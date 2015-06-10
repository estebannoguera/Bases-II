create database ProyectoRios;
USE ProyectoRios;

---tablas proyecto bases II.

create table Rios ( 
id int  identity (1,1),
nombre varchar(30),
geometria geometry check (geometria.STGeometryType() = 'Line') not null,
constraint PKrios primary key(id));

create table Provincia (
id int not null, 
nombre varchar(30),
area int, 
geometria geometry check(geometria.STGeometryType() = 'MultiPolygon') not null,
constraint PKprovincia primary key(id)
);

create table Canton (
	id int  identity (1,1), 
	nombre varchar(30),
	pob_200h int,
	pob_200m int, 
	areacanton int, 
	geometria geometry check(geometria.STGeometryType() = 'MultiPolygon') not null, 
	FKidprovincia int,
	constraint PKcanton primary key(id),
	constraint FKcanton foreign key (FKidprovincia) references Provincia (id) on delete cascade on update cascade
);

create table Infraestructura(
id_Canton_Infraestructura int identity (1,1) not null,
tipo      varchar(45) not null,
cantidad  int check(cantidad > 0),
constraint PKinfraestructura primary key(id_Canton_Infraestructura),
constraint FKinfraestructura foreign key(id_Canton_Infraestructura) references Canton(id)
);

create table Poblado(
id int    identity (1,1),
nombre    varchar(30),
geometria geometry check(geometria.STGeometryType() = 'Point') not null,
FKidCanton  int,
constraint PKpoblado primary key(id),
constraint FKpoblado foreign key (FKidCanton) references Canton (id) on delete cascade on update cascade
);

create table Region (
id int not null,
nombre      varchar(30) not null,
viviendas_O int,
geometria   geometry check(geometria.STGeometryType() = 'MultiPolygon') not null,
constraint PKregion primary key(id),
);

create table Edades (
	id_RegionFK int not null,
	tipo varchar(30),
	cantidad int check(cantidad >= 0),
	constraint EdadesPK primary key(id_RegionFK),
	constraint EdadesFK foreign key (id_RegionFK) references Region (id) on delete cascade on update cascade
);

create table GeneracionElectrica (
	id int  identity (1,1),
	nombre varchar(30),
	empresa varchar(30),
	tipo varchar(30),
	capacidad int check(capacidad >= 0),
	propiedad varchar(30),
	estado varchar(30),
	geometria geometry check(geometria.STGeometryType() = 'Point') not null,
	
	constraint PKGeneracionElectrica primary key(id)
);

create table Gen_Canton_Region(

idGenElec int not null, 
idCanton  int not null,
idRegion  int not null, 

constraint PKgen_Canton_Region primary key(idGenElec,idCanton,idRegion),
constraint FK1gen_Canton_Region foreign key(idGenElec) references GeneracionElectrica(id),
constraint FK2gen_Canton_Region foreign key(idCanton) references Canton(id),
constraint FK3gen_Canton_Region foreign key(idRegion) references Region(id)
);

create table Rios_en_Canton (
idRioFK int,
idCantonFK int
constraint PKRios_en_Canton primary key (idRioFK, idCantonFK),
constraint FK1Rios_en_Canton foreign key(idRioFK) references Rios(id),
constraint FK2Rios_en_Canton foreign key(idCantonFK) references Canton(id) 
);

create table ServElectricidad (
id_RegionFK int,
tipo varchar(30),
cantidad int,
constraint PKServElectricidad primary key (id_RegionFK),
constraint FKServElectricidad foreign key(id_RegionFK) references Region(id)
);

select provincia, geom.STIsValid(), geom
from   ProvinciaShape;

update ProvinciaShape
set    geom = geom.MakeValid();

update ProvinciaShape 
set    geom = geom.STUnion(geom.STStartPoint());

update ProvinciaShape
set    geom = geom.STBuffer(0.00001).STBuffer(-0.00001);


--Forma de ver las dimensiones, visualmente se pueden sacar los boundingbox NO LA MEJOR FORMA--
select provincia, geom.STEnvelope().ToString() as boundingbox
from ProvinciaShape;


--Provincias se llama la tabla temporal que cree al ingresar el archivo shape de provincias
--Creo 4 columnas nuevas, con el min y max de cada poligono.
alter table ProvinciaShape
add 
MinX as (convert(int, geom.STEnvelope().STPointN((1)).STX,0)) PERSISTED,
MinY as (convert(int, geom.STEnvelope().STPointN((1)).STY,0)) PERSISTED,
MaxX as (convert(int, geom.STEnvelope().STPointN((3)).STX,0)) PERSISTED,
MaxY as (convert(int, geom.STEnvelope().STPointN((3)).STY,0)) PERSISTED;

