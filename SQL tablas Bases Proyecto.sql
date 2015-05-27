

---tablas proyecto bases II.

create table poblado(

id int    identity (1,1),
nombre    varchar(30),
geometria geometry,
idCanton  int,

constraint pobladoPK primary key(id),
constraint pobladoFK foreign key (idCanton) references Canton (id) on delete cascade on update cascade
);


create table Region(

id int      identity (1,1),
nombre      varchar(30) not null,
viviendas_O int,
geometria   geometry check(geometria.STGeometryType = 'MultiPolygon') not null,

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


