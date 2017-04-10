use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_CreationRoleActeur') IS NOT NULL DROP PROCEDURE ps_CreationRoleActeur
go

CREATE PROCEDURE ps_CreationRoleActeur(@pLibelleRoleActeur varchar(200),
								 @oId int OUTPUT,
								 @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_CreationCategorie(@pLibelleRoleActeur varchar(200), @pIdCategorie int, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_CreationRoleActeur *	Auteur : Corentin ROGERÉ						*
 ****************************************************************************************
 * Cette procédure permet de créer un nouveau rôle.										*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pLibelleRoleActeur : libellé du rôle,												*
 *		- oId : identifiant du rôle,													*
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

	/* nettoyage du libellé du rôle */
	SET @pLibelleRoleActeur = dbo.fn_CleanString(@pLibelleRoleActeur);

	/* vérification des paramètres */
	/* vérification de la cohérence du libellé du rôle */
	if @pLibelleRoleActeur is null
	begin
		set @oMessage = ' ** Le libellé du nouveau rôle n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleRoleActeur LIKE('')
	begin
		set @oMessage = ' ** Le libellé du nouveau rôle est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage de la table RoleActeur */
		select @dummy = 0 from RoleActeur with (holdlock, tablockx);

		/* Vérification de la non existence du Rôle */
		if exists (select * from RoleActeur where LibelleRoleActeur=@pLibelleRoleActeur)
		begin
			set @oMessage = ' ** Il existe déjà un rôle avec le même libellé. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Libération des tables
		end

		/* création du genre */
		else
		begin
			/* Enregistrement du nouveau rôle */
			Insert RoleActeur(LibelleRoleActeur)
			values (@pLibelleRoleActeur);

			/* Récup de l'id */
			set @oId = (select IdRoleActeur from RoleActeur where LibelleRoleActeur = @pLibelleRoleActeur collate French_CI_AI);

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