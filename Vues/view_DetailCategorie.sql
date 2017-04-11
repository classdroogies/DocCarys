use Sebo_Carys;
go

CREATE VIEW DetailCategorie
--ALTER VIEW DetailCategorie
as
select  Categorie.IdCategorie as 'Id cat',
		Categorie.LibelleCategorie as 'Libellé',
		Categorie.Tva as 'Tva',
		count(Genre.IdCategorie) as 'nb utilisations'
from Categorie
full join Genre on Genre.IdCategorie = Categorie.IdCategorie
group by Categorie.IdCategorie, Libellecategorie, Categorie.Tva