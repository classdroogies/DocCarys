use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_SuppressionGenre') IS NOT NULL DROP PROCEDURE ps_SuppressionGenre
go

CREATE PROCEDURE ps_SuppressionGenre(@pIdGenre int,
									 @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_SuppressionGenre(@pIdGenre int, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_SuppressionGenre *	Auteur : Corentin ROGERÉ							*
 ****************************************************************************************
 * Cette procédure permet de supprimer un genre de la base de données.					*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pIdGenre : Identifiant du genre,												*
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

	/* vérification des paramètres */
	/* vérification de la cohérence d""e l'identifiant du genre */
	if @pIdGenre is null
	begin
		set @oMessage = ' ** L''identifiant du genre à supprimer n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdGenre < 1
	begin
		set @oMessage = ' ** L''identifiant du genre à supprimer n''est pas correct il doit être supérieur à 0.  ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage des tables Article et Genre */
		select @dummy = 0 from Article, Genre with (holdlock, tablockx);

		/* Vérification de l'existence du genre */
		if not exists(select * from Genre where IdGenre=@pIdGenre)
		begin
			set @oMessage = ' ** L''identifiant du genre que vous souhaitez supprimer ne correspond à aucun genre dans la base de données. ** ';
			set @codeRet = @paramNonConforme;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de l'inexistence d'article correspondant au genre. */
		else if exists(select * from Article where IdGenre=@pIdGenre)
		begin
			set @oMessage = ' ** Le genre que vous souhaitez supprimer est utilisé par un ou plusieurs article, par conséquent sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end

		/* suppression du genre */
		else
		begin
			/* suppression du genre */
			delete from Genre where IdGenre = @pIdGenre;

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