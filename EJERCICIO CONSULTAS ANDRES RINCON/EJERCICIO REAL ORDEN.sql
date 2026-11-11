-- ****************************************************
-- * SCRIPT DE LIMPIEZA DE DATOS *
-- ****************************************************

DROP TABLE IF EXISTS tab_pagos, tab_det_compra, tab_enc_compra,
tab_det_orden, tab_orden_compra, tab_prod_prov,
tab_prov, tab_areas, tab_prod, tab_ciud,
tab_dptos, tab_pmtros;

-- ****************************************************
-- * SCRIPT DE CREACION DE LA TABLA PARAMETROS *
-- ****************************************************

CREATE TABLE tab_pmtros


(

	id_empresa 			DECIMAL(10,0) 	NOT NULL,
	dia_pagos1 			SMALLINT 		NOT NULL, 
	dia_pagos2 			SMALLINT 		NOT NULL,
	dia_pagos3			SMALLINT 		NOT NULL,
	num_orden 			DECIMAL(6,0) 	NOT NULL, 
PRIMARY KEY (id_empresa),
CHECK (id_empresa > 0),
CHECK (dia_pagos1 BETWEEN 1 AND 7
AND dia_pagos2 BETWEEN 1 AND 7
AND dia_pagos3 BETWEEN 1 AND 7
AND dia_pagos1 < dia_pagos2
AND dia_pagos2 < dia_pagos3),
CHECK (num_orden > 0)
);


-- ****************************************************
-- * SCRIPT DE CREACION DE LA TABLA DEPARTAMENTOS *
-- ****************************************************

CREATE TABLE tab_dptos


(

		id_dpto 	VARCHAR(2) 		NOT NULL,
		nom_dpto 	VARCHAR(60) 	NOT NULL,
PRIMARY KEY (id_dpto)
);

-- ****************************************************
-- * SCRIPT DE CREACION DE LA TABLA CIUDADES *
-- ****************************************************

CREATE TABLE tab_ciud
(

	
	id_ciud 	VARCHAR(5) 		NOT NULL,
	nom_ciud 	VARCHAR(80) 	NOT NULL,
	id_dpto 	VARCHAR(2) 		NOT NULL,
PRIMARY KEY (id_ciud),
FOREIGN KEY (id_dpto)
REFERENCES tab_dptos (id_dpto)

);


-- ****************************************************
-- * SCRIPT DE CREACION DE LA TABLA DE PROVEEDORES *
-- ****************************************************


CREATE TABLE tab_prov

(

	id_prov 		DECIMAL(10,0) 	NOT NULL,
	nom_prov 		VARCHAR(15) 	NOT NULL,
	ape_prov 		VARCHAR(10) 	NOT NULL,
	dir_prov 		VARCHAR(100) 	NULL,
	tel_prov 		VARCHAR(10) 	NULL,
	email_prov 		VARCHAR(100) 	NOT NULL,
	id_ciud 		VARCHAR(5) 		NOT NULL,
	val_cupocre 	DECIMAL(12,0) 	NULL DEFAULT 0,
	val_puntos 		DECIMAL(3,0) 	NULL DEFAULT 0,
	num_fact 		DECIMAL(6,0) 	NOT NULL,
	ind_estado 		BOOLEAN 		NULL DEFAULT TRUE,
	
PRIMARY KEY (id_prov),
FOREIGN KEY (id_ciud)
REFERENCES tab_ciud (id_ciud)

);


-- ****************************************************
-- * SCRIPT DE CREACION DE LA TABLA DE PRODUCTOS *
-- ****************************************************


CREATE TABLE tab_prod 

(    

	id_prod     SMALLINT    NOT NULL,    
	id_ref      VARCHAR(10) NOT NULL,    
	nom_prod    VARCHAR(80) NOT NULL,    
	ind_estado  BOOLEAN     NOT NULL DEFAULT TRUE,    
PRIMARY KEY (id_prod),    
UNIQUE (id_ref),    
CHECK (id_prod > 0),    
CHECK (BTRIM(nom_prod) <> '') 


);


-- **************************************************************
-- * SCRIPT DE CREACION DE LA TABLA DE PRODUCTOS DE PROVEEDORES *
-- **************************************************************

CREATE TABLE tab_prod_prov 


