use Sebo_Carys;
go

select  Article.Reference as 'Référence',
		Article.LibelleArticle as 'Libellé',
		Genre.LibelleGenre as 'Genre',
		LibelleCategorie as 'Catégorie',
		NomFournisseur as 'Fournisseur',
		Reapprovisionnable as 'Actif',
		count(LigneCommande.QuantiteCommande) + count (LigneCommandeFournisseur.QuantiteCommandeFournisseur) + count (StockArticle.Quantite) as 'cas d''emploi'
from Article
full join LigneCommande on LigneCommande.Reference = Article.Reference
full join LigneCommandeFournisseur on LigneCommandeFournisseur.Reference = Article.Reference
full join StockArticle on StockArticle.Reference = Article.Reference
join Genre on Genre.IdGenre = Article.IdGenre
join Categorie on Categorie.IdCategorie = Genre.IdCategorie
join Fournisseur on Fournisseur.IdFournisseur = Article.IdFournisseur
group by Article.Reference, LibelleArticle, LibelleGenre, Libellecategorie, NomFournisseur, Reapprovisionnable