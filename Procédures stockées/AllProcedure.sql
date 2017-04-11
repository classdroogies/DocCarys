use master;
go

use master
go


use Sebo_Carys
IF OBJECT_ID ('fn_CleanString') IS NOT NULL DROP FUNCTION fn_CleanString
go

CREATE FUNCTION fn_CleanString (@pChaineBrute varchar(254))
								RETURNS varchar(254)
 /***************************************************************************************
 * Procédure fn_CleanString *	Auteur : Anthony ORGER									*
 ****************************************************************************************
 * Cette fonction renvoie une chaine débarrassée de ses caractères non imprimables. 	*
 *																						*
 * Paramètres :																			*
 *		- @pChaineBrute : l'id de catégorie donnée en paramètre							*
 *																						*
 * Retourne la chaine nettoyée															*
 ****************************************************************************************/
AS
BEGIN
	-- Déclaration des variables --
	DECLARE	 @oChaineNette	varchar(254);	-- la chaine à renvoyer

	-- élimination ciblée, code à code -- 
	-- suppression des espaces		
	SET @oChaineNette = LTRIM(RTRIM(@pChaineBrute))

	-- suppression des caractères de tabulation. Équivalents à \t , \x09 et \cI.
	SET @oChaineNette = REPLACE(@oChaineNette,char(9),'')

	-- suppression des caractères de saut de ligne. Équivalents à \n , \x0a et \cJ
	SET @oChaineNette = REPLACE(@oChaineNette,char(10),'')

	-- suppression des caractères de tabulation verticale. Équivalents à \v , \x0b et \cK.
	SET @oChaineNette = REPLACE(@oChaineNette,char(11),'')

	-- suppression des caractères de saut de page. Équivalents à \f , \x0c et \cL
	SET @oChaineNette = REPLACE(@oChaineNette,char(12),'')

	-- suppression des caractères de retour chariot Équivalents à \r ,  \x0d et \cM
	SET @oChaineNette = REPLACE(@oChaineNette,char(13),'')
		
	/* retour du résultat de la fonction */
	return @oChaineNette
END
go

use Sebo_Carys
IF OBJECT_ID ('ps_CreationActeur') IS NOT NULL DROP PROCEDURE ps_CreationActeur
go

