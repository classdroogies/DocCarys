USE master;
GO

ALTER DATABASE Sebo_Carys SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE Sebo_Carys
GO

CREATE DATABASE Sebo_Carys;
GO
/*------------------------------------------------------------
*        Script SQLSERVER 
------------------------------------------------------------*/
USE Sebo_Carys;
GO
/*------------------------------------------------------------
-- Table: Promotion
------------------------------------------------------------*/
CREATE TABLE Promotion(
	IdPromotion INT IDENTITY (1,1) NOT NULL ,
	Remise      INT  NOT NULL ,
	DateDebut   DATETIME NOT NULL ,
	DateFin     DATETIME NOT NULL ,
	CONSTRAINT prk_constraint_Promotion PRIMARY KEY NONCLUSTERED (IdPromotion)
);


/*------------------------------------------------------------
-- Table: Article
------------------------------------------------------------*/
CREATE TABLE Article(
	Reference          INT IDENTITY (1,1) NOT NULL ,
	LibelleArticle     VARCHAR (200) NOT NULL ,
	Prix               FLOAT  NOT NULL ,
	PhotoArticle       VARCHAR (200) DEFAULT 'http://placehold.it/200' ,
	DescriptionArticle TEXT ,
	Reapprovisionnable bit   ,	
	IdStock            INT  ,
	IdGenre            INT  NOT NULL ,
	PrixAchat          FLOAT   ,
	IdFournisseur      INT  NOT NULL ,
	CONSTRAINT prk_constraint_Article PRIMARY KEY NONCLUSTERED (Reference)
);

/*------------------------------------------------------------
-- Table: StockArticle
------------------------------------------------------------*/
CREATE TABLE StockArticle(
	IdStock         INT IDENTITY (1,1) NOT NULL ,
	Quantite        INT  NOT NULL DEFAULT  0,
	QuantiteReserve INT  NOT NULL DEFAULT 0,
	Seuil           INT NOT NULL DEFAULT 0,
	Reference       INT  NOT NULL ,
	CONSTRAINT prk_constraint_StockArticle PRIMARY KEY NONCLUSTERED (IdStock)
);


/*------------------------------------------------------------
-- Table: Genre
------------------------------------------------------------*/
CREATE TABLE Genre(
	IdGenre      INT IDENTITY (1,1) NOT NULL ,
	LibelleGenre VARCHAR (200) NOT NULL ,
	IdCategorie  INT  NOT NULL ,
	CONSTRAINT prk_constraint_Genre PRIMARY KEY NONCLUSTERED (IdGenre),
	CONSTRAINT UK_LibelleGenre UNIQUE(LibelleGenre)
);


/*------------------------------------------------------------
-- Table: Client
------------------------------------------------------------*/
CREATE TABLE Client(
	NumeroClient     INT IDENTITY (1,1) NOT NULL ,
	NomClient        VARCHAR (250) NOT NULL ,
	PrenomClient     VARCHAR (250) NOT NULL ,
	AdresseClient    VARCHAR (250) NOT NULL ,
	CodePostalClient VARCHAR (5) NOT NULL ,
	VilleClient      VARCHAR (250) NOT NULL ,
	EmailClient      VARCHAR (250) NOT NULL ,
	TelephoneClient	 VARCHAR (10) NOT NULL,
	MotDePasseClient VARCHAR (250) NOT NULL ,
	CONSTRAINT prk_constraint_Client PRIMARY KEY NONCLUSTERED (NumeroClient),
	CONSTRAINT UK_EmailClient UNIQUE(EmailClient)
);


/*------------------------------------------------------------
-- Table: RoleActeur
------------------------------------------------------------*/
CREATE TABLE RoleActeur(
	IdRoleActeur      INT IDENTITY (1,1) NOT NULL ,
	LibelleRoleActeur VARCHAR (200) NOT NULL ,
	CONSTRAINT prk_constraint_RoleActeur PRIMARY KEY NONCLUSTERED (IdRoleActeur),
	CONSTRAINT UK_LibelleRoleActeur UNIQUE(LibelleRoleActeur)
);


/*------------------------------------------------------------
-- Table: Categorie
------------------------------------------------------------*/
CREATE TABLE Categorie(
	IdCategorie      INT IDENTITY (1,1) NOT NULL ,
	LibelleCategorie VARCHAR (200) NOT NULL ,
	Tva              FLOAT  NOT NULL ,
	CONSTRAINT prk_constraint_Categorie PRIMARY KEY NONCLUSTERED (IdCategorie),
	CONSTRAINT UK_LibelleCategorie UNIQUE(LibelleCategorie)
);


