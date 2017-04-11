use Sebo_Carys;
Go

CREATE VIEW DetailGenre
--ALTER VIEW DetailGenre
as
select  Genre.IdGenre as 'Id',
		LibelleGenre,
		LibelleCategorie as 'Catégorie',
		COUNT(Article.IdGenre) as 'Cas d''emploi',
		Genre.IdCategorie as 'IdCategorie'
from Genre
left join Article on Article.IdGenre = Genre.IdGenre
left join Categorie on Categorie.IdCategorie = Genre.IdCategorie
group by Genre.IdGenre, LibelleGenre, LibelleCategorie, Genre.IdCategorie;