/****************************************************************************************
 * Test de la procédure ps_CreationArticle *	Auteur : Corentin ROGERÉ				*
 ****************************************************************************************
 * Cette procédure permet de créer un nouvel article.									*
 *																						*
 * Rappel des code d'erreur -> Retourne le résultat de l'exécution de la procédure :	*
 *		- 0 : tout s'est bien passé,													*
 *		- 1 : un paramètre est manquant/vide (= null),									*
 *		- 2 : un paramètre n'est pas conforme (pb valeur/format),						*
 *		- 3 : un élément demandé n'existe pas,											*
 *		- 4 : une action est redondante(déjà fait, déjà créé),							*
 *		- 5 : une action est interdite, impossible (règle de gestion),					*
 *		- 9 : problème sur la base de données.											*
 ****************************************************************************************/
 /*
 Signature de la procédure :
 PROCEDURE ps_CreationArticle(@pLibelleArticle varchar(200), @pPrix float, @pPhotoArticle varchar(200), @pDescriptionArticle text, @pIdGenre int, @pPrixFournisseur float, @pIdFournisseur int, @pReapprovisionnable bit, @oReference int OUTPUT, @oMessage varchar(200) OUTPUT)	
*/

 use Sebo_Carys;
 go

 /* Déclarations */
 DECLARE @pLibelleArticle varchar(200),
		 @pPrix float,
		 @pPhotoArticle varchar(200),
		 @pDescriptionArticle varchar(2000),
		 @pIdGenre int,
		 @pPrixFournisseur float,
		 @pIdFournisseur int,
		 @pReapprovisionnable bit,
		 @oReference int,
		 @oMessage varchar(200),
		 @codeRetour int;

PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 1; message = ** Le libellé du nouvel article n''a pas été fourni. ** ';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=1
begin
	PRINT ' ++ OK ++';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** Le libellé du nouvel article est vide ou ne contient que des espaces. ** ';
set @pLibelleArticle = '';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** Le libellé du nouvel article est vide ou ne contient que des espaces. ** ';
set @pLibelleArticle = '        ';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 1; message = ** Le prix de l''article n''a pas été fourni. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=1
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** Le prix de vente de l''article doit être compris entre 0.01€ et 100€. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =-1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** Le prix de vente de l''article doit être compris entre 0.01€ et 100€. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =102;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 1; message = ** L''identifiant du genre de l''article n''a pas été fourni. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=1
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** L''identifiant du genre de l''article doit être supérieur à 0. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 0;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** Le prix d''achat de l''article doit être compris entre 0.01€ et 50€. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = 0.005;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** Le prix d''achat de l''article doit être compris entre 0.01€ et 50€. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = 50.01;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 1; message = ** L''identifiant du fournisseur de l''article n''a pas été fourni. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = null;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=1
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 2; message = ** L''identifiant du fournisseur de l''article doit être supérieur à 0. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = null;
set @pIdFournisseur = 0;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=2
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 3; message = ** Le genre fourni n''existe pas dans la base de données. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 123;
set @pPrixFournisseur = null;
set @pIdFournisseur = 1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=3
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 3; message = ** Le fournisseur fourni n''existe pas dans la base de données. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = null;
set @pIdFournisseur = 123;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=3
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 4; message = ** Un Article avec le même libellé, le même genre et le même fournisseur existe déjà dans la base. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = null;
set @pIdFournisseur = 1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=4
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 0; message = OK';
set @pLibelleArticle = 'Les 3 petits cochons';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = null;
set @pIdFournisseur = 1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=0
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 0; message = OK';
set @pLibelleArticle = 'Les 3 cloches';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = 2;
set @pIdFournisseur = 1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=0
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 0; message = OK';
set @pLibelleArticle = 'Les 3 vallées';
set @pPrix =12.5;
set @pPhotoArticle = 'kaaris.png';
set @pIdGenre = 1;
set @pPrixFournisseur = 5;
set @pIdFournisseur = 1;
set @pReapprovisionnable = 1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=0
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'


/*-----------------*/


PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 0; message = OK';
set @pLibelleArticle = 'Les 3 soleils';
set @pPrix =12.5;
set @pPhotoArticle = 'kaaris.png';
set @pIdGenre = 1;
set @pPrixFournisseur = 5;
set @pIdFournisseur = 1;
set @pReapprovisionnable = 0;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'Référence : ' + cast(@oReference as char(5));
end
if @codeRetour=0
begin
	PRINT ' ++ OK ++ ';
end
else
begin
	PRINT 'XXXXXX';
end
PRINT '';
PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
