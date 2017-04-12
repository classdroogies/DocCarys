use Sebo_Carys;
go

create view ArticleSupprimable
--alter view ArticleSupprimable
as
select	Article.Reference,
		count(LigneCommande.QuantiteCommande) + COUNT(LigneCommandeFournisseur.QuantiteCommandeFournisseur) as 'nbUtilisation'
from Article
left join LigneCommande on LigneCommande.Reference = Article.Reference
left join LigneCommandeFournisseur on LigneCommandeFournisseur.Reference = Article.Reference
Group by Article.Reference

go

create view DetailArticle
--alter view DetailArticle
as
select  Article.Reference as 'Référence',
		LibelleArticle as 'Libellé',
		DescriptionArticle as 'Description',
		PhotoArticle as 'Photo',
		Genre.IdCategorie as 'id Catégorie',
		Categorie.LibelleCategorie as 'Catégorie',
		Article.IdGenre as 'id genre',
		Genre.LibelleGenre as 'Genre',
		Article.IdFournisseur as 'id Fournisseur',
		Fournisseur.NomFournisseur as 'Fournisseur',
		Prix as 'Prix de vente',
		PrixAchat as 'Prix d''achat',
		Reapprovisionnable,
		nbUtilisation

from Article
left join Genre on Genre.IdGenre = Article.IdGenre
left join Categorie on Categorie.IdCategorie = Genre.IdCategorie
left join Fournisseur on Fournisseur.IdFournisseur = Article.IdFournisseur
join ArticleSupprimable on ArticleSupprimable.Reference = Article.Reference;
Go