/*------------------------------------------------------------
-- Table: CommandeFournisseur
------------------------------------------------------------*/
CREATE TABLE CommandeFournisseur(
	NumeroCommandeFournisseur INT IDENTITY (1,1) NOT NULL ,
	DateCommandeFournisseur   DATETIME NOT NULL ,
	IdFournisseur             INT  NOT NULL ,
	CONSTRAINT prk_constraint_CommandeFournisseur PRIMARY KEY NONCLUSTERED (NumeroCommandeFournisseur)
);


/*------------------------------------------------------------
-- Table: Paiement
------------------------------------------------------------*/
CREATE TABLE Paiement(
	IdPaiement   	 INT IDENTITY (1,1) NOT NULL ,
	MontantPaiement  FLOAT  NOT NULL ,
	ModePaiement	 VARCHAR (200) NOT NULL ,
	NumeroCommande   INT  NOT NULL ,
	CONSTRAINT prk_constraint_Paiement PRIMARY KEY NONCLUSTERED (IdPaiement),
	CONSTRAINT UK_ModePaiement UNIQUE(ModePaiement)
);


/*------------------------------------------------------------
-- Table: Livraison
------------------------------------------------------------*/
CREATE TABLE Livraison(
	NumeroLivraison   INT IDENTITY (1,1) NOT NULL ,
	DateLivraison     DATETIME NOT NULL ,
	AccuseReception   bit  NOT NULL ,
	LivraisonComplete bit  NOT NULL ,
	NumeroCommande    INT  NOT NULL ,
	CONSTRAINT prk_constraint_Livraison PRIMARY KEY NONCLUSTERED (NumeroLivraison)
);


/*------------------------------------------------------------
-- Table: Acteur
------------------------------------------------------------*/
CREATE TABLE Acteur(
	IdActeur  INT IDENTITY (1,1) NOT NULL ,
	NomActeur VARCHAR (200) NOT NULL ,
	IdRoleActeur    INT  NOT NULL ,
	CONSTRAINT prk_constraint_Acteur PRIMARY KEY NONCLUSTERED (IdActeur),
	CONSTRAINT UK_NomActeur UNIQUE(NomActeur)
);


/*------------------------------------------------------------
-- Table: PanierCommande
------------------------------------------------------------*/
CREATE TABLE PanierCommande(
	NumeroCommande INT IDENTITY (0,1) NOT NULL ,
	DateCommande   DATETIME NOT NULL ,
	IdEtat         INT  NOT NULL ,
	IdPaiement  	INT,
	NumeroClient   INT NOT NULL,
	CONSTRAINT prk_constraint_PanierCommande PRIMARY KEY NONCLUSTERED (NumeroCommande)
);


/*------------------------------------------------------------
-- Table: Fournisseur
------------------------------------------------------------*/
CREATE TABLE Fournisseur(
	IdFournisseur  INT IDENTITY (1,1) NOT NULL ,
	NomFournisseur VARCHAR (200) NOT NULL ,
	CONSTRAINT prk_constraint_Fournisseur PRIMARY KEY NONCLUSTERED (IdFournisseur),
	CONSTRAINT UK_NomFournisseur UNIQUE(NomFournisseur)
);


/*------------------------------------------------------------
-- Table: Batch
------------------------------------------------------------*/
CREATE TABLE Batch(
	IdBatch    INT IDENTITY (1,1) NOT NULL ,
	HeureBatch DATETIME  NOT NULL ,
	CONSTRAINT prk_constraint_Batch PRIMARY KEY NONCLUSTERED (IdBatch)
);

/*------------------------------------------------------------
-- Table: EtatCommande
------------------------------------------------------------*/
CREATE TABLE EtatCommande(
	IdEtat      INT IDENTITY (1,1) NOT NULL ,
	LibelleEtat VARCHAR (50) NOT NULL ,
	CONSTRAINT prk_constraint_EtatCommande PRIMARY KEY NONCLUSTERED (IdEtat)
);

