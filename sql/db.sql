/*
Base de Dados 2021
Diogo Oliveira Ribeiro 201707434

BD para associação de estudantes.
Ficheiro SQL e insercao de alguns dados.
*/

CREATE DATABASE IF NOT EXISTS ASSOCIACAO_ESTUDANTES;

USE ASSOCIACAO_ESTUDANTES;


DROP TABLE IF EXISTS ESTUDANTE,DEPARTAMENTO,EVENTO,REUNIAO,PUBLICACAO,
MEMBRO,PRESIDENTE,ORGANIZADOR,ORADOR,CONVOCADOR,REUNIDOS,ASSUNTO,CONCLUSOES;

CREATE TABLE ESTUDANTE(
   Id INT PRIMARY KEY AUTO_INCREMENT,
   Nome VARCHAR(128) NOT NULL,
   Sexo ENUM('M','F') NOT NULL,
   Nascimento DATE NOT NULL,
   Adesao DATETIME DEFAULT NOW(),
   CursoNome VARCHAR(128) NOT NULL,
   CursoAno INT NOT NULL,
   Telemovel INT DEFAULT NULL,
   Mentor INT DEFAULT NULL,
   FOREIGN KEY(Mentor) REFERENCES ESTUDANTE(Id)
);

CREATE TABLE DEPARTAMENTO(
   Id INT PRIMARY KEY AUTO_INCREMENT,
   Nome VARCHAR(128) UNIQUE NOT NULL
);

CREATE TABLE EVENTO(
   Id INT PRIMARY KEY AUTO_INCREMENT,
   Nome VARCHAR(128) NOT NULL,
   Inicio DATETIME NOT NULL,
   Fim DATETIME NOT NULL,
   Descricao TEXT NOT NULL,
   Local VARCHAR(128) NOT NULL
);

CREATE TABLE REUNIAO(
   Id INT PRIMARY KEY AUTO_INCREMENT,
   Geral ENUM('S','N') NOT NULL DEFAULT 'N',
   Inicio DATETIME NOT NULL,
   Fim DATETIME NOT NULL
);

CREATE TABLE PUBLICACAO(
   Evento INT NOT NULL,
   Imagem VARCHAR(32) NOT NULL,
   Descricao TEXT NOT NULL,
   Data DATETIME NOT NULL,
   PRIMARY KEY(Evento),
   FOREIGN KEY(Evento) REFERENCES EVENTO(Id) ON DELETE CASCADE
);

CREATE TABLE MEMBRO( /*Associa estudantes aos seus departamentos*/
	Estudante INT NOT NULL,
	Departamento INT NOT NULL,
	PRIMARY KEY(Estudante,Departamento),
	FOREIGN KEY(Estudante) REFERENCES ESTUDANTE(Id),
	FOREIGN KEY(Departamento) REFERENCES DEPARTAMENTO(Id)
);

CREATE TABLE PRESIDENTE( /*Os presidentes de cada departamento*/
   Presidente INT NOT NULL,
   Departamento INT NOT NULL,
   Mandato INT NOT NULL,
   PRIMARY KEY(Presidente,Departamento),
   FOREIGN KEY(Presidente) REFERENCES ESTUDANTE(Id),
   FOREIGN KEY(Departamento) REFERENCES DEPARTAMENTO(Id)
);

CREATE TABLE ORGANIZADOR( /*Departamento que organizou cada evento*/
   Evento INT NOT NULL,
   Departamento INT NOT NULL,
   PRIMARY KEY(Evento,Departamento),
   FOREIGN KEY(Evento) REFERENCES EVENTO(Id) ON DELETE CASCADE,
   FOREIGN KEY(Departamento) REFERENCES DEPARTAMENTO(Id)
);

CREATE TABLE ORADOR( /*Oradores dos eventos*/
   Evento INT NOT NULL AUTO_INCREMENT,
   Nome VARCHAR(128) NOT NULL,
   PRIMARY KEY(Evento,Nome),
   FOREIGN KEY(Evento) REFERENCES EVENTO(Id) ON DELETE CASCADE
);

CREATE TABLE CONVOCADOR( /*Departamento que convocou cada reuniao*/
   Reuniao INT NOT NULL,
   Departamento INT NOT NULL,
   PRIMARY KEY(Reuniao,Departamento),
   FOREIGN KEY(Reuniao) REFERENCES REUNIAO(Id),
   FOREIGN KEY(Departamento) REFERENCES DEPARTAMENTO(Id)
);

CREATE TABLE REUNIDOS( /*Membros foram a cada reuniao*/
   Reuniao INT NOT NULL,
   Participante INT NOT NULL,
   PRIMARY KEY(Reuniao,Participante),
   FOREIGN KEY(Reuniao) REFERENCES REUNIAO(Id),
   FOREIGN KEY(Participante) REFERENCES ESTUDANTE(Id)
);

CREATE TABLE ASSUNTO( /*Assuntos foram discutidos nas reunioes*/
   Reuniao INT NOT NULL,
   Assunto VARCHAR(64) NOT NULL,
   PRIMARY KEY(Reuniao,Assunto),
   FOREIGN KEY(Reuniao) REFERENCES REUNIAO(Id)
);

