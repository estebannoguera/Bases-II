create database Rios;
USE Rios;

---tablas proyecto bases II.

create table poblado(

id int    identity (1,1),
nombre    varchar(30),
geometria geometry,
idCanton  int,

constraint pobladoPK primary key(id),
constraint pobladoFK foreign key (idCanton) references Canton (id) on delete cascade on update cascade
);


create table Region (

id int      identity (1,1),
nombre      varchar(30) not null,
viviendas_O int,
geometria   geometry check(geometria.STGeometryType() = 'MultiPolygon') not null,

constraint regionPK primary key(id),
);


gen_Canton_Region(

idGenElec int not null, 
idCanton  int not null,
idRegion  int not null, 

constraint gen_Canton_RegionPK primary key(idGenElec,idCanton,idRegion),
constraint gen_Canton_RegionFK1 foreign key(idGenElec) references GeneracionElectrica(id),
constraint gen_Canton_RegionFK2 foreign key(idCanton) references Canton(id),
constraint gen_Canton_RegionFK3 foreign key(idRegion) references Region(id)
);


create table Infraestructura(

id_Canton int not null,
tipo      varchar(45) not null,
cantidad  int check(cantidad > 0),

constraint infraestructuraPK primary key(id_Canton),
constraint infraestructuraFK foreign key(id_Canton) references Canton(id)
);

------Tablas JP------

create table Canton (
	id int, 
	nombre varchar(30),
	pob_200h int,
	pob_200m int, 
	areacanton int, 
	geometria geometry, 
	idprovinciaFK int,
	
	constraint cantonPK primary key(id),
	constraint cantonFK foreign key (idprovinciaFK) references Provincia (id) on delete cascade on update cascade
);

create table GeneracionElectrica (
	id int not null,
	nombre varchar(30),
	empresa varchar(30),
	tipo varchar(30),
	capacidad int check(capacidad >= 0),
	propiedad varchar(30),
	estado varchar(30),
	geometria geometry check(geometria.STGeometryType() = 'Point') not null,
	
	constraint GeneracionElectricaPK primary key(id)
);

create table Edades (
	id_RegionFK int not null,
	tipo varchar(30),
	cantidad int check(cantidad >= 0),
	
	constraint EdadesPK primary key(id_RegionFK),
	constraint EdadesFK foreign key (id_RegionFK) references Region (id) on delete cascade on update cascade
);


