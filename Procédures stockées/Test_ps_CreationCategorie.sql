/****************************************************************************************
 * Test de la procédure ps_CreationCategorie *	Auteur : Corentin ROGERÉ				*
 ****************************************************************************************
 * Cette procédure permet de créer une nouvelle catégorie.								*
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
 PROCEDURE ps_CreationCategorie(@pLibelleCategorie varchar(200), @pTauxTva float, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
*/

 use Sebo_Carys;
 go

 /* Déclarations */
 DECLARE @pLibelleCategorie varchar(200),
		 @pTauxTva float,
		 @oId int,
		 @oMessage varchar(200),
		 @codeRetour int;

PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'Résultat attendu = 1; message = ** Le libellé de la nouvelle catégorie n''a pas été fourni. ** ';
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 2; message = ** Le libellé de la nouvelle catégorie est vide ou ne contient que des espaces. ** ';
set @pLibelleCategorie = '';
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 2; message = ** Le libellé de la nouvelle catégorie est vide ou ne contient que des espaces. ** ';
set @pLibelleCategorie = '        ';
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 1; message = ** Le taux de TVA lié à la catégorie n''a pas été fourni. ** ';
set @pLibelleCategorie = 'BluRay';
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 2; message = ** Le taux de TVA lié à la catégorie doit être compris entre 0.00 et 0.50. ** ';
set @pLibelleCategorie = 'BluRay';
set @pTauxTva =-1;
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 2; message = ** Le taux de TVA lié à la catégorie doit être compris entre 0.00 et 0.50. ** ';
set @pLibelleCategorie = 'BluRay';
set @pTauxTva =0.51;
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 0; message = OK';
set @pLibelleCategorie = 'BluRay';
set @pTauxTva = 0.20;
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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
PRINT 'Résultat attendu = 4; message = ** Il existe déjà une catégorie avec ce même libellé dans la base de données. ** ';
set @pLibelleCategorie = 'BluRay';
set @pTauxTva = 0.20;
EXECUTE @codeRetour = ps_CreationCategorie @pLibelleCategorie, @pTauxTva, @oId OUTPUT, @oMessage OUTPUT;
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