CREATE TABLE CONCLUSOES( /*Que conclusoes foram tiradas nas reunioes*/
   Reuniao INT NOT NULL,
   Conclusao VARCHAR(128) NOT NULL,
   PRIMARY KEY(Reuniao,Conclusao),
   FOREIGN KEY(Reuniao) REFERENCES REUNIAO(Id)
);

/*
Insercao de dados
*/

INSERT INTO DEPARTAMENTO(Nome)
VALUES
   ('Administrativo'),('Divulgacao'),('Educacional'),('Ludico');

INSERT INTO ESTUDANTE(Nome,Sexo,Nascimento,Adesao,CursoNome,CursoAno,Telemovel)
VALUES
   ('Luiza Marinho Telmo','F','1997-07-27','2017-09-17 14:03:21','Ciencia de Dinossauros',5,973400985),
   ('Telmo Arnaldo Sabina','M','1998-09-16','2017-09-17 14:04:09','Engenharia de Esparguete',4,960703386),
   ('Xande Rafaela Toninho','M','1998-11-06','2017-11-25 10:31:51','Ciencia de Dinossauros',4,930512785),
   ('Rosana Luciano Tiago','F','1998-04-25','2018-01-04 18:05:43','Engenharia de Esparguete',3,975307106),
   ('Jeremias Gui Carlito','M','1997-03-09','2018-01-14 18:06:26','Labirintos para Ratos',2,960310499);

INSERT INTO ESTUDANTE(Nome,Sexo,Nascimento,Adesao,CursoNome,CursoAno,Mentor)
VALUES
   ('Albino Iria Aurora','M','1999-06-27','2018-02-26 15:31:17','Labirintos para Ratos',2,5),
   ('Salvador Paulino Machado','M','1999-05-11','2018-02-27 14:01:31','Ciencia de Dinossauros',3,1),
   ('Delfina Susana Ariana','F','1998-02-11','2019-09-18 11:21:06','Engenharia de Esparguete',2,4);

INSERT INTO ESTUDANTE(Nome,Sexo,Nascimento,Adesao,CursoNome,CursoAno,Telemovel,Mentor)
VALUES
   ('Maria Raimundo Larissa','F','1997-08-24','2019-09-18 12:11:21','Engenharia de Esparguete',2,904182642,4),
   ('Feliciano Vera Antonio','M','2000-05-14','2019-10-11 15:36:55','Ciencia de Dinossauros',2,939712057,7);

INSERT INTO ESTUDANTE(Nome,Sexo,Nascimento,Adesao,CursoNome,CursoAno,Telemovel)
VALUES
   ('Maria Raimundo Larissa','F','2001-11-30','2019-12-13 10:21:49','Arqueologia de Botas',3,906518741),
   ('Vitorino Eliseu Elisabete','M','2002-10-05','2020-02-17 09:45:29','Labirintos para Ratos',2,976017812),
   ('Marquinhos Nicodemo Luiza','M','2001-07-12','2021-09-20 16:15:56','Arqueologia de Botas',1,939050234);

INSERT INTO ESTUDANTE(Nome,Sexo,Nascimento,Adesao,CursoNome,CursoAno,Telemovel,Mentor)
VALUES
   ('Cezar Zacarias Matias','M','1999-06-23','2021-10-04 18:06:04','Ciencia de Dinossauros',1,912385421,7),
   ('Josefina Irene Amanda','F','2002-01-31','2021-10-04 18:06:45','Engenharia de Esparguete',1,912345678,9);

INSERT INTO MEMBRO(Estudante,Departamento)
VALUES
   (1,1),(1,2),(2,2),(2,4),(3,2),(4,1),(4,3),(5,3),(6,4),(6,1),(7,3),
   (7,4),(8,1),(9,4),(9,2),(10,1),(11,4),(11,3),(12,3),(13,2),(14,4),(15,2);

INSERT INTO PRESIDENTE(Presidente,Departamento,Mandato)
VALUES
   (4,1,3),(9,2,1),(12,3,1),(6,4,2);

INSERT INTO REUNIAO(Geral,Inicio,Fim)
VALUES
   ('S','2018-03-10 21:30:00','2018-03-10 23:12:07'),
   ('N','2018-03-14 21:30:00','2018-03-14 22:32:14'),
   ('N','2019-03-16 22:00:00','2019-03-17 00:13:21'),
   ('S','2019-05-19 21:30:00','2019-05-19 22:46:31'),
   ('N','2020-10-15 18:00:00','2020-10-15 19:13:56');

INSERT INTO CONVOCADOR(Reuniao,Departamento)
VALUES
   (1,1),(2,2),(3,4),(4,1),(5,3);

INSERT INTO ASSUNTO(Reuniao,Assunto)
VALUES
   (1,'Direcao da Associacao'),(1,'Objetivos e obstaculos'),
   (2,'Workshops'),(2,'Contactar oradores'),(2,'Computadores'),
   (3,'Definir Templates'),(3,'Questoes legais'),
   (4,'Organizacao da sala da Associacao'),(4,'Acessos nao autorizados'),
   (5,'Parcerias com bares e discotecas');