/*------------------------------------------------------------
-- Table: ActeurArticle
------------------------------------------------------------*/
CREATE TABLE ActeurArticle(
	Reference INT  NOT NULL ,
	IdActeur  INT  NOT NULL ,
	CONSTRAINT prk_constraint_ActeurArticle PRIMARY KEY NONCLUSTERED (Reference,IdActeur)
);


/*------------------------------------------------------------
-- Table: PromotionArticle
------------------------------------------------------------*/
CREATE TABLE PromotionArticle(
	Reference   INT  NOT NULL ,
	IdPromotion INT  NOT NULL ,
	CONSTRAINT prk_constraint_PromotionArticle PRIMARY KEY NONCLUSTERED (Reference,IdPromotion)
);


/*------------------------------------------------------------
-- Table: LigneCommandeFournisseur
------------------------------------------------------------*/
CREATE TABLE LigneCommandeFournisseur(
	QuantiteCommandeFournisseur INT  NOT NULL ,
	PrixUnitaireFournisseur     FLOAT  NOT NULL ,
	NumeroCommandeFournisseur   INT  NOT NULL ,
	Reference                   INT  NOT NULL ,
	CONSTRAINT prk_constraint_LigneCommandeFournisseur PRIMARY KEY NONCLUSTERED (NumeroCommandeFournisseur,Reference)
);


/*------------------------------------------------------------
-- Table: LigneCommande
------------------------------------------------------------*/
CREATE TABLE LigneCommande(
	QuantiteCommande INT  NOT NULL ,
	PrixUnitaire     FLOAT  NOT NULL ,
	NumeroCommande   INT  NOT NULL ,
	Reference        INT  NOT NULL ,
	CONSTRAINT prk_constraint_LigneCommande PRIMARY KEY NONCLUSTERED (NumeroCommande,Reference)
);


/*------------------------------------------------------------
-- Table: LigneLivraison
------------------------------------------------------------*/
CREATE TABLE LigneLivraison(
	QuantiteLivraison INT  NOT NULL ,
	NumeroLivraison   INT  NOT NULL ,
	Reference         INT  NOT NULL ,
	CONSTRAINT prk_constraint_LigneLivraison PRIMARY KEY NONCLUSTERED (NumeroLivraison,Reference)
);



ALTER TABLE Article ADD CONSTRAINT FK_Article_IdGenre FOREIGN KEY (IdGenre) REFERENCES Genre(IdGenre);
ALTER TABLE Article ADD CONSTRAINT FK_Article_IdFournisseur FOREIGN KEY (IdFournisseur) REFERENCES Fournisseur(IdFournisseur);
ALTER TABLE StockArticle ADD CONSTRAINT FK_StockArticle_Reference FOREIGN KEY (Reference) REFERENCES Article(Reference);
ALTER TABLE Genre ADD CONSTRAINT FK_Genre_IdCategorie FOREIGN KEY (IdCategorie) REFERENCES Categorie(IdCategorie);
ALTER TABLE CommandeFournisseur ADD CONSTRAINT FK_CommandeFournisseur_IdFournisseur FOREIGN KEY (IdFournisseur) REFERENCES Fournisseur(IdFournisseur);
ALTER TABLE Paiement ADD CONSTRAINT FK_Paiement_NumeroCommande FOREIGN KEY (NumeroCommande) REFERENCES PanierCommande(NumeroCommande);
ALTER TABLE Livraison ADD CONSTRAINT FK_Livraison_NumeroCommande FOREIGN KEY (NumeroCommande) REFERENCES PanierCommande(NumeroCommande);
ALTER TABLE Acteur ADD CONSTRAINT FK_Acteur_IdRoleActeur FOREIGN KEY (IdRoleActeur) REFERENCES RoleActeur(IdRoleActeur);
ALTER TABLE ActeurArticle ADD CONSTRAINT FK_ActeurArticle_Reference FOREIGN KEY (Reference) REFERENCES Article(Reference);
ALTER TABLE ActeurArticle ADD CONSTRAINT FK_ActeurArticle_IdActeur FOREIGN KEY (IdActeur) REFERENCES Acteur(IdActeur);
ALTER TABLE PanierCommande ADD CONSTRAINT FK_PanierCommande_IdEtat FOREIGN KEY (IdEtat) REFERENCES EtatCommande(IdEtat);
ALTER TABLE PromotionArticle ADD CONSTRAINT FK_PromotionArticle_Reference FOREIGN KEY (Reference) REFERENCES Article(Reference);
ALTER TABLE PromotionArticle ADD CONSTRAINT FK_PromotionArticle_IdPromotion FOREIGN KEY (IdPromotion) REFERENCES Promotion(IdPromotion);
ALTER TABLE LigneCommandeFournisseur ADD CONSTRAINT FK_LigneCommandeFournisseur_NumeroCommandeFournisseur FOREIGN KEY (NumeroCommandeFournisseur) REFERENCES CommandeFournisseur(NumeroCommandeFournisseur);
ALTER TABLE LigneCommandeFournisseur ADD CONSTRAINT FK_LigneCommandeFournisseur_Reference FOREIGN KEY (Reference) REFERENCES Article(Reference);
ALTER TABLE LigneCommande ADD CONSTRAINT FK_LigneCommande_NumeroCommande FOREIGN KEY (NumeroCommande) REFERENCES PanierCommande(NumeroCommande);
ALTER TABLE LigneCommande ADD CONSTRAINT FK_LigneCommande_Reference FOREIGN KEY (Reference) REFERENCES Article(Reference);
ALTER TABLE LigneLivraison ADD CONSTRAINT FK_LigneLivraison_NumeroLivraison FOREIGN KEY (NumeroLivraison) REFERENCES Livraison(NumeroLivraison);
ALTER TABLE LigneLivraison ADD CONSTRAINT FK_LigneLivraison_Reference FOREIGN KEY (Reference) REFERENCES Article(Reference);
GO

