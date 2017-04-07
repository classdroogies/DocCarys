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