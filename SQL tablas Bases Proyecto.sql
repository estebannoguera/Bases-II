create database ProyectoRios;
USE ProyectoRios;

---tablas proyecto bases II.

create table Rios ( 
id int  identity (1,1),
nombre varchar(30),
geometria geography check (geometria.STGeometryType() = 'Line') not null,
constraint PKrios primary key(id));

create table Provincia (
id int not null, 
nombre varchar(30),
area int, 
geometria geography check(geometria.STGeometryType() = 'MultiPolygon') not null,
constraint PKprovincia primary key(id)
);

create table Canton (
	id int  identity (1,1), 
	nombre varchar(30),
	pob_200h int,
	pob_200m int, 
	areacanton int, 
	geometria geography check(geometria.STGeometryType() = 'MultiPolygon') not null, 
	FKidprovincia int,
	constraint PKcanton primary key(id),
	constraint FKcanton foreign key (FKidprovincia) references Provincia (id) on delete cascade on update cascade
);

create table Infraestructura(
id_Canton_Infraestructura int not null,
tipo      varchar(45) not null,
cantidad  int check(cantidad > 0),
constraint PKinfraestructura primary key(id_Canton_Infraestructura),
constraint FKinfraestructura foreign key(id_Canton_Infraestructura) references Canton(id)
);

create table Poblado(
id int    identity (1,1),
nombre    varchar(30),
geometria geography check(geometria.STGeometryType() = 'Point') not null,
FKidCanton  int,
constraint PKpoblado primary key(id),
constraint FKpoblado foreign key (FKidCanton) references Canton (id) on delete cascade on update cascade
);

create table Region (
id int not null,
nombre      varchar(30) not null,
viviendas_O int,
geometria   geography check(geometria.STGeometryType() = 'MultiPolygon') not null,
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
	geometria geography check(geometria.STGeometryType() = 'Point') not null,
	
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