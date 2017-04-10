/****************************************************************************************
 * Test de la proc�dure ps_CreationCategorie *	Auteur : Corentin ROGER�				*
 ****************************************************************************************
 * Cette proc�dure permet de cr�er une nouvelle cat�gorie.								*
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
 PROCEDURE ps_CreationCategorie(@pLibelleCategorie varchar(200), @pTauxTva float, @oId int OUTPUT, @oMessage varchar(200) OUTPUT)
*/

 use Sebo_Carys;
 go

 /* D�clarations */
 DECLARE @pLibelleCategorie varchar(200),
		 @pTauxTva float,
		 @oId int,
		 @oMessage varchar(200),
		 @codeRetour int;

PRINT '----------------------------------------------------------------------------------------------------------------------------------------------------------'
PRINT '';
PRINT 'R�sultat attendu = 1; message = ** Le libell� de la nouvelle cat�gorie n''a pas �t� fourni. ** ';
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
PRINT 'R�sultat attendu = 2; message = ** Le libell� de la nouvelle cat�gorie est vide ou ne contient que des espaces. ** ';
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
PRINT 'R�sultat attendu = 2; message = ** Le libell� de la nouvelle cat�gorie est vide ou ne contient que des espaces. ** ';
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
PRINT 'R�sultat attendu = 1; message = ** Le taux de TVA li� � la cat�gorie n''a pas �t� fourni. ** ';
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
PRINT 'R�sultat attendu = 2; message = ** Le taux de TVA li� � la cat�gorie doit �tre compris entre 0.00 et 0.50. ** ';
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
PRINT 'R�sultat attendu = 2; message = ** Le taux de TVA li� � la cat�gorie doit �tre compris entre 0.00 et 0.50. ** ';
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
PRINT 'R�sultat attendu = 0; message = OK';
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
PRINT 'R�sultat attendu = 4; message = ** Il existe d�j� une cat�gorie avec ce m�me libell� dans la base de donn�es. ** ';
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