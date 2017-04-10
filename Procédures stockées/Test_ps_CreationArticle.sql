/****************************************************************************************
 * Test de la proc�dure ps_CreationArticle *	Auteur : Corentin ROGER�				*
 ****************************************************************************************
 * Cette proc�dure permet de cr�er un nouvel article.									*
 *																						*
 * Rappel des code d'erreur -> Retourne le r�sultat de l'ex�cution de la proc�dure :	*
 *		- 0 : tout s'est bien pass�,													*
 *		- 1 : un param�tre est manquant/vide (= null),									*
 *		- 2 : un param�tre n'est pas conforme (pb valeur/format),						*
 *		- 3 : un �l�ment demand� n'existe pas,											*
 *		- 4 : une action est redondante(d�j� fait, d�j� cr��),							*
 *		- 5 : une action est interdite, impossible (r�gle de gestion),					*
 *		- 9 : probl�me sur la base de donn�es.											*
 ****************************************************************************************/
 /*
 Signature de la proc�dure :
 PROCEDURE ps_CreationArticle(@pLibelleArticle varchar(200), @pPrix float, @pPhotoArticle varchar(200), @pDescriptionArticle text, @pIdGenre int, @pPrixFournisseur float, @pIdFournisseur int, @pReapprovisionnable bit, @oReference int OUTPUT, @oMessage varchar(200) OUTPUT)	
*/

 use Sebo_Carys;
 go

 /* D�clarations */
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
PRINT 'R�sultat attendu = 1; message = ** Le libell� du nouvel article n''a pas �t� fourni. ** ';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le libell� du nouvel article est vide ou ne contient que des espaces. ** ';
set @pLibelleArticle = '';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le libell� du nouvel article est vide ou ne contient que des espaces. ** ';
set @pLibelleArticle = '        ';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 1; message = ** Le prix de l''article n''a pas �t� fourni. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le prix de vente de l''article doit �tre compris entre 0.01� et 100�. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =-1;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le prix de vente de l''article doit �tre compris entre 0.01� et 100�. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =102;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 1; message = ** L''identifiant du genre de l''article n''a pas �t� fourni. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** L''identifiant du genre de l''article doit �tre sup�rieur � 0. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 0;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le prix d''achat de l''article doit �tre compris entre 0.01� et 50�. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = 0.005;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le prix d''achat de l''article doit �tre compris entre 0.01� et 50�. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = 50.01;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 1; message = ** L''identifiant du fournisseur de l''article n''a pas �t� fourni. ** ';
set @pLibelleArticle = 'Les 3 mousquetaires';
set @pPrix =12.5;
set @pIdGenre = 1;
set @pPrixFournisseur = null;
EXECUTE @codeRetour = ps_CreationArticle @pLibelleArticle, @pPrix, @pPhotoArticle, @pDescriptionArticle, @pIdGenre, @pPrixFournisseur, @pIdFournisseur, @pReapprovisionnable, @oReference OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oReference is not null
begin
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** L''identifiant du fournisseur de l''article doit �tre sup�rieur � 0. ** ';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 3; message = ** Le genre fourni n''existe pas dans la base de donn�es. ** ';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 3; message = ** Le fournisseur fourni n''existe pas dans la base de donn�es. ** ';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 4; message = ** Un Article avec le m�me libell�, le m�me genre et le m�me fournisseur existe d�j� dans la base. ** ';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 0; message = OK';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 0; message = OK';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 0; message = OK';
set @pLibelleArticle = 'Les 3 vall�es';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
PRINT 'R�sultat attendu = 0; message = OK';
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
	PRINT 'R�f�rence : ' + cast(@oReference as char(5));
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