INSERT INTO CONCLUSOES(Reuniao,Conclusao)
VALUES
   (1,'Estamos num bom caminho.'),
   (2,'Java e C serão as línguas abordadas nos workshops'),
   (2,'E preciso continuar a negociar acesso a computadores'),
   (3,'Falta definir template para eventos recreativos'),
   (4,'Serao implementadas mais restricoes no acesso a sala e a cloud'),
   (5,'A discoteca "Eskadas para o lado" oferece bons preços para eventos');

INSERT INTO REUNIDOS(Reuniao,Participante)
VALUES
   (1,1),(1,3),(1,4),(1,5),(1,6),(1,7),(2,1),(2,3),(3,4),(3,5),
   (3,7),(4,2),(4,3),(4,5),(4,6),(4,7),(5,2),(5,7),(5,9);

INSERT INTO EVENTO(Nome,Inicio,Fim,Descricao,Local)
VALUES
   ('Jantar de boas-vindas','2020-10-01 20:00:00','2020-10-01 23:00:00',
   'Primeiro jantar do ano para dar as boas-vindas aos novos alunos.','Capas Brancas'),
   ('Workshop de JAVA','2020-11-18 18:00:00','2020-11-18 20:00:00',
   'Pequena sessão de conceitos basicos e boas praticas da linguagem JAVA.','DCC/FCUP'),
   ('Workshop de Git','2021-03-05 18:00:00','2021-03-05 20:00:00',
   'Pequena sessão de introdução ao uso de Git.','DCC/FCUP'),
   ('Torneio de League of Legends','2021-05-13 15:00:00','2021-05-13 20:00:00',
   'Pequeno torneio de League of Legends. Maximo de 8 equipas, compostas por estudantes da UP.','Discord da AE'),
   ('Jantar de boas-vindas','2021-09-28 20:30:00','2021-09-28 23:30:00',
   'Jantar de boas-vindas aos novos alunos','Capas Brancas'),
   ('Constroi um computador','2021-11-14 18:00:00','2021-11-14 20:00:00',
   'Dar a conhecer os diferentes componentes de um computador e como os montar.','DCC/FCUP'),
   ('Torneio de caça aos gambuzinos','2021-12-21 21:12:21','2021-12-22 00:00:00',
   'Primeira edicao deste novo desporto cada vez mais popular.','Jardins da Cordoaria');

INSERT INTO ORGANIZADOR(Evento,Departamento)
VALUES
   (1,4),(2,3),(3,3),(4,4),(5,4),(6,3),(7,4);

INSERT INTO ORADOR(Evento,Nome)
VALUES
   (1,'Quim Barreiros'),(2,'Pedro Ribeiro'),(2,'James Gosling'),(3,'Linus Torvalds'),(4,'RiotPhreak');

INSERT INTO PUBLICACAO(Evento,Imagem,Descricao,Data)
VALUES
   (1,'cartaz_jantar.png','Sabemos que pode ser dificil quebrar o gelo num novo ambiente.
   Por isso organizamos este jantar para te dar as boas vindas a esta nova etapa da tua vida e para conheceres os teus novos colegas.','2020-09-22 23:15:16'),
   (2,'wsJAVA.png','Se te sentes um pouco perdido a programar em JAVA ou apenas queres reforcar os teus conhecimentos e aprender boas praticas entao aparece no DCC dia 18 de novembro pelas 18 horas.','2020-11-12 12:35:51'),
   (3,'wsGit.jpg','Git e um sistema de controlo de versoes usado para manter backups de software, desenvolver software com outros programadores e outras funcionalidades.
   Nos vamos dar-te uma introducao! Dia 25 de fevereiro pelas 18 horas, no DCC.','2021-02-25 18:25:36'),
   (4,'torneio_lol.png','Chamando todos os jogadores de LoL da UP. Sim, ate voces Teemo mains! Reunam a vossa equipa e habilitem-se a ganhar alguns Riot Points!
   Maximo de 8 equipas, cada equipa precisa de um minimo de 5 jogadores e um maximo de 10.','2021-05-02 19:17:15'),
   (5,'jantar_boas_vindas.png','Para começar o ano em grande nada melhor que um jantar para conheceres melhor os teus novos colegas. So precisas de trazer boa disposicao!','2021-09-20 16:00:14'),
   (6,'constroi_computador.jpeg','Se gostarias de preceber melhor como funcionam os diferentes componentes de um computador entao isto e para ti.
   Poderas desmontar e montar e voltar a desmontar as vezes que forem necessarias. Vemo-nos dia 14 pelas 18 horas.','2021-11-10 19:04:11'),
   (7,'gambuzinos.png','Es o melhor apanhador de gambuzinos? Prova-nos no proximo sabado. Tenta aparecer com alguma antecedencia. Boa sorte!','2021-12-19 00:10:41');