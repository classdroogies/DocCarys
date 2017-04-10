use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_CreationActeur') IS NOT NULL DROP PROCEDURE ps_CreationActeur
go

CREATE PROCEDURE ps_CreationActeur(@pNomActeur varchar(200),
								   @pIdRoleActeur int,
								   @oId int OUTPUT,
								   @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_CreationCategorie(@pNomActeur varchar(200), @pIdRoleActeur int, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_CreationActeur *	Auteur : Corentin ROGERÉ							*
 ****************************************************************************************
 * Cette procédure permet de créer un nouvel acteur.									*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pNomActeur : nom de l'acteur,													*
 *		- pIdRoleActeur : identifiant du rôle associée à l'acteur,						*
 *		- oId : identifiant de l'acteur,												*
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
			@paramNonConforme int,		-- sert à affecter codeRet en cas de paramètre non conforme
			@paramInexistant int,		-- sert à affecter codeRet en cas de paramètre inexistant dans la base
			@dejaFait int,				-- sert à affecter codeRet en cas d'action déjà faite
			@actionInterdite int,		-- sert à affecter codeRet en cas d'action allant à l'encontre des règles de gestion
			@pbBase int,				-- sert à affecter codeRet quand il y a un problème sur la base de données
			@trancountOrigine int,		-- sert à stocker le trancount d'origine en cas d'annulation
			@dummy int;					-- sert à verrouiller les tables sans lancer de résultats
											   
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
	SET @pNomActeur = dbo.fn_CleanString(@pNomActeur);

	/* vérification des paramètres */
	/* vérification de la cohérence du nom de l'acteur */
	if @pNomActeur is null
	begin
		set @oMessage = ' ** Le nom du nouvel acteur n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pNomActeur LIKE('')
	begin
		set @oMessage = ' ** Le nom du nouvel acteur est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* vérification de la cohérence de l'identifiant du rôle */
	else if @pIdRoleActeur is null
	begin
		set @oMessage = ' ** L''identifiant du rôle n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdRoleActeur < 1
	begin
		set @oMessage = ' ** L''identifiant du rôle doit être supérieur à 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage des tables RoleActeur et Acteur */
		select @dummy = 0 from RoleActeur, Acteur with (holdlock, tablockx);

		/* Vérification de l'existence du rôl */
		if not exists(select * from RoleActeur where IdRoleActeur=@pIdRoleActeur)
		begin
			set @oMessage = ' ** L''identifiant du rôle associé n''existe pas dans la base de données. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de la non existence de l'acteur associé au même rôle) */
		else if exists (select * from Acteur where NomActeur=@pNomActeur and IdRoleActeur=@pIdRoleActeur)
		begin
			set @oMessage = ' ** Il existe déjà un acteur avec le même libellé et le même rôle dans la base de données. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Libération des tables
		end

		/* création du genre */
		else
		begin
			/* Enregistrement du nouvel acteur */
			Insert Acteur(NomActeur, IdRoleActeur)
			values (@pNomActeur, @pIdRoleActeur);

			/* Récup de l'id */
			set @oId = (select IdActeur from Acteur where NomActeur = @pNomActeur collate French_CI_AI);

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