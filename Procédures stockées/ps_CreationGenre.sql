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
 * Proc�dure ps_CreationGenre *	Auteur : Corentin ROGER�								*
 ****************************************************************************************
 * Cette proc�dure permet de cr�er un nouveau genre.									*
 * La proc�dure est s�curis�e.															*
 *																						*
 * Param�tres :																			*
 *		- pLibelleGenre : libell� du genre,												*
 *		- pIdCategorie : identifiant de la cat�gorie associ�e au genre,					*
 *		- oId : identifiant du genre,											*
 *		- oMessage : message de sortie de la proc�dure.									*
 *																						*
 * Retourne le r�sultat de l'ex�cution de la proc�dure :								*
 *		- 0 : tout s'est bien pass�,													*
 *		- 1 : un param�tre est manquant/vide (= null),									*
 *		- 2 : un param�tre n'est pas conforme (pb valeur/format),						*
 *		- 3 : un �l�ment demand� n'existe pas,											*
 *		- 4 : une action est redondante(d�j� fait, d�j� cr��),							*
 *		- 5 : une action est interdite, impossible (r�gle de gestion),					*
 *		- 9 : probl�me sur la base de donn�es.											*
 ****************************************************************************************/		
 AS
	/* D�claration des variables */
	declare	@codeRet int,				-- Rapport d'ex�cution de la proc�dure
			@reussite int,				-- sert � affecter codeRet quand tout s'est bien pass�
			@paramManquant int,			-- sert � affecter codeRet en cas de param�tre manquant
			@paramNonConforme int,		-- sert � affecter codeRet en cas de parametre non conforme
			@paramInexistant int,		-- sert � affecter codeRet en cas de param�tre inexistant dans la base
			@dejaFait int,				-- sert � affecter codeRet en cas d'action d�j� faite
			@actionInterdite int,		-- sert � affecter codeRet en cas d'action allant � l'encontre des r�gles de gestion
			@pbBase int,				-- sert � affecter codeRet quand il y a un probl�me sur la base de donn�es
			@trancountOrigine int,		-- sert � stocker le trancount d'origine en cas d'annulation
			@dummy int;					-- sert � v�rouiller les tables sans lancer de r�sultats
											   
/* D�but */
	/* Initialisation des variables */
	set @reussite = 0;
	set @paramManquant = 1;
	set @paramNonConforme = 2;
	set @paramInexistant = 3;
	set @dejaFait = 4;	
	set @actionInterdite = 5;
	set @pbBase = 9;

	/* nettoyage du libell� de a cat�gorie */
	SET @pLibelleGenre = dbo.fn_CleanString(@pLibelleGenre);

	/* v�rification des param�tres */
	/* v�rif de la coh�rence du libell� du genre */
	if @pLibelleGenre is null
	begin
		set @oMessage = ' ** Le libell� du nouveau genre n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleGenre LIKE('')
	begin
		set @oMessage = ' ** Le libell� du nouveau genre est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* v�rif de la coh�rence de l'id de la cat�gorie */
	else if @pIdCategorie is null
	begin
		set @oMessage = ' ** L''identifiant de la cat�gorie n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdCategorie < 1
	begin
		set @oMessage = ' ** L''identifiant de la cat�gorie doit �tre sup�rieur � 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* r�cup�ration de l'�tat de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verouillage des tables Categorie et Genre */
		select @dummy = 0 from Categorie, Genre with (holdlock, tablockx);

		/* V�rification de l'existence de la cat�gorie */
		if not exists(select * from Categorie where IdCategorie=@pIdCategorie)
		begin
			set @oMessage = ' ** L''identifiant de la cat�gorie associ�e n''existe pas dans la base de donn�es. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Lib�ration des tables
		end

		/* V�rification de la non existence du genre */ /* (associ� � la m�me cat�gorie) */
		else if exists (select * from Genre where LibelleGenre=@pLibelleGenre) /* and IdCategorie=@pIdCategorie)*/
		begin
			set @oMessage = ' ** Il existe d�j� un genre avec le m�me libell�. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Lib�ration des tables
		end

		/* cr�ation du genre */
		else
		begin
			/* Enregistrement du nouveau Genre */
			Insert Genre(LibelleGenre, IdCategorie)
			values (@pLibelleGenre, @pIdCategorie);

			/* R�cup de l'id */
			set @oId = (select IdGenre from Genre where LibelleGenre = @pLibelleGenre collate French_CI_AI);

			/* Validation de la transaction */
			commit transaction;

			set @oMessage = 'OK';
			set @codeRet = @reussite;
		end

	
	end try
	begin catch
		/* Probl�me sur la base de donn�es */
		set @oMessage = '** Il y a un probl�me dans la base de donn�es ** ' + ERROR_MESSAGE();
		set @codeRet = @pbBase;
		while (@@TRANCOUNT > @trancountOrigine)
		begin
			/* Annulation de ce qui a �t� fait */
			rollback transaction;
		end
	end catch
	/* retour du r�sultat de la proc�dure */
	return @codeRet
/* Fin */
go