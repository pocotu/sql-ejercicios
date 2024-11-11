-- Crear la base de datos
Create DATABASE DBCreditoRural1  -- Creates the Credito_Rural DataBase
on
  (NAME = DBCreditoRural1,    -- Primary data file
  FILENAME = 'D:\Base de datos\BD\file\DBCreditoRural1.mdf',
  SIZE = 5MB,
  FILEGROWTH = 1MB
  )
  LOG ON
  (NAME = DBCreditoRural1_Log,   -- Log file
  FILENAME = 'D:\Base de datos\BD\file\DBCreditoRural1.ldf',
  SIZE = 4MB,
  FILEGROWTH = 1MB
  )
go

---------------------------------------------------------------
/* Activar Base de datos: DBCreditoRural */
use DBCreditoRural1
go
/* Crear los tipos */

exec sp_addtype TCodPrestatario, "varchar(8)","NOT NULL"
go

exec sp_addtype TDocPrestamo, "varchar(12)","NOT NULL"
go

exec sp_addtype TDocCancelacion, "varchar(12)","NOT NULL"
go


/* Activar la Base de datos DBCreditoRural */
use DBCreditoRural1
go

/* Crear las tablas */

create table Prestatario_Rural(
  CodPrestatario   TCodPrestatario NOT NULL,
  Nombres          varchar(40),
  Comunidad        varchar(40),
  LimitePrestamo   numeric(15,2),
  PRIMARY KEY (CodPrestatario)
 )
 go

create table Prestatario_Ciudad(
  CodPrestatario   TCodPrestatario NOT NULL,
  Nombres          varchar(40),
  Direccion        varchar(40),
  Telefono         varchar(9),
  LimitePrestamo   numeric(15,2),
  PRIMARY KEY (CodPrestatario)
 )
 go

create table Prestamo(
  DocPrestamo       TDocPrestamo NOT NULL,
  FechaPrestamo     datetime,
  ImportePrestamo   numeric(15,2) check(ImportePrestamo > 0),
  FechaVcto         datetime,
  CodPrestatario   TCodPrestatario NOT NULL,
  PRIMARY KEY (DocPrestamo)
 )
 go

create table Cancelacion(
  DocCancelacion     TDocCancelacion NOT NULL,
  FechaCancelacion   datetime,
  ImporteCancelacion numeric(15,2) check(ImporteCancelacion > 0),
  DocPrestamo        TDocPrestamo NOT NULL,
  PRIMARY KEY (DocCancelacion),
  FOREIGN KEY (DocPrestamo) REFERENCES Prestamo
 )
 go

create table Historico(
  NroOperacion     int Identity(1,1),
  Usuario          varchar(40),
  Fecha            datetime,  
  Tabla            varchar(20),
  Operacion        varchar(6), 
  Observaciones    varchar(40),
  PRIMARY KEY (NroOperacion)
 )
 go
---------------------------------------------------------------
/* Activar Base de datos: DBCreditoRural */
use DBCreditoRural1
go

/* Insertar Datos de Prestatarios Rural */ 

INSERT INTO Prestatario_Rural
  values ('P01','Lopez Caceres Jose Antonio','Poroy',2500);

INSERT INTO Prestatario_Rural
  values ('P02','Delgado Caceres Ana Maria','Ccorca',1800);

INSERT INTO Prestatario_Rural
  values ('P03','Candia Calderon Maria','Poroy',3000); 

/* Insertar Datos de Prestatarios Ciudad */ 

INSERT INTO Prestatario_Ciudad
  values ('P04','Paz CCuno Eva','Av. Cusco 324','234567',5000);

INSERT INTO Prestatario_Ciudad
  values ('P05','Pezo Meza Pedro','Av. SOl 345','248123',6000);

INSERT INTO Prestatario_Ciudad
  values ('P06','Bueno Guerra Mónica','Av. Perú','240213',4500);

INSERT INTO Prestatario_Ciudad
  values ('P07','Luza Gudiel Ricardo','Jr. Tacna','240608',6200);

/* Insertar Datos de Prestamos */ 

INSERT INTO Prestamo 
  	  values ('PA-10001','01/02/2004',1500.00,'05/02/2004','P01');

INSERT INTO Prestamo 
      values ('PR10002','01/10/2004',4500.00,'06/10/2004','P03');

INSERT INTO Prestamo 
      values ('PR10003','01/24/2004',3000.00,'08/11/2004','P01');

INSERT INTO Prestamo 
      values ('PR10004','03/23/2004',5000.00,'10/15/2004','P02');

INSERT INTO Prestamo 
  	  values ('PR10005','04/12/2004',500.00,'05/30/2004','P04');

INSERT INTO Prestamo 
      values ('PR10006','05/11/2004',2400.00,'06/10/2004','P05');

INSERT INTO Prestamo 
      values ('PR10007','06/20/2004',3200.00,'08/11/2004','P07');

INSERT INTO Prestamo 
      values ('PR10008','07/16/2004',450.00,'10/15/2004','P06');

/* Insertar Datos de Cancelaciones */ 

INSERT INTO Cancelacion
      values ('RC-0013','03/03/2004',500.00,'PA-10001');

INSERT INTO Cancelacion
      values ('RC-0242','05/04/2004',600.00,'PA-10001');

INSERT INTO Cancelacion
      values ('RC-0256','03/10/2004',1000.00,'PR10002');

INSERT INTO Cancelacion
      values ('RC-0294','04/02/2004',1500.00,'PR10004');

INSERT INTO Cancelacion
      values ('RC-0324','05/03/2004',400.00,'PR10005');
---------------------------------------------------------------