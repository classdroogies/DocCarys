SET IDENTITY_INSERT [dbo].[Article] ON
INSERT INTO [dbo].[Article] ([Reference], [LibelleArticle], [Prix], [IdGenre], [PrixFournisseur], [IdFournisseur]) VALUES (1, N'Les 3 mousquetaires', 12, 1, 3, 1)
INSERT INTO [dbo].[Article] ([Reference], [LibelleArticle], [Prix], [IdGenre], [PrixFournisseur], [IdFournisseur]) VALUES (2, N'Miles Davis', 20, 2, 5, 2)
INSERT INTO [dbo].[Article] ([Reference], [LibelleArticle], [Prix], [IdGenre], [PrixFournisseur], [IdFournisseur]) VALUES (3, N'GhostBuster', 25, 3, 10, 4)
SET IDENTITY_INSERT [dbo].[Article] OFF
