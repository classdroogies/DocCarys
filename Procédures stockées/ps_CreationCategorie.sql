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
 * Proc�dure ps_CreationCategorie *	Auteur : Corentin ROGER�							*
 ****************************************************************************************
 * Cette proc�dure permet de cr�er un nouvelle cat�gorie.								*
 * La proc�dure est s�curis�e.															*
 *																						*
 * Param�tres :																			*
 *		- pLibelleCategrie : libell� de a cat�gorie,									*
 *		- pTauxTva : taux de tva de la cat�gorie,										*
 *		- oId : identifiant de la cat�gorie,											*
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
	SET @pLibelleCategorie = dbo.fn_CleanString(@pLibelleCategorie);

	/* Mise en forme du taux de tva ex. 0.055 pour une TVA � 5.5% 3 chiffres ap�s la virgule */
	if @pTauxTva is not null
	begin
		set @pTauxTva = ROUND(@pTauxTva, 3);
	end

	/* v�rification des param�tres */
	/* v�rif de la coh�rence du libell� de la cat�gorie */
	if @pLibelleCategorie is null
	begin
		set @oMessage = ' ** Le libell� de la nouvelle cat�gorie n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pLibelleCategorie LIKE('')
	begin
		set @oMessage = ' ** Le libell� de la nouvelle cat�gorie est vide ou ne contient que des espaces. ** ';
		set @codeRet = @paramNonConforme;
	end

	/* v�rif de la coh�rence du taux de tva */
	else if @pTauxTva is null
	begin
		set @oMessage = ' ** Le taux de TVA li� � la cat�gorie n''a pas �t� fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pTauxTva not between 0.0 and 0.50
	begin
		set @oMessage = ' ** Le taux de TVA li� � la cat�gorie doit �tre compris entre 0.00 et 0.50. ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* r�cup�ration de l'�tat de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verouillage de la table Categorie */
		select @dummy = 0 from Categorie with (holdlock, tablockx);

		/* V�rification de l'existence de la cat�gorie */
		if exists(select * from Categorie where LibelleCategorie=@pLibelleCategorie)
		begin
			set @oMessage = ' ** Il existe d�j� une cat�gorie avec ce m�me libell� dans la base de donn�es. ** ';
			set @codeRet = @dejaFait;
			rollback transaction;	-- Lib�ration des tables
		end

		/* cr�ation de la cat�gorie */
		else
		begin
			/* Enregistrement de la nouvelle Cat�gorie */
			Insert Categorie(LibelleCategorie, Tva)
			values (@pLibelleCategorie, @pTauxTva);

			/* R�cup de l'id */
			set @oId = (select IdCategorie from Categorie where LibelleCategorie = @pLibelleCategorie collate French_CI_AI);

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