/****************************************************************************************
 * Test de la proc�dure ps_CreationGenre *	Auteur : Corentin ROGER�					*
 ****************************************************************************************
 * Cette proc�dure permet de cr�er un nouveau genre.									*
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
 PROCEDURE ps_CreationGenre(@pLibelleGenre varchar(200), @pIdCategorie int, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
*/

 use Sebo_Carys;
 go

 /* D�clarations */
 DECLARE @pLibelleGenre varchar(200),
		 @pIdCategorie int,
		 @oId int,
		 @oMessage varchar(200),
		 @codeRetour int;

PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'R�sultat attendu = 1; message = ** Le libell� du nouveau genre n''a pas �t� fourni. ** ';
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le libell� du nouveau genre est vide ou ne contient que des espaces. ** ';
set @pLibelleGenre = '';
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** Le libell� du nouveau genre est vide ou ne contient que des espaces. ** ';
set @pLibelleGenre = '        ';
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 1; message = ** L''identifiant de la cat�gorie n''a pas �t� fourni. ** ';
set @pLibelleGenre = 'Nouvelles';
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 2; message = ** L''identifiant de la cat�gorie doit �tre sup�rieur � 0. ** ';
set @pLibelleGenre = 'Nouvelles';
set @pIdCategorie =-1;
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 3; message = ** L''identifiant de la cat�gorie associ�e n''existe pas dans la base de donn�es. ** ';
set @pLibelleGenre = 'Nouvelles';
set @pIdCategorie =36974;
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 0; message = OK';
set @pLibelleGenre = 'Nouvelles';
set @pIdCategorie = 1;
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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
PRINT 'R�sultat attendu = 4; message = ** Il existe d�j� un genre avec le m�me libell�. ** ';
set @pLibelleGenre = 'Nouvelles';
set @pIdCategorie = 1;
set @oId = null;
EXECUTE @codeRetour = ps_CreationGenre @pLibelleGenre, @pIdCategorie, @oId OUTPUT, @oMessage OUTPUT;
PRINT 'Code retour : ' + cast(@codeRetour as char(1));
PRINT 'Message : ' + @oMessage;
IF @oId is not null
begin
	PRINT 'Id : ' + cast(@oId as char(5));
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