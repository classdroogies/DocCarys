use master
go


use Sebo_Carys
IF OBJECT_ID ('fn_CleanString') IS NOT NULL DROP FUNCTION fn_CleanString
go

CREATE FUNCTION fn_CleanString (@pChaineBrute varchar(254))
								RETURNS varchar(254)
 /***************************************************************************************
 * Proc�dure fn_CleanString *	Auteur : Anthony ORGER									*
 ****************************************************************************************
 * Cette fonction renvoie une chaine d�barrass�e de ses caract�res non imprimables. 	*
 *																						*
 * Param�tres :																			*
 *		- @pChaineBrute : l'id de cat�gorie donn�e en param�tre							*
 *																						*
 * Retourne la chaine nettoy�e															*
 ****************************************************************************************/
AS
BEGIN
	-- D�claration des variables --
	DECLARE	 @oChaineNette	varchar(254);	-- la chaine � renvoyer

	-- �limination cibl�e, code � code -- 
	-- suppression des espaces		
	SET @oChaineNette = LTRIM(RTRIM(@pChaineBrute))

	-- suppression des caract�res de tabulation. �quivalents � \t , \x09 et \cI.
	SET @oChaineNette = REPLACE(@oChaineNette,char(9),'')

	-- suppression des caract�res de saut de ligne. �quivalents � \n , \x0a et \cJ
	SET @oChaineNette = REPLACE(@oChaineNette,char(10),'')

	-- suppression des caract�res de tabulation verticale. �quivalents � \v , \x0b et \cK.
	SET @oChaineNette = REPLACE(@oChaineNette,char(11),'')

	-- suppression des caract�res de saut de page. �quivalents � \f , \x0c et \cL
	SET @oChaineNette = REPLACE(@oChaineNette,char(12),'')

	-- suppression des caract�res de retour chariot �quivalents � \r ,  \x0d et \cM
	SET @oChaineNette = REPLACE(@oChaineNette,char(13),'')
		
	/* retour du r�sultat de la fonction */
	return @oChaineNette
END
go