(    


		id_prov   DECIMAL(10,0) 	NOT NULL,    
		id_prod   SMALLINT      	NOT NULL,    
		val_prod  DECIMAL(10,0) 	NULL,    
		ind_disp  BOOLEAN       	NULL DEFAULT TRUE,    
PRIMARY KEY (id_prov, id_prod),    
FOREIGN KEY (id_prov)               
REFERENCES tab_prov (id_prov),    
FOREIGN KEY (id_prod)               
REFERENCES tab_prod (id_prod),    
CHECK (val_prod > 0) 

);  


-- **************************************************************
-- * SCRIPT DE CREACION  DE LA TABLA AREAS DE LA EMPRESA *
-- **************************************************************


CREATE TABLE tab_areas 

(    

		id_area     DECIMAL(2,0)  NOT NULL,    
		nom_area    VARCHAR(60)   NOT NULL,    
		nom_encarg  VARCHAR(50)  NOT NULL,    
PRIMARY KEY (id_area),    
UNIQUE (nom_area),    
CHECK (id_area > 0) 

);


-- **************************************************************
-- * SCRIPT DE CREACION DE LA TABLA ORDENES DE COMPRA *
-- **************************************************************

CREATE TABLE tab_orden_compra 


(    


			id_orden   DECIMAL(6,0) 	NOT NULL,    
			fec_orden  TIMESTAMP    	NOT NULL DEFAULT CURRENT_TIMESTAMP,    
			id_area    DECIMAL(2,0) 	NOT NULL,


PRIMARY KEY (id_orden),    
FOREIGN KEY (id_area)               
REFERENCES tab_areas (id_area) ON DELETE RESTRICT,    
CONSTRAINT ck_orden_id   CHECK (id_orden > 0) 


);


CREATE TABLE tab_det_orden
(


	id_orden 	DECIMAL(6,0) 	NOT NULL,
	id_prod 	SMALLINT 		NOT NULL,
	val_cant 	SMALLINT 		NOT NULL,
	
PRIMARY KEY (id_orden, id_prod),
FOREIGN KEY (id_orden)
REFERENCES tab_orden_compra (id_orden) ON DELETE CASCADE,
FOREIGN KEY (id_prod)
REFERENCES tab_prod (id_prod) ON DELETE RESTRICT,
CHECK (val_cant > 0)


);



-- **************************************************************
-- * SCRIPT DE CREACION DE LA TABLA FACTURAS DE COMPRA *
-- **************************************************************


CREATE TABLE tab_enc_compra


(
	
		id_factura 			DECIMAL(6,0) 		NOT NULL,
		fec_factura 		DATE 				NOT NULL DEFAULT CURRENT_DATE,
		id_prov 			DECIMAL(10,0) 		NOT NULL,
		id_ciud_entrega 	VARCHAR(5) 			NOT NULL,
		val_observa 		TEXT,
PRIMARY KEY (id_factura),
FOREIGN KEY (id_prov)
REFERENCES tab_prov (id_prov) ON DELETE RESTRICT,
FOREIGN KEY (id_ciud_entrega)
REFERENCES tab_ciud (id_ciud) ON DELETE RESTRICT,
CHECK (id_factura > 0),
CHECK (fec_factura >= DATE '2000-01-01')
);


-- **************************************************************
-- * SCRIPT DE CREACION DE LA TABLA DETALLES DE COMPRA *
-- **************************************************************



CREATE TABLE tab_det_compra


(


		id_factura 		DECIMAL(6,0) 	NOT NULL,
		id_prod 		SMALLINT 		NOT NULL,
		val_cant 		SMALLINT 		NOT NULL,
		val_unit 		DECIMAL(10,0) 	NOT NULL,
		val_descu 		DECIMAL(12,0) 	NOT NULL DEFAULT 0,
		porc_iva 		DECIMAL(4,2) 	NOT NULL DEFAULT 19,
		val_bruto 		DECIMAL(12,0) 	GENERATED ALWAYS AS (val_cant * val_unit) STORED,
		val_iva 		DECIMAL(12,0) 	GENERATED ALWAYS AS
		(ROUND((val_cant * val_unit - val_descu) * porc_iva / 100)) STORED,
		val_neto DECIMAL(12,0) GENERATED ALWAYS AS
		(val_cant * val_unit - val_descu
		+ ROUND((val_cant * val_unit - val_descu) * porc_iva / 100)) STORED,
PRIMARY KEY (id_factura, id_prod),
FOREIGN KEY (id_factura)
REFERENCES tab_enc_compra (id_factura) ON DELETE CASCADE,
FOREIGN KEY (id_prod)
REFERENCES tab_prod (id_prod) ON DELETE RESTRICT,
CHECK (val_cant > 0),
CHECK (val_unit > 0),
CHECK (val_descu >= 0
AND val_descu <= val_cant * val_unit),
CHECK (porc_iva IN (0, 5, 19))
);