-- Script d'insertion
INSERT INTO Categorie VALUES
('Livre', 5.5),
('CD', 20.0),
('DVD', 20.0);
GO

INSERT INTO Genre VALUES
('Littérature', 1),
('Roman', 1),
('Poésie', 1),
('Bande dessinée', 1),
('Jazz', 2),
('Pop-Rock', 2),
('Variété', 2),
('Classique', 2),
('Policier', 3),
('Comédie', 3),
('Action', 3),
('Historique', 3);
GO

INSERT INTO Fournisseur VALUES
('Hachette'),
('Universal'),
('Sony'),
('Mercury'),
('Glénat');
GO

INSERT INTO Article VALUES
('Les 3 mousquetaires', 12, 'kaaris.png', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut consectetur volutpat neque, a cursus nunc iaculis et. In lobortis, ante ullamcorper ultricies eleifend, turpis erat volutpat tellus, non varius lorem metus non turpis. Proin dapibus neque nibh, ut tempor ante eleifend eu. Duis ut arcu ac dolor porttitor pharetra id a erat. Maecenas porttitor condimentum efficitur. Mauris maximus purus sit amet dui molestie dignissim. Quisque lorem erat, interdum at est eu, hendrerit luctus elit.',1, 1, 3, 1, 1),
('Miles Davis', 20, 'kaaris.png', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut consectetur volutpat neque, a cursus nunc iaculis et. In lobortis, ante ullamcorper ultricies eleifend, turpis erat volutpat tellus, non varius lorem metus non turpis. Proin dapibus neque nibh, ut tempor ante eleifend eu. Duis ut arcu ac dolor porttitor pharetra id a erat. Maecenas porttitor condimentum efficitur. Mauris maximus purus sit amet dui molestie dignissim. Quisque lorem erat, interdum at est eu, hendrerit luctus elit.',0, 5, 5, 2, 1),
('Ghostbusters', 25, 'kaaris.png', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut consectetur volutpat neque, a cursus nunc iaculis et. In lobortis, ante ullamcorper ultricies eleifend, turpis erat volutpat tellus, non varius lorem metus non turpis. Proin dapibus neque nibh, ut tempor ante eleifend eu. Duis ut arcu ac dolor porttitor pharetra id a erat. Maecenas porttitor condimentum efficitur. Mauris maximus purus sit amet dui molestie dignissim. Quisque lorem erat, interdum at est eu, hendrerit luctus elit.',1, 10, 10, 4, 1);
GO

INSERT INTO Client VALUES
('TOTO', 'Titi', '5 rue Tata', 38000, 'Grenoble', 'toto@toto.fr', '0102030405', 'toto');
GO

INSERT INTO EtatCommande VALUES
('Panier'),
('En attente de paiement'),
('En attente de réapprovisionement'),
('Paiement validé'),
('Commande terminéé'),
('Commande partielle'),
('En cours de livraison'),
('Livrée');
GO