use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_CreationArticle') IS NOT NULL DROP PROCEDURE ps_CreationArticle
go

CREATE PROCEDURE ps_CreationArticle(@pLibelleArticle varchar(200),
								    @pPrix float,
									@pPhotoArticle varchar(200),
									@pDescriptionArticle text,
								    @pIdGenre int,
									@pPrixFournisseur float,
									@pIdFournisseur int,
									@pReapprovisionnable bit,
								    @oReference int OUTPUT,
								    @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_CreationArticle(@pLibelleArticle varchar(200), @pPrix float, @pPhotoArticle varchar(200), @pDescriptionArticle text, @pIdGenre int, @pPrixFournisseur float, @pIdFournisseur int, @pReapprovisionnable bit, @oReference int OUTPUT, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_CreationArticle *	Auteur : Corentin ROGERÉ							*
 ****************************************************************************************
 * Cette procédure permet de créer un nouvel article.									*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pLibelleArticle : libellé de l'article,										*
 *		- pPrix : prix de l'article,													*
 *		- pPhotoArticle : nom du fichier contenant la photo de l'article,				*
 *		- pDescriptionArticle : description de l'article,								*
 *		- pIdGenre : identifiant du genre de l'article,									*
 *		- pPrixFournisseur : prix d'achat de l'article,									*
 *		- pIdFournisseur : identifiant du fournisseur,									*
 *		- pReapprovisionnable : indicateur pous savoir si l'article est					*
							    réapprovisionnable										*
 *		- oReference : reference dee l'article,											*
 *		- oMessage : message de sortie de la procédure.									*
 *																						*
 * Retourne le résultat de l'exécution de la procédure :								*
 *		- 0 : tout s'est bien passé,													*
 *		- 1 : un paramètre est manquant/vide (= null),									*
 *		- 2 : un paramètre n'est pas conforme (pb valeur/format),						*
 *		- 3 : un élément demandé n'existe pas,											*
 *		- 4 : une action est redondante(déjà fait, déjà créé),							*
 *		- 5 : une action est interdite, impossible (règle de gestion),					*
 *		- 9 : problème sur la base de données.											*
 ****************************************************************************************/		
 AS
	/* Déclaration des variables */
	declare	@codeRet int,				-- Rapport d'exécution de la procédure
			@reussite int,				-- sert à affecter codeRet quand tout s'est bien passé
			@paramManquant int,			-- sert à affecter codeRet en cas de paramètre manquant
			@paramNonConforme int,		-- sert à affecter codeRet en cas de parametre non conforme
			@paramInexistant int,		-- sert à affecter codeRet en cas de paramètre inexistant dans la base
			@dejaFait int,				-- sert à affecter codeRet en cas d'action déjà faite
			@actionInterdite int,		-- sert à affecter codeRet en cas d'action allant à l'encontre des régles de gestion
			@pbBase int,				-- sert à affecter codeRet quand il y a un problème sur la base de données
			@trancountOrigine int,		-- sert à stocker le trancount d'origine en cas d'annulation
			@dummy int;					-- sert à vérouiller les tables sans lancer de résultats
											   
/* Début */
	/* Initialisation des variables */
	set @reussite = 0;
	set @paramManquant = 1;
	set @paramNonConforme = 2;
	set @paramInexistant = 3;
	set @dejaFait = 4;	
	set @actionInterdite = 5;
	set @pbBase = 9;

	/* nettoyage du libellé de l'article */
	SET @pLibelleArticle = dbo.fn_CleanString(@pLibelleArticle);

	/* nettoyage du prix d'achat */
	if @pPrixFournisseur = 0
	begin
		set @pPrixFournisseur = null;
	end

	/* vérification des paramètres */
	/* vérif de la cohérence du libellé de l'article */
	if @pLibelleArticle is null
	begin
		set @oMessage = ' ** Le libellé du nouvel article n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleArticle LIKE('')
	begin
		set @oMessage = ' ** Le libellé du nouvel article est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérif de la cohérence du prix */
	else if @pPrix is null
	begin
		set @oMessage = ' ** Le prix de l''article n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pPrix not between 0.01 and 100
	begin
		set @oMessage = ' ** Le prix de vente de l''article doit être compris entre 0.01€ et 100€. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérif de la cohérence de l'identifiant du genre */
	else if @pIdGenre is null
	begin
		set @oMessage = ' ** L''identifiant du genre de l''article n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdGenre < 1
	begin
		set @oMessage = ' ** L''identifiant du genre de l''article doit être supérieur à 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérif de la cohérence du prix d'achat */
	else if @pPrixFournisseur is not null and  @pPrixFournisseur not between 0.01 and 50
	begin
		set @oMessage = ' ** Le prix d''achat de l''article doit être compris entre 0.01€ et 50€. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérif de la cohérence de l'identifiant du fournisseur */
	else if @pIdFournisseur is null
	begin
		set @oMessage = ' ** L''identifiant du fournisseur de l''article n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdFournisseur < 1
	begin
		set @oMessage = ' ** L''identifiant du fournisseur de l''article doit être supérieur à 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verouillage de la table MODELE */
		select @dummy = 0 from Article, Fournisseur, Genre with (holdlock, tablockx);

		/* Vérification de l'existence du genre */
		if not exists(select * from Genre where IdGenre=@pIdGenre)
		begin
			set @oMessage = ' ** Le genre fourni n''existe pas dans la base de données. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de l'existence du fournisseur */
		else if not exists(select * from Fournisseur where IdFournisseur=@pIdFournisseur)
		begin
			set @oMessage = ' ** Le fournisseur fourni n''existe pas dans la base de données. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de la non existence d'un modèle avec le même nom */
		else if exists (select * from Article where LibelleArticle = @pLibelleArticle collate French_CI_AI and IdGenre = @pIdGenre and IdFournisseur = @pIdFournisseur)
		begin
			set @oMessage = ' ** Un Article avec le même libellé, le même genre et le même fournisseur existe déjà dans la base. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Libération des tables
		end

		/* création de l'article */
		else
		begin
			/* Enregistrement du nouvel Article */
			Insert Article(LibelleArticle, Prix,PhotoArticle, DescriptionArticle, IdGenre, PrixFournisseur, IdFournisseur, Reapprovisionnable)
			values (@pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable);

			/* Récup de l'id */
			set @oReference = (select Reference from Article where LibelleArticle = @pLibelleArticle collate French_CI_AI and IdGenre = @pIdGenre and IdFournisseur = @pIdFournisseur);

			/* Validation de la transaction */
			commit transaction;

			set @oMessage = 'OK';
			set @codeRet = @reussite;
		end

	
	end try
	begin catch
		/* Problème sur la base de données */
		set @oMessage = '** Il y a un problème dans la base de données ** ' + ERROR_MESSAGE();
		set @codeRet = @pbBase;
		while (@@TRANCOUNT > @trancountOrigine)
		begin
			/* Annulation de ce qui a été fait */
			rollback transaction;
		end
	end catch
	/* retour du résultat de la procédure */
	return @codeRet
/* Fin */
go