CREATE PROCEDURE ps_CreationActeur(@pNomActeur varchar(200),
								   @pIdRoleActeur int,
								   @oId int OUTPUT,
								   @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_CreationActeur(@pNomActeur varchar(200), @pIdRoleActeur int, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
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
			Insert Article(LibelleArticle, Prix,PhotoArticle, DescriptionArticle, IdGenre, PrixAchat, IdFournisseur, Reapprovisionnable)
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

use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_SuppressionActeur') IS NOT NULL DROP PROCEDURE ps_SuppressionActeur
go

CREATE PROCEDURE ps_SuppressionActeur(@pIdActeur int,
									 @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_SuppressionActeur(@pIdActeur int, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_SuppressionActeur *	Auteur : Corentin ROGERÉ							*
 ****************************************************************************************
 * Cette procédure permet de supprimer un acteur de la base de données.					*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pIdActeur : Identifiant de l'acteur,											*
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
	/* vérification de la cohérence de l'identifiant de l'acteur */
	if @pIdActeur is null
	begin
		set @oMessage = ' ** L''identifiant de l''acteur à supprimer n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdActeur < 1
	begin
		set @oMessage = ' ** L''identifiant de l''acteur à supprimer n''est pas correct il doit être supérieur à 0.  ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage des tables Article et Acteur */
		select @dummy = 0 from Article, Acteur with (holdlock, tablockx);

		/* Vérification de l'existence de l'acteur */
		if not exists(select * from Acteur where IdActeur=@pIdActeur)
		begin
			set @oMessage = ' ** L''identifiant de l''acteur que vous souhaitez supprimer ne correspond à aucun acteur dans la base de données. ** ';
			set @codeRet = @paramNonConforme;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de l'inexistence d'article correspondant à l'acteur. */
		else if exists(select * from Acteur where IdActeur=@pIdActeur)
		begin
			set @oMessage = ' ** L''acteur que vous souhaitez supprimer est utilisé par un ou plusieurs article, par conséquent sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end

		/* suppression du acteur */
		else
		begin
			/* suppression du acteur */
			delete from Acteur where IdActeur = @pIdActeur;

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

use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_SuppressionArticle') IS NOT NULL DROP PROCEDURE ps_SuppressionArticle
go

CREATE PROCEDURE ps_SuppressionArticle(@pRefArticle int,
									   @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_SuppressionArticle(@pRefArticle int, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_SuppressionArticle *	Auteur : Corentin ROGERÉ						*
 ****************************************************************************************
 * Cette procédure permet de supprimer un article de la base de données.				*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pRefArticle : référence de l'article,											*
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
	/* vérification de la cohérence de la référence de l'article */
	if @pRefArticle is null
	begin
		set @oMessage = ' ** La référence de l''article à supprimer n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pRefArticle < 1
	begin
		set @oMessage = ' ** La référence de l''article à supprimer n''est pas correct il doit être supérieur à 0.  ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage des tables Article, StockArticle, LigneCommande et LigneCommandeFournisseur */
		select @dummy = 0 from Article, StockArticle, LigneCommande, LigneCommandeFournisseur with (holdlock, tablockx);

		/* Vérification de l'existence de l'article */
		if not exists(select * from Article where Reference=@pRefArticle)
		begin
			set @oMessage = ' ** La référence de l''article que vous souhaitez supprimer ne correspond à aucun article dans la base de données. ** ';
			set @codeRet = @paramNonConforme;
			rollback transaction;	-- Libération des tables
		end
		/* Vérification de l'inexistence de Stocks correspondant à l'article. */
		else if exists(select * from StockArticle where Reference=@pRefArticle)
		begin
			set @oMessage = ' ** L''article que vous souhaitez supprimer est référencé dans les stocks, sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end
		/* Vérification de l'inexistence de lignes de commande correspondant à l'article. */
		else if exists(select * from LigneCommande where Reference=@pRefArticle)
		begin
			set @oMessage = ' ** L''article que vous souhaitez supprimer est référencé dans au moins une commande, sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end
		/* Vérification de l'inexistence de lignes de commande fournisseur correspondant à l'article. */
		else if exists(select * from LigneCommandeFournisseur where Reference=@pRefArticle)
		begin
			set @oMessage = ' ** L''article que vous souhaitez supprimer est référencé dans au moins une commande fournisseur, sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end

		/* suppression de l'article */
		else
		begin
			/* suppression de l'a'rticle */
			delete from Article where Reference = @pRefArticle;

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

use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_SuppressionCategorie') IS NOT NULL DROP PROCEDURE ps_SuppressionCategorie
go

CREATE PROCEDURE ps_SuppressionCategorie(@pIdCategorie int,
										 @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_SuppressionCategorie(@pIdCategorie int, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_SuppressionCategorie *	Auteur : Corentin ROGERÉ						*
 ****************************************************************************************
 * Cette procédure permet de supprimer une catégorie de la base de données.				*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pIdCategorie : Identifiant de la catégorie,									*
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
	/* vérification de la cohérence de l'identifiant de la catégorie */
	if @pIdCategorie is null
	begin
		set @oMessage = ' ** L''identifiant de la catégorie à supprimer n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdCategorie < 1
	begin
		set @oMessage = ' ** L''identifiant de la catégorie à supprimer n''est pas correct il doit être supérieur à 0.  ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage des tables Categorie et Genre */
		select @dummy = 0 from Categorie, Genre with (holdlock, tablockx);

		/* Vérification de l'existence de la catégorie */
		if not exists(select * from Categorie where IdCategorie=@pIdCategorie)
		begin
			set @oMessage = ' ** L''identifiant de la catégorie que vous souhaitez supprimer ne correspond à aucune catégorie dans la base de données. ** ';
			set @codeRet = @paramNonConforme;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de l'inexistence de genres correspondant à la catégorie. */
		else if exists(select * from Genre where IdCategorie=@pIdCategorie)
		begin
			set @oMessage = ' ** La catégorie que vous souhaitez supprimer est utilisé par un ou plusieurs genre, par conséquent sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end

		/* suppression de la catégorie */
		else
		begin
			/* suppression de la catégorie */
			delete from Categorie where IdCategorie = @pIdCategorie;

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

use master;
go


use Sebo_Carys
IF OBJECT_ID ('ps_SuppressionRoleActeur') IS NOT NULL DROP PROCEDURE ps_SuppressionRoleActeur
go

CREATE PROCEDURE ps_SuppressionRoleActeur(@pIdRoleActeur int,
										  @oMessage varchar(200) OUTPUT)
--ALTER PROCEDURE ps_SuppressionRoleActeur(@pIdRoleActeur int, @oMessage varchar(200) OUTPUT)
/****************************************************************************************
 * Procédure ps_SuppressionRoleActeur *	Auteur : Corentin ROGERÉ						*
 ****************************************************************************************
 * Cette procédure permet de supprimer un rôleActeur de la base de données.				*
 * La procédure est sécurisée.															*
 *																						*
 * Paramètres :																			*
 *		- pIdRoleActeur : Identifiant du rôle à supprimer,								*
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
	/* vérification de la cohérence de l'identifiant du rôle */
	if @pIdRoleActeur is null
	begin
		set @oMessage = ' ** L''identifiant du rôle à supprimer n''a pas été fourni. ** ';
		set @codeRet = @paramManquant;
	end
	else if @pIdRoleActeur < 1
	begin
		set @oMessage = ' ** L''identifiant du rôle à supprimer n''est pas correct il doit être supérieur à 0.  ** ';
		set @codeRet = @paramNonConforme;
	end

	else
	begin try
		/* récupération de l'état de transaction d'origine */
		set @trancountOrigine = @@TRANCOUNT;

		/* On lance la transaction pour annuler en cas d'erreur */
		begin transaction;

		/* Verrouillage des tables Article et Genre */
		select @dummy = 0 from RoleActeur, Acteur with (holdlock, tablockx);

		/* Vérification de l'existence du rôle */
		if not exists(select * from RoleActeur where IdRoleActeur=@pIdRoleActeur)
		begin
			set @oMessage = ' ** L''identifiant du rôle que vous souhaitez supprimer ne correspond à aucun rôle dans la base de données. ** ';
			set @codeRet = @paramNonConforme;
			rollback transaction;	-- Libération des tables
		end

		/* Vérification de l'inexistence d'acteur correspondant au rôle. */
		else if exists(select * from Acteur where IdRoleActeur=@pIdRoleActeur)
		begin
			set @oMessage = ' ** Le rôle que vous souhaitez supprimer est utilisé par un ou plusieurs acteurs, par conséquent sa suppression est impossible. ** ';
			set @codeRet = @actionInterdite;
			rollback transaction;	-- Libération des tables
		end

		/* suppression du rôle */
		else
		begin
			/* suppression du rôle */
			delete from RoleActeur where IdRoleActeur = @pIdRoleActeur;

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