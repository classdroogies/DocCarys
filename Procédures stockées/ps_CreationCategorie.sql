use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_CreationCategorie') IS NOT NULL DROP PROCEDURE ps_CreationCategorie
go

CREATE PROCEDURE ps_CreationCategorie(@pLibelleCategorie varchar(200),
									  @pTauxTva float,
								      @oId int OUTPUT,
								      @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_CreationCategorie(@pLibelleCategorie varchar(200), @pTauxTva float, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_CreationCategorie *	Auteur : Corentin ROGERÉ							*
 ****************************************************************************************
 * Cette procédure permet de créer un nouvelle catégorie.								*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pLibelleCategrie : libellé de a catégorie,									*
 *		- pTauxTva : taux de tva de la catégorie,										*
 *		- oId : identifiant de la catégorie,											*
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
	SET @pLibelleCategorie = dbo.fn_CleanString(@pLibelleCategorie);

	/* Mise en forme du taux de tva ex. 0.055 pour une TVA à 5.5% 3 chiffres apès la virgule */
	if @pTauxTva is not null
	begin
		set @pTauxTva = ROUND(@pTauxTva, 3);
	end

	/* vérification des paramètres */
	/* vérif de la cohérence du libellé de la catégorie */
	if @pLibelleCategorie is null
	begin
		set @oMessage = ' ** Le libellé de la nouvelle catégorie n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleCategorie LIKE('')
	begin
		set @oMessage = ' ** Le libellé de la nouvelle catégorie est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérif de la cohérence du taux de tva */
	else if @pTauxTva is null
	begin
		set @oMessage = ' ** Le taux de TVA lié à la catégorie n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pTauxTva not between 0.0 and 50.0
	begin
		set @oMessage = ' ** Le taux de TVA lié à la catégorie doit être compris entre 0.00 et 50.0. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verouillage de la table Categorie */
		select @dummy = 0 from Categorie with (holdlock, tablockx);

		/* Vérification de l'existence de la catégorie */
		if exists(select * from Categorie where LibelleCategorie=@pLibelleCategorie)
		begin
			set @oMessage = ' ** Il existe déjà une catégorie avec ce même libellé dans la base de données. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Libération des tables
		end

		/* création de la catégorie */
		else
		begin
			/* Enregistrement de la nouvelle Catégorie */
			Insert Categorie(LibelleCategorie, Tva)
			values (@pLibelleCategorie, @pTauxTva);

			/* Récup de l'id */
			set @oId = (select IdCategorie from Categorie where LibelleCategorie = @pLibelleCategorie collate French_CI_AI);

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