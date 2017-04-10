/****************************************************************************************
 * Test de la procédure ps_CreationGenre *	Auteur : Corentin ROGERÉ					*
 ****************************************************************************************
 * Cette procédure permet de créer un nouveau genre.									*
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
 PROCEDURE ps_CreationGenre(@pLibelleGenre varchar(200), @pIdCategorie int, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
*/

 use Sebo_Carys;
 go

 /* Déclarations */
 DECLARE @pLibelleGenre varchar(200),
		 @pIdCategorie int,
		 @oId int,
		 @oMessage varchar(200),
		 @codeRetour int;

PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 1; message = ** Le libellé du nouveau genre n''a pas été fourni. ** ';
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
PRINT 'Résultat attendu = 2; message = ** Le libellé du nouveau genre est vide ou ne contient que des espaces. ** ';
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
PRINT 'Résultat attendu = 2; message = ** Le libellé du nouveau genre est vide ou ne contient que des espaces. ** ';
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
PRINT 'Résultat attendu = 1; message = ** L''identifiant de la catégorie n''a pas été fourni. ** ';
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
PRINT 'Résultat attendu = 2; message = ** L''identifiant de la catégorie doit être supérieur à 0. ** ';
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
PRINT 'Résultat attendu = 3; message = ** L''identifiant de la catégorie associée n''existe pas dans la base de données. ** ';
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
PRINT 'Résultat attendu = 0; message = OK';
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
PRINT 'Résultat attendu = 4; message = ** Il existe déjà un genre avec le même libellé. ** ';
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