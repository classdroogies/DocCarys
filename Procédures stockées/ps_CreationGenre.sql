use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_CreationGenre') IS NOT NULL DROP PROCEDURE ps_CreationGenre
go

CREATE PROCEDURE ps_CreationGenre(@pLibelleGenre varchar(200),
								  @pIdCategorie int,
								  @oId int OUTPUT,
								  @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_CreationCategorie(@pLibelleGenre varchar(200), @pIdCategorie int, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_CreationGenre *	Auteur : Corentin ROGERÉ								*
 ****************************************************************************************
 * Cette procédure permet de créer un nouveau genre.									*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pLibelleGenre : libellé du genre,												*
 *		- pIdCategorie : identifiant de la catégorie associée au genre,					*
 *		- oId : identifiant du genre,											*
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

	/* nettoyage du libellé de a catégorie */
	SET @pLibelleGenre = dbo.fn_CleanString(@pLibelleGenre);

	/* vérification des paramètres */
	/* vérif de la cohérence du libellé du genre */
	if @pLibelleGenre is null
	begin
		set @oMessage = ' ** Le libellé du nouveau genre n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleGenre LIKE('')
	begin
		set @oMessage = ' ** Le libellé du nouveau genre est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérif de la cohérence de l'id de la catégorie */
	else if @pIdCategorie is null
	begin
		set @oMessage = ' ** L''identifiant de la catégorie n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdCategorie < 1
	begin
		set @oMessage = ' ** L''identifiant de la catégorie doit être supérieur à 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verouillage des tables Categorie et Genre */
		select @dummy = 0 from Categorie, Genre with (holdlock, tablockx);

		/* Vérification de l'existence de la catégorie */
		if not exists(select * from Categorie where IdCategorie=@pIdCategorie)
		begin
			set @oMessage = ' ** L''identifiant de la catégorie associée n''existe pas dans la base de données. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de la non existence du genre */ /* (associé à la même catégorie) */
		else if exists (select * from Genre where LibelleGenre=@pLibelleGenre) /* and IdCategorie=@pIdCategorie)*/
		begin
			set @oMessage = ' ** Il existe déjà un genre avec le même libellé. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Libération des tables
		end

		/* création du genre */
		else
		begin
			/* Enregistrement du nouveau Genre */
			Insert Genre(LibelleGenre, IdCategorie)
			values (@pLibelleGenre, @pIdCategorie);

			/* Récup de l'id */
			set @oId = (select IdGenre from Genre where LibelleGenre = @pLibelleGenre collate French_CI_AI);

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