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
 * Proc�dure ps_CreationArticle *	Auteur : Corentin ROGER�							*
 ****************************************************************************************
 * Cette proc�dure permet de cr�er un nouvel article.									*
 * La proc�dure est s�curis�e.															*
 *																						*
 * Param�tres :																			*
 *		- pLibelleArticle : libell� de l'article,										*
 *		- pPrix : prix de l'article,													*
 *		- pPhotoArticle : nom du fichier contenant la photo de l'article,				*
 *		- pDescriptionArticle : description de l'article,								*
 *		- pIdGenre : identifiant du genre de l'article,									*
 *		- pPrixFournisseur : prix d'achat de l'article,									*
 *		- pIdFournisseur : identifiant du fournisseur,									*
 *		- pReapprovisionnable : indicateur pous savoir si l'article est					*
							    r�approvisionnable										*
 *		- oReference : reference dee l'article,											*
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

	/* nettoyage du libell� de l'article */
	SET @pLibelleArticle = dbo.fn_CleanString(@pLibelleArticle);

	/* nettoyage du prix d'achat */
	if @pPrixFournisseur = 0
	begin
		set @pPrixFournisseur = null;
	end

	/* v�rification des param�tres */
	/* v�rif de la coh�rence du libell� de l'article */
	if @pLibelleArticle is null
	begin
		set @oMessage = ' ** Le libell� du nouvel article n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleArticle LIKE('')
	begin
		set @oMessage = ' ** Le libell� du nouvel article est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* v�rif de la coh�rence du prix */
	else if @pPrix is null
	begin
		set @oMessage = ' ** Le prix de l''article n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pPrix not between 0.01 and 100
	begin
		set @oMessage = ' ** Le prix de vente de l''article doit �tre compris entre 0.01� et 100�. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* v�rif de la coh�rence de l'identifiant du genre */
	else if @pIdGenre is null
	begin
		set @oMessage = ' ** L''identifiant du genre de l''article n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdGenre < 1
	begin
		set @oMessage = ' ** L''identifiant du genre de l''article doit �tre sup�rieur � 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* v�rif de la coh�rence du prix d'achat */
	else if @pPrixFournisseur is not null and  @pPrixFournisseur not between 0.01 and 50
	begin
		set @oMessage = ' ** Le prix d''achat de l''article doit �tre compris entre 0.01� et 50�. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* v�rif de la coh�rence de l'identifiant du fournisseur */
	else if @pIdFournisseur is null
	begin
		set @oMessage = ' ** L''identifiant du fournisseur de l''article n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdFournisseur < 1
	begin
		set @oMessage = ' ** L''identifiant du fournisseur de l''article doit �tre sup�rieur � 0. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* r�cup�ration de l'�tat de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verouillage de la table MODELE */
		select @dummy = 0 from Article, Fournisseur, Genre with (holdlock, tablockx);

		/* V�rification de l'existence du genre */
		if not exists(select * from Genre where IdGenre=@pIdGenre)
		begin
			set @oMessage = ' ** Le genre fourni n''existe pas dans la base de donn�es. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Lib�ration des tables
		end

		/* V�rification de l'existence du fournisseur */
		else if not exists(select * from Fournisseur where IdFournisseur=@pIdFournisseur)
		begin
			set @oMessage = ' ** Le fournisseur fourni n''existe pas dans la base de donn�es. ** ';
			set @codeRet = @paramInexistant;
			rollback transaction;	-- Lib�ration des tables
		end

		/* V�rification de la non existence d'un mod�le avec le m�me nom */
		else if exists (select * from Article where LibelleArticle = @pLibelleArticle collate French_CI_AI and IdGenre = @pIdGenre and IdFournisseur = @pIdFournisseur)
		begin
			set @oMessage = ' ** Un Article avec le m�me libell�, le m�me genre et le m�me fournisseur existe d�j� dans la base. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Lib�ration des tables
		end

		/* cr�ation de l'article */
		else
		begin
			/* Enregistrement du nouvel Article */
			Insert Article(LibelleArticle, Prix,PhotoArticle, DescriptionArticle, IdGenre, PrixFournisseur, IdFournisseur, Reapprovisionnable)
			values (@pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable);

			/* R�cup de l'id */
			set @oReference = (select Reference from Article where LibelleArticle = @pLibelleArticle collate French_CI_AI and IdGenre = @pIdGenre and IdFournisseur = @pIdFournisseur);

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