--Con esta consulta encuentro los minimos y maximos para los boundingbox 
--FORMA OPTIMA PARA SACAR LOS BOUNDING BOXES
select 
MIN(MinX) as MinX,
MIN (MinY) as MinY,
MAX (MaxX) as MaxX,
MAX (MaxY) as MaxY
from ProvinciaShape;

select *
from   ProvinciaShape;


select provincia, geom.ToString() as boundingbox
from ProvinciaShape;

DECLARE @g geometry;
SET @g = geometry::Parse('MULTIPOLYGON(((0 0, 0 3, 3 3, 3 0, 0 0), (1 1, 1 2, 2 1, 1 1)), ((9 9, 9 10, 10 9, 9 9)))');
SELECT @g.STGeometryN(2).STAsText();


select Nombre, geom.STIsValid(), geom
from   GenElecShape;

select *
from   GenElecShape;


insert into GeneracionElectrica (nombre, empresa, tipo, capacidad, propiedad, estado, geometria)
select nombre, empresa, tipo, capacidad, propiedad, estado, geom
from GenElecShape 

CREATE TRIGGER corregirGeom_Rios
ON Rios r
AFTER INSERT, UPDATE
AS
BEGIN
DECLARE @geometria_v Geometry,
@Nombre Nchar(40);
SELECT @Nombre = r.Nombre, @geometria_v = r.geometria
FROM INSERTED

IF @geometria_v.STIsValid()=0
SET @geometria_v = @geometria_v.MakeValid();
UPDATE r.geometria
SET Geometria = @geometria_v
WHERE p.Nombre = @Nombre
END

--correcciones de las geometrias

CREATE TRIGGER corregirGeom_Prov
ON provincia p
AFTER INSERT, UPDATE
AS
BEGIN
DECLARE @geometria Geometry,
@Nombre Nchar(40);
SELECT @Nombre = p.Nombre, @geometria = p.geometria
FROM INSERTED
IF @geometria.STIsValid()=0
SET @geometria = @geometria.MakeValid();
UPDATE p.geometria
SET p.geometria = @geometria
WHERE p.Nombre = @Nombre
END

CREATE TRIGGER corregirGeom_Poblado
ON Poblado p
AFTER INSERT, UPDATE
AS
BEGIN
DECLARE @geometria Geometry,
@Nombre Nchar(40);
SELECT @Nombre = p.Nombre, @geometria = p.geometria
FROM INSERTED
IF @geometria.STIsValid()=0
SET @geometria = @geometria.MakeValid();
UPDATE p.geometria
SET p.geometria = @geometria
WHERE p.Nombre = @Nombre
END

CREATE TRIGGER corregirGeom_Region
ON Region r
AFTER INSERT, UPDATE
AS
BEGIN
DECLARE @geometria Geometry,
@Nombre Nchar(40);
SELECT @Nombre = r.Nombre, @geometria = r.geometria
FROM INSERTED
IF @geometria.STIsValid()=0
SET @geometria = @geometria.MakeValid();
UPDATE r.geometria
SET r.geometria = @geometria
WHERE p.Nombre = @Nombre
END

CREATE TRIGGER corregirGeom_Canton
 ON canton c
 AFTER INSERT, UPDATE
AS
BEGIN
 DECLARE @geometria Geometry,
 @Nombre Nchar(40);
 SELECT @Nombre = c.nombre, @cantones = c.geometria
 FROM cantones c
 IF @cantones.STIsValid()=0
 SET @cantones = @cantones.MakeValid();

 UPDATE c.geometria
 SET p.geometria = @cantones_shp
 WHERE c.nombre = @Nombre
END

CREATE TRIGGER corregirGeom_GenElectrica
 ON  generacionelectrica ge 
 AFTER INSERT, UPDATE
AS
BEGIN
 DECLARE @geometry Geometry,
 @Nombre Nchar(40);
 SELECT @Nombre = g.nombre, @cantones = g.geometria
 FROM generacionelectrica g
 IF @cantones.STIsValid()=0
 SET @cantones = @cantones.MakeValid();

 UPDATE g.geometria
 SET g.geometria = @cantones
 WHERE g.nombre = @Nombre
END