-- **************************************************************
-- * SCRIPT DE CREACION DE LA TABLA PAGOS *
-- **************************************************************


CREATE TABLE tab_pagos


(


		id_factura 	DECIMAL(6,0) 	NOT NULL,
		id_pago 	SMALLINT 		NOT NULL,
		fec_pago 	DATE 			NOT NULL,
		val_pago 	DECIMAL(12,0)	 NOT NULL,
PRIMARY KEY (id_factura, id_pago),
FOREIGN KEY (id_factura)
REFERENCES tab_enc_compra (id_factura) ON DELETE RESTRICT,
CHECK (id_pago > 0),
CHECK (val_pago > 0)
);




-- **************************************************************
-- **************  SCRIPT DE INSERCION DE DATOS  ****************
-- **************************************************************


-- ****************************************************
-- * TABLA DEPARTAMENTOS (PROVINCIAS)                 *
-- ****************************************************

INSERT INTO tab_dptos (id_dpto, nom_dpto) VALUES
('01', 'Buenos Aires'),
('02', 'Córdoba'),
('03', 'Santa Fe'),
('04', 'Mendoza'),
('05', 'Tucumán'),
('06', 'Salta'),
('07', 'Entre Ríos'),
('08', 'Misiones'),
('09', 'Corrientes'),
('10', 'Chaco'),
('11', 'Jujuy'),
('12', 'Neuquén'),
('13', 'Río Negro'),
('14', 'Chubut'),
('15', 'Santa Cruz'),
('16', 'Tierra del Fuego'),
('17', 'San Juan'),
('18', 'San Luis'),
('19', 'La Pampa'),
('20', 'Catamarca');

-- ****************************************************
-- * TABLA CIUDADES                                   *
-- ****************************************************

INSERT INTO tab_ciud (id_ciud, nom_ciud, id_dpto) VALUES
-- 01 Buenos Aires
('01001', 'La Plata', '01'),
('01002', 'Mar del Plata', '01'),
('01003', 'Bahía Blanca', '01'),
-- 02 Córdoba
('02001', 'Córdoba', '02'),
('02002', 'Río Cuarto', '02'),
('02003', 'Villa María', '02'),
-- 03 Santa Fe
('03001', 'Santa Fe', '03'),
('03002', 'Rosario', '03'),
('03003', 'Rafaela', '03'),
-- 04 Mendoza
('04001', 'Mendoza', '04'),
('04002', 'San Rafael', '04'),
('04003', 'San Martín', '04'),
-- 05 Tucumán
('05001', 'San Miguel de Tucumán', '05'),
('05002', 'Concepción', '05'),
('05003', 'Tafí Viejo', '05'),
-- 06 Salta
('06001', 'Salta', '06'),
('06002', 'San Ramón de la Nueva Orán', '06'),
('06003', 'Tartagal', '06'),
-- 07 Entre Ríos
('07001', 'Paraná', '07'),
('07002', 'Concordia', '07'),
('07003', 'Gualeguaychú', '07'),
-- 08 Misiones
('08001', 'Posadas', '08'),
('08002', 'Oberá', '08'),
('08003', 'Eldorado', '08'),
-- 09 Corrientes
('09001', 'Corrientes', '09'),
('09002', 'Goya', '09'),
('09003', 'Paso de los Libres', '09'),
-- 10 Chaco
('10001', 'Resistencia', '10'),
('10002', 'Presidencia Roque Sáenz Peña', '10'),
('10003', 'Villa Ángela', '10'),
-- 11 Jujuy
('11001', 'San Salvador de Jujuy', '11'),
('11002', 'Palpalá', '11'),
('11003', 'San Pedro de Jujuy', '11'),
-- 12 Neuquén
('12001', 'Neuquén', '12'),
('12002', 'Cutral Có', '12'),
('12003', 'Zapala', '12'),
-- 13 Río Negro
('13001', 'Viedma', '13'),
('13002', 'San Carlos de Bariloche', '13'),
('13003', 'General Roca', '13'),
-- 14 Chubut
('14001', 'Rawson', '14'),
('14002', 'Comodoro Rivadavia', '14'),
('14003', 'Trelew', '14'),
-- 15 Santa Cruz
('15001', 'Río Gallegos', '15'),
('15002', 'Caleta Olivia', '15'),
('15003', 'El Calafate', '15'),
-- 16 Tierra del Fuego
('16001', 'Ushuaia', '16'),
('16002', 'Río Grande', '16'),
('16003', 'Tolhuin', '16'),
-- 17 San Juan
('17001', 'San Juan', '17'),
('17002', 'Chimbas', '17'),
('17003', 'Caucete', '17'),
-- 18 San Luis
('18001', 'San Luis', '18'),
('18002', 'Villa Mercedes', '18'),
('18003', 'Merlo', '18'),
-- 19 La Pampa
('19001', 'Santa Rosa', '19'),
('19002', 'General Pico', '19'),
('19003', 'Toay', '19'),
-- 20 Catamarca
('20001', 'San Fernando del Valle de Catamarca', '20'),
('20002', 'Andalgalá', '20'),
('20003', 'Belén', '20');


-- ****************** tab_pmtros ******************
INSERT INTO tab_pmtros (id_empresa, dia_pagos1, dia_pagos2, dia_pagos3, num_orden) VALUES
(9001234567, 1, 3, 5, 1009);

-- ****************** tab_areas ******************
INSERT INTO tab_areas (id_area, nom_area, nom_encarg) VALUES
(1,'Administración','Laura Gómez Ruiz'),
(2,'Sistemas','Andrés Torres Vega'),
(3,'Recursos Humanos','Marcela Díaz Soto'),
(4,'Contabilidad','Ricardo Mena Paz'),
(5,'Mantenimiento','Jorge Ibarra Luna');

-- ****************** tab_prod ******************
INSERT INTO tab_prod (id_prod, id_ref, nom_prod, ind_estado) VALUES
(1,'PAP-001','Resma de papel carta 500 hojas',TRUE),
(2,'TON-002','Tóner negro para impresora láser',TRUE),
(3,'BOL-003','Caja de bolígrafos x12',TRUE),
(4,'CUA-004','Cuaderno argollado 100 hojas',TRUE),
(5,'MAR-005','Marcadores borrables x4',TRUE),
(6,'CAR-006','Carpeta archivadora oficio',TRUE),
(7,'GRA-007','Grapadora metálica',TRUE),
(8,'CLI-008','Caja de clips x100',TRUE),
(9,'SIL-009','Silla ergonómica de oficina',TRUE),
(10,'ESC-010','Escritorio modular',TRUE),
(11,'TEC-011','Teclado USB',TRUE),
(12,'MOU-012','Mouse óptico USB',TRUE),
(13,'MON-013','Monitor 24 pulgadas',TRUE),
(14,'HDM-014','Cable HDMI 2 metros',TRUE),
(15,'DET-015','Detergente multiusos galón',TRUE);

-- ****************** tab_prov ******************
INSERT INTO tab_prov (id_prov, nom_prov, ape_prov, dir_prov, tel_prov, email_prov, id_ciud, val_cupocre, val_puntos, num_fact, ind_estado) VALUES
(1012345678,'Michael','Jackson','Av. Colón 1250','3515551201','ELREYDEL.POPO@proveedores.com','02001',5000000,120,501,TRUE),
(1023456789,'Lionel','Messi','Calle San Martín 340','3415551202','ELGOAT@proveedores.com','03002',3000000,80,601,TRUE),
(1034567890,'Andres','chikiza','Av. Corrientes 4500','2215551203','legendariodelrap@proveedores.com','01001',8000000,200,701,TRUE),
(1045678901,'Tupac','Shakur','Calle Mitre 78','2615551204','elreydelrap@proveedores.com','04001',2000000,45,801,TRUE),
(1056789012,'Notorius','Big','Av. Belgrano 910','3815551205','biggie.biggie@proveedores.com','05001',4500000,95,901,TRUE),
(1067890123,'Cristo','EsDios','Calle Rivadavia 2210','3875551206','cristo.teama@proveedores.com','06001',1500000,30,1001,TRUE),
(1078901234,'Eminem','Rapgod','Av. Libertador 765','3765551207','diosdelrap@proveedores.com','08001',6000000,150,1101,TRUE),
(1089012345,'Cristiano','Ronaldo','Calle Sarmiento 123','2995551208','penaldo7@proveedores.com','12001',2500000,60,1201,TRUE),
(1090123456,'Eicib','Legendary','Av. Roca 456','2945551209','ecleciastico@proveedores.com','13002',3500000,110,1301,TRUE),
(1101234567,'Camila','Herrera','Calle Belgrano 987','2901551210','camila.herrera@proveedores.com','16001',1000000,20,1401,TRUE);

-- ****************** tab_prod_prov ******************
INSERT INTO tab_prod_prov (id_prov, id_prod, val_prod, ind_disp) VALUES
(1012345678,1,17800,TRUE),
(1012345678,2,77700,TRUE),
(1012345678,3,9800,TRUE),
(1012345678,6,7100,TRUE),
(1012345678,7,15600,TRUE),
(1012345678,9,293600,TRUE),
(1012345678,10,442900,TRUE),
(1012345678,11,45300,TRUE),
(1023456789,1,16400,TRUE),
(1023456789,2,81200,TRUE),
(1023456789,4,6800,TRUE),
(1023456789,7,14500,TRUE),
(1023456789,10,482300,TRUE),
(1023456789,11,46600,TRUE),
(1023456789,14,22900,TRUE),
(1023456789,15,36400,TRUE),
(1034567890,2,88100,TRUE),
(1034567890,3,8700,TRUE),
(1034567890,4,5900,TRUE),
(1034567890,6,7400,TRUE),
(1034567890,10,513600,TRUE),
(1034567890,11,45300,TRUE),
(1034567890,12,27400,TRUE),
(1034567890,13,680200,TRUE),
(1045678901,2,87700,TRUE),
(1045678901,3,10600,TRUE),
(1045678901,4,7000,TRUE),
(1045678901,5,11700,TRUE),
(1045678901,6,8900,TRUE),
(1045678901,8,2300,TRUE),
(1045678901,12,28100,TRUE),
(1045678901,13,708000,TRUE),
(1056789012,1,17700,TRUE),
(1056789012,2,83900,TRUE),
(1056789012,3,9700,TRUE),
(1056789012,6,8600,TRUE),
(1056789012,7,14200,TRUE),
(1056789012,8,2300,TRUE),
(1056789012,9,309600,TRUE),
(1056789012,11,48300,TRUE),
(1067890123,1,19400,TRUE),
(1067890123,2,95300,TRUE),
(1067890123,5,11800,TRUE),
(1067890123,8,2800,TRUE),
(1067890123,10,474700,TRUE),
(1067890123,11,47400,TRUE),
(1067890123,12,28700,TRUE),
(1067890123,13,620500,TRUE),
(1078901234,2,80000,TRUE),
(1078901234,3,9500,TRUE),
(1078901234,4,6300,TRUE),
(1078901234,5,11200,TRUE),
(1078901234,7,15600,TRUE),
(1078901234,8,2600,TRUE),
(1078901234,11,48400,TRUE),
(1078901234,12,32100,TRUE),
(1089012345,2,90500,TRUE),
(1089012345,3,8600,TRUE),
(1089012345,4,7200,TRUE),
(1089012345,7,14700,TRUE),
(1089012345,10,465800,TRUE),
(1089012345,11,42100,TRUE),
(1089012345,12,28900,TRUE),
(1089012345,13,684100,TRUE),
(1090123456,1,18000,TRUE),
(1090123456,3,9500,TRUE),
(1090123456,6,8000,TRUE),
(1090123456,7,15500,TRUE),
(1090123456,8,2400,TRUE),
(1090123456,9,366800,TRUE),
(1090123456,10,484900,TRUE),
(1090123456,12,26000,TRUE),
(1101234567,1,20500,TRUE),
(1101234567,2,89500,TRUE),
(1101234567,3,8700,TRUE),
(1101234567,9,304600,TRUE),
(1101234567,10,477100,TRUE),
(1101234567,13,688100,TRUE),
(1101234567,14,25100,TRUE),
(1101234567,15,36800,TRUE);

-- ****************** tab_orden_compra ******************
INSERT INTO tab_orden_compra (id_orden, fec_orden, id_area) VALUES
(1001,'2026-09-01 08:30:00',4),
(1002,'2026-09-05 09:30:00',1),
(1003,'2026-09-09 10:30:00',1),
(1004,'2026-09-13 11:30:00',4),
(1005,'2026-09-17 12:30:00',4),
(1006,'2026-09-21 13:30:00',4),
(1007,'2026-09-25 14:30:00',4),
(1008,'2026-09-29 15:30:00',3);

-- ****************** tab_det_orden ******************
INSERT INTO tab_det_orden (id_orden, id_prod, val_cant) VALUES
(1001,2,11),
(1001,3,9),
(1002,3,17),
(1002,12,1),
(1002,14,7),
(1003,3,1),
(1003,6,17),
(1003,9,10),
(1003,12,3),
(1004,5,6),
(1004,6,12),
(1004,9,8),
(1004,14,18),
(1005,6,8),
(1005,9,20),
(1005,11,7),
(1005,13,8),
(1006,4,7),
(1006,12,17),
(1006,13,16),
(1007,1,9),
(1007,12,16),
(1007,14,9),
(1008,10,12),
(1008,12,15);

-- ****************** tab_enc_compra ******************
INSERT INTO tab_enc_compra (id_factura, fec_factura, id_prov, id_ciud_entrega, val_observa) VALUES
(2001,'2026-09-05',1012345678,'06001','Facturar a nombre de la empresa'),
(2002,'2026-09-10',1023456789,'02001','Entrega en horario de oficina'),
(2003,'2026-09-15',1034567890,'02001','Entrega en horario de oficina'),
(2004,'2026-09-20',1045678901,'12001','Entrega en horario de oficina'),
(2005,'2026-09-25',1056789012,'06001','Entrega en horario de oficina'),
(2006,'2026-09-30',1067890123,'12001',NULL),
(2007,'2026-10-05',1078901234,'12001','Facturar a nombre de la empresa'),
(2008,'2026-10-10',1089012345,'02001',NULL),
(2009,'2026-10-15',1090123456,'08001','Entrega en horario de oficina'),
(2010,'2026-10-20',1101234567,'12001','Entrega en horario de oficina'),
(2011,'2026-10-25',1078901234,'06001',NULL),
(2012,'2026-10-30',1078901234,'12001','Entrega parcial autorizada');

-- ****************** tab_det_compra ******************
-- (val_bruto, val_iva y val_neto se calculan automaticamente)
INSERT INTO tab_det_compra (id_factura, id_prod, val_cant, val_unit, val_descu, porc_iva) VALUES
(2001,2,3,77700,0,5),
(2001,9,10,293600,293600,5),
(2001,10,10,442900,442900,19),
(2001,11,3,45300,0,0),
(2002,2,12,81200,0,19),
(2002,10,4,482300,0,0),
(2003,4,4,5900,1100,19),
(2003,6,9,7400,6600,5),
(2003,10,1,513600,25600,19),
(2004,3,9,10600,0,19),
(2004,6,9,8900,0,19),
(2004,12,3,28100,0,5),
(2004,13,3,708000,0,19),
(2005,1,11,17700,19400,0),
(2005,2,9,83900,0,5),
(2005,3,4,9700,1900,0),
(2005,7,2,14200,2800,19),
(2006,2,6,95300,0,19),
(2006,8,8,2800,2200,19),
(2007,7,4,15600,6200,5),
(2007,12,7,32100,0,19),
(2008,2,4,90500,36200,0),
(2008,11,4,42100,8400,0),
(2008,13,3,684100,102600,5),
(2009,3,12,9500,0,19),
(2009,6,8,8000,0,5),
(2009,7,3,15500,4600,19),
(2010,2,6,89500,26800,0),
(2010,9,12,304600,182700,0),
(2010,13,6,688100,412800,19),
(2011,2,10,80000,40000,19),
(2011,4,2,6300,0,5),
(2011,5,2,11200,0,19),
(2011,7,5,15600,0,5),
(2012,4,11,6300,3400,19),
(2012,5,3,11200,3300,19),
(2012,11,2,48400,4800,0);

-- ****************** tab_pagos ******************
INSERT INTO tab_pagos (id_factura, id_pago, fec_pago, val_pago) VALUES
(2001,1,'2026-09-24',7898634),
(2002,1,'2026-09-28',1544000),
(2002,2,'2026-10-07',1544736),
(2003,1,'2026-09-28',268000),
(2004,1,'2026-09-28',2824920),
(2005,1,'2026-10-06',310000),
(2005,2,'2026-10-13',310000),
(2005,3,'2026-10-30',415519),
(2006,1,'2026-10-08',281000),
(2007,1,'2026-10-24',326403),
(2008,1,'2026-10-21',1266000),
(2008,2,'2026-10-29',1266985),
(2009,1,'2026-10-31',252721),
(2010,1,'2026-11-09',3361000),
(2011,1,'2026-11-04',513000),
(2011,2,'2026-11-12',513186),
(2012,1,'2026-11-10',206478);


