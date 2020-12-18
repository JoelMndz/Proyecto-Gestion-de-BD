use master
 --===========================================================================
----------------Creación de la BD---------------------------
 --===========================================================================
if exists ( select * from sysdatabases where (name = 'proyecto' ))
begin
drop database proyecto
end
create database proyecto
go
use proyecto
go
begin try
	begin transaction
 --===========================================================================
----------------Creación de tablas---------------------------
 --===========================================================================

    create table administrador(
		adm_id smallint not null primary key identity(1,1),
		adm_nombres varchar (50) not null,
        adm_apellidos varchar (50) not null,
        adm_cedula varchar (10) unique not null,
        adm_usuario varchar(50) unique not null,
        adm_clave varchar (50) not null,
        adm_telefono varchar(15) default 'DESCONOCIDO',
        adm_email varchar(100) default 'DESCONOCIDO'
	)
    --tabla para auditoria del administrador
    create table administrador_historial(
        id smallint ,
		nombres varchar (50),
        apellidos varchar (50),
        cedula varchar (10),
        usuario varchar(50),
        clave varchar (50),
        telefono varchar(15),
        email varchar(100),
        fecha_auditoria datetime,
        descripcion varchar(100)
    )

    create table profesor(
        pro_id smallint not null primary key identity(1,1),
		pro_nombres varchar (50) not null,
        pro_apellidos varchar (50) not null,
        pro_cedula varchar (10) unique not null,
        pro_telefono varchar(15) default 'DESCONOCIDO',
        pro_email varchar(100) default 'DESCONOCIDO'
    )
    --tabla para auditoria del profesor
    create table profesor_historial(
        id smallint ,
		nombres varchar (50),
        apellidos varchar (50),
        cedula varchar (10),
        telefono varchar(15),
        email varchar(100),
        fecha_auditoria datetime,
        descripcion varchar(100)
    )

    create table estudiante(
        est_id smallint not null primary key identity(1,1),
        est_nombres varchar (50) not null,
        est_apellidos varchar (50) not null,
        est_cedula varchar (10) unique not null,
        est_telefono varchar(15) default 'DESCONOCIDO',
        est_email varchar(100) default 'DESCONOCIDO'
    )
    --tabla para auditoria del estudiante
    create table estudiante_historial(
        id smallint ,
		nombres varchar (50),
        apellidos varchar (50),
        cedula varchar (10),
        telefono varchar(15),
        email varchar(100),
        fecha_auditoria datetime,
        descripcion varchar(100)
    )

    create table clase(
        cla_codigo varchar(20) primary key,
        cla_descripcion varchar(50) unique not null,
        cla_precio real not null,
        profesor_id smallint not null,
        foreign key (profesor_id) references profesor(pro_id)
        on delete cascade on update cascade
    )   

    --tabla para auditoria de clase
    create table clase_historial(
        codigo varchar(20),
        descripcion varchar(50),
        precio real not null,
        profesor_id smallint,
        fecha_auditoria datetime,
        _descripcion varchar(100)
    )          

    create table tutoria(
        tut_id smallint not null primary key identity(1,1),
        tut_fecha date not null,
        tut_hora time(0) not null,
        tut_horas smallint not null,
        tut_total real,
        clase_codigo varchar(20) not null,
        estudiante_id smallint not null,
        foreign key (clase_codigo) references clase(cla_codigo)
        on delete cascade on update cascade,
        foreign key (estudiante_id) references estudiante(est_id)
        on delete cascade on update cascade,
        constraint inicio_tutoria unique(tut_fecha,tut_hora,estudiante_id)
    )

    --tabla para auditoria de tutoria
    create table tutoria_historial(
        id smallint,
        fecha date,
        hora time(0) not null,
        horas smallint not null,
        total real,
        clase_codigo varchar(20),
        estudiante_id smallint,
        fecha_auditoria datetime,
        descripcion varchar(100)
    )

	commit transaction
end try
begin catch
	rollback transaction
end catch
 
 --===========================================================================
----------------PROCEDIMIENTO ALMACENADO DE SALIDA---------------------------
 --===========================================================================
 --Procedimiento de salida que devuelve el precio de la clase
 go

create procedure precio_clase @clase_codigo varchar(20), @costo real output
as
begin
    set @costo=(select cla_precio from clase where cla_codigo=@clase_codigo)
end

 --===========================================================================
----------------PROCEDIMIENTO ALMACENADO---------------------------
 --===========================================================================
go
-- Procedimiento para actualizar administrador
create procedure actualizar_administrador @id smallint, @nombres varchar(50), @apellidos varchar(50),
    @cedula varchar(10), @usuario varchar(50), @clave varchar(50), @telefono varchar(15), @email varchar(100)
as
begin
    update administrador set adm_nombres=@nombres, adm_apellidos=@apellidos, adm_cedula=@cedula,
            adm_usuario=@usuario, adm_clave=@clave, adm_telefono=@telefono, adm_email=@email
    where adm_id=@id
end

go
--Procedimiento para eliminar administrador
create procedure eliminar_administrador @id smallint
as
begin
    delete from administrador where adm_id=@id
end

go
-- Procedimiento para actualizar profesor
create procedure actualizar_profesor @id smallint, @nombres varchar(50), @apellidos varchar(50),
    @cedula varchar(10), @telefono varchar(15), @email varchar(100)
as
begin
    update profesor set pro_nombres=@nombres, pro_apellidos=@apellidos, pro_cedula=@cedula,
            pro_telefono=@telefono, pro_email=@email
    where pro_id=@id
end

go
--Procedimiento para eliminar profesor
create procedure eliminar_profesor @id smallint
as
begin
    delete from profesor where pro_id=@id
end

go
-- Procedimiento para actualizar estudiante
create procedure actualizar_estudiante @id smallint, @nombres varchar(50), @apellidos varchar(50),
    @cedula varchar(10), @telefono varchar(15), @email varchar(100)
as
begin
    update estudiante set est_nombres=@nombres, est_apellidos=@apellidos, est_cedula=@cedula,
            est_telefono=@telefono, est_email=@email
    where est_id=@id
end

go
--Procedimiento para eliminar estudiante
create procedure eliminar_estudiante @id smallint
as
begin
    delete from estudiante where est_id=@id
end

go
--Procedimiento para actualizar clase
create procedure actualizar_clase @codigo varchar(20), @descripcion varchar(50), @precio real, @profesor_id smallint
as
begin
    update clase set cla_descripcion=@descripcion, cla_precio=@precio, profesor_id=@profesor_id
    where cla_codigo=@codigo
end

go
--Procedimiento para eliminar clase
create procedure eliminar_clase @codigo varchar(20)
as
begin
    delete from clase 
    where cla_codigo=@codigo
end

go
--Procedimiento para actualizar tutoria
create procedure actualizar_tutoria @id smallint, @fecha date, @hora time(0), @horas smallint,
    @clase_codigo varchar(20), @estudiante_id smallint
as
begin
    declare @total real, @precio real
        if (datename(dw, @fecha))!='Domingo' and (datename(dw, @fecha))!='Sábado' and (@fecha>=getdate())
        begin

            if (@hora>='8:00:00') and (@hora<='11:00:00') or (@hora>='14:00:00') and (@hora<='17:00:00')
            --utilizo el procedimiento de salida para obtener el precio de la materia
            begin
                exec precio_clase @clase_codigo, @precio output
                set @total=@horas*@precio
                update tutoria set tut_fecha=@fecha, tut_hora=@hora, tut_horas=@horas, tut_total=@total, 
                clase_codigo=@clase_codigo, estudiante_id=@estudiante_id
                where tut_id=@id
            end
        end

        if  (datename(dw, @fecha))='Sábado' and (@fecha>=getdate()) 
        begin

            if (@hora>='8:00:00') and (@hora<='11:00:00')
            --utilizo el procedimiento de salida para obtener el precio de la materia
            begin
                exec precio_clase @clase_codigo, @precio output
                set @total=@horas*@precio
                update tutoria set tut_fecha=@fecha, tut_hora=@hora, tut_horas=@horas, tut_total=@total,
                clase_codigo=@clase_codigo, estudiante_id=@estudiante_id
                where tut_id=@id
            end
        end        
end

go
--Procedimiento para eliminar tutoria
create procedure eliminar_tutoria @id smallint
as
begin
    delete from tutoria 
    where tut_id=@id
end

go
--Procedimiento que ingresa la tutoria si cumple con lo establecido caso contrario no la ingresa
create procedure ingresar_tutoria @fecha date, @hora time(0), @horas smallint,
                                  @clase_codigo varchar(20), @estudiante_id smallint
as 
begin

        declare @total real, @precio real
        if (datename(dw, @fecha))!='Domingo' and (datename(dw, @fecha))!='Sábado' and (@fecha>=getdate())
        begin

            if (@hora>='8:00:00') and (@hora<='11:00:00') or (@hora>='14:00:00') and (@hora<='17:00:00')
            --utilizo el procedimiento de salida para obtener el precio de la materia
            begin
                exec precio_clase @clase_codigo, @precio output
                set @total=@horas*@precio
                insert into tutoria(tut_fecha, tut_hora, tut_horas, tut_total, clase_codigo, estudiante_id) 
                            values(@fecha, @hora, @horas, @total, @clase_codigo, @estudiante_id)
            end
        end

        if  (datename(dw, @fecha))='Sábado' and (@fecha>=getdate()) 
        begin

            if (@hora>='8:00:00') and (@hora<='11:00:00')
            --utilizo el procedimiento de salida para obtener el precio de la materia
            begin
                exec precio_clase @clase_codigo, @precio output
                set @total=@horas*@precio
                insert into tutoria(tut_fecha, tut_hora, tut_horas, tut_total, clase_codigo, estudiante_id) 
                            values(@fecha, @hora, @horas, @total, @clase_codigo, @estudiante_id)
            end
        end        
end

go 
--Procedimiento para consultar cuantas tutorías hay en una determinada fecha
create procedure tutorias_por_dia @fecha date
as 
begin
    select t.tut_fecha as feha,t.tut_hora as hora, c.cla_descripcion as materia,
	(p.pro_nombres+' '+p.pro_apellidos)as profesor,count(t.estudiante_id) as estudiantes
    from tutoria as t inner join estudiante e on t.estudiante_id=e.est_id
    inner join clase c on t.clase_codigo=c.cla_codigo
    inner join profesor p on c.profesor_id=p.pro_id
    where t.tut_fecha=@fecha
    group by  t.tut_fecha,t.tut_hora, c.cla_descripcion,p.pro_nombres,p.pro_apellidos
	order by t.tut_hora
end

go
 --===========================================================================
----------------VISTAS--------------------------------------------------
 --===========================================================================

--Vista de administradores
create view administrador_V
as 
	select adm_id as id, adm_nombres as Nombres,adm_apellidos as Apellidos, adm_cedula as Cedula,
           adm_usuario as Usuario, adm_telefono as Telefono , adm_email as Email
    from administrador
go
--Vista de estudiantes
create view estudiante_V
as
    select est_id as id, est_nombres as Nombres, est_apellidos as Apellidos,est_cedula as Cedula, 
           est_telefono as Telefono, est_email as Email
    from estudiante
go
--Vista de profesores
create view profesor_V
as  
    select pro_id as id, pro_nombres as Nombres, pro_apellidos as Apellidos, pro_cedula as Cedula,
           pro_telefono as Telefono, pro_email as Email
    from profesor
go
--Vista de clases
create view clase_V
as
    select c.cla_codigo as Codigo, c.cla_descripcion as Descripcion, c.cla_precio as Precio, 
        profesor_id as Profesor_id
    from clase as c

go
--Vista de tutorías
create view tutorias_V
as  
    select tut_id as id, tut_fecha as Fecha,tut_hora as Hora, tut_horas as Horas, clase_codigo as Clase_codigo,
	    estudiante_id as Estudiante_id, tut_total as Total
    from tutoria 

go 
--Vista de tutorías
create view tutorias_general_V
as  
    select t.tut_fecha as Feha,t.tut_hora as Hora, t.tut_horas as Horas, c.cla_descripcion as Materia,
	(p.pro_nombres+' '+p.pro_apellidos)as Profesor,count(t.estudiante_id) as Estudiantes, sum(t.tut_total) as Total
    from tutoria as t inner join estudiante e on t.estudiante_id=e.est_id
    inner join clase c on t.clase_codigo=c.cla_codigo
    inner join profesor p on c.profesor_id=p.pro_id
    group by t.tut_fecha,t.tut_hora, t.tut_horas, c.cla_descripcion,p.pro_nombres,p.pro_apellidos, t.tut_total
    
 --===========================================================================
----------------CURSOR DENTRO DE UN PROCEDIMIENTO---------------------------
 --===========================================================================

go
--Creamos un Cursor dentro de un procedimiento almacenado
create procedure eliminar_registros_tutoria
as
begin
	--Creo un try catch y una transacción
	begin try
		begin transaction
		declare @fecha date, @id smallint
		--Declaro el cursor
		declare cursor_tutoria cursor
		--seleccionamos los parametros que vamos a utilizar
		for select tut_id, tut_fecha from tutoria
		--abrimos el cursor
		open cursor_tutoria
		--selecionamos la primera fila
		fetch next from cursor_tutoria into @id, @fecha
		--recorremos toda la tabla
		while(@@fetch_status = 0)
		begin
			--si la fecha es menor a la actual se elimina esa fila
			if @fecha < getdate()
			begin
				delete from tutoria where tut_id=@id
			end
			fetch next from cursor_tutoria into @id, @fecha
		end
		--ceramos el cursor
		close cursor_tutoria
		--borramos el espacio de memoria
		deallocate cursor_tutoria
		commit 
	end try
	begin catch
		rollback transaction
	end catch
end

 --===========================================================================
----------------TRIGGERS----------------------------------------------
 --===========================================================================

go
--guarda las inserciones de la tabla administrador
create trigger TR_administrador_insertar
on administrador
for insert
as
begin
    set nocount on
    insert into administrador_historial
    select adm_id,adm_nombres,adm_apellidos,adm_cedula,adm_usuario,adm_clave, 
    adm_telefono,adm_email,getdate(),'Se insetaron datos'
    from inserted
end

go
--almacena las filas eliminadas de la tabla administrador
create trigger TR_administrador_eliminar
on administrador
for delete
as
begin
    set nocount on
    insert into administrador_historial
    select adm_id,adm_nombres,adm_apellidos,adm_cedula,adm_usuario,adm_clave, 
    adm_telefono,adm_email,getdate(),'Se eliminaron datos'
    from deleted
end

go
--almacena la fila antes de ser actualizada de la tabla administrador
create trigger TR_administrador_actualizar
on administrador
for update
as
begin
    set nocount on
    insert into administrador_historial
    select adm_id,adm_nombres,adm_apellidos,adm_cedula,adm_usuario,adm_clave, 
    adm_telefono,adm_email,getdate(),'Se actualizaron datos'
    from inserted
end
---------------------------------------------------------------------
go
--guarda las inserciones de la tabla profesor
create trigger TR_profesor_insertar
on profesor
for insert
as
begin
    set nocount on
    insert into profesor_historial
    select pro_id,pro_nombres,pro_apellidos,pro_cedula, 
    pro_telefono,pro_email,getdate(),'Se insetaron datos'
    from inserted
end

go
--almacena las filas eliminadas de la tabla profesor
create trigger TR_profesor_eliminar
on profesor
for delete
as
begin
    set nocount on
    insert into profesor_historial
    select pro_id,pro_nombres,pro_apellidos,pro_cedula, 
    pro_telefono,pro_email,getdate(),'Se eliminaron datos'
    from deleted
end

go
--almacena la fila antes de ser actualizada de la tabla profesor
create trigger TR_profesor_actualizar
on profesor
for update
as
begin
    set nocount on
    insert into profesor_historial
    select pro_id,pro_nombres,pro_apellidos,pro_cedula, 
    pro_telefono,pro_email,getdate(),'Se actualizaron datos'
    from inserted
end

go

---------------------------------------------------------------------------------------
--guarda las inserciones de la tabla estudiante
create trigger TR_estudiante_insertar
on estudiante
for insert
as
begin
    set nocount on
    insert into estudiante_historial
    select est_id,est_nombres,est_apellidos,est_cedula, 
    est_telefono,est_email,getdate(),'Se insetaron datos'
    from inserted
end

go
--almacena las filas eliminadas de la tabla estudiante
create trigger TR_estudiante_eliminar
on estudiante
for delete
as
begin
    set nocount on
    insert into estudiante_historial
    select est_id,est_nombres,est_apellidos,est_cedula, 
    est_telefono,est_email,getdate(),'Se eliminaron datos'
    from deleted
end

go
--almacena la fila antes de ser actualizada de la tabla estudiante
create trigger TR_estudiante_actualizar
on estudiante
for update
as
begin
    set nocount on
    insert into estudiante_historial
    select est_id,est_nombres,est_apellidos,est_cedula, 
    est_telefono,est_email,getdate(),'Se actualizaron datos'
    from inserted
end

go
-------------------------------------------------------------------------------
--guarda las inserciones de la tabla clase
create trigger TR_clase_insertar
on clase
for insert
as
begin
    set nocount on
    insert into clase_historial
    select cla_codigo,cla_descripcion,cla_precio,
    profesor_id, getdate(),'Se insetaron datos'
    from inserted
end

go
--almacena las filas eliminadas de la tabla clase
create trigger TR_clase_eliminar
on clase
for delete
as
begin
    set nocount on
    insert into clase_historial
    select cla_codigo,cla_descripcion,cla_precio,
    profesor_id, getdate(),'Se eliminaron datos'
    from deleted
end

go
--almacena la fila antes de ser actualizada de la tabla clase
create trigger TR_clase_actualizar
on clase
for update
as
begin
    set nocount on
    insert into clase_historial
    select cla_codigo,cla_descripcion,cla_precio,
    profesor_id, getdate(),'Se actualizaron datos'
    from inserted
end

go
-----------------------------------------------------------------------------
--guarda las inserciones de la tabla tutoria
create trigger TR_tutoria_insertar
on tutoria
for insert
as
begin
    set nocount on
    insert into tutoria_historial
    select tut_id,tut_fecha,tut_hora,tut_horas,tut_total,
    clase_codigo, estudiante_id,getdate(),'Se insetaron datos'
    from inserted
end

go
--almacena las filas eliminadas de la tabla clase
create trigger TR_tutoria_eliminar
on tutoria
for delete
as
begin
    set nocount on
    insert into tutoria_historial
    select tut_id,tut_fecha,tut_hora,tut_horas,tut_total,
    clase_codigo, estudiante_id,getdate(),'Se eliminaron datos'
    from deleted
end

go
--almacena la fila antes de ser actualizada de la tabla clase
create trigger TR_tutoria_actualizar
on tutoria
for update
as
begin
    set nocount on
    insert into tutoria_historial
    select tut_id,tut_fecha,tut_hora,tut_horas,tut_total,
    clase_codigo, estudiante_id,getdate(),'Se actualizaron datos'
    from inserted
end

 --===========================================================================
----------------INDICES NO CLUSTERED---------------------------
 --===========================================================================

--indice del administrador
go
create nonclustered index idx_administrador
on administrador (adm_id, adm_nombres, adm_apellidos, adm_cedula, adm_usuario, adm_telefono, adm_email)

go
--indice del profesor
create nonclustered index idx_profesor
on profesor (pro_id, pro_nombres, pro_apellidos, pro_cedula, pro_telefono, pro_email)

go
--indice del estudiante
create nonclustered index idx_estudiante
on estudiante (est_id, est_nombres, est_apellidos, est_cedula, est_telefono, est_email)

go
--indice de clase
create nonclustered index idx_clase
on clase (cla_codigo, cla_descripcion, cla_precio, profesor_id)

go
--indice del estudiante
create nonclustered index idx_tutoria
on tutoria (tut_fecha, tut_hora, clase_codigo, estudiante_id)

go
---Ingreso Administrador
insert into administrador(adm_nombres, adm_apellidos, adm_cedula, adm_usuario, adm_clave, adm_telefono, adm_email)
values('Elizabeth Estefania', 'Martillo Arebalo', '1302927473', 'admin', 'admin123', '098237834', 'estefania12099@gmail.com')
insert into administrador(adm_nombres, adm_apellidos, adm_cedula, adm_usuario, adm_clave, adm_telefono, adm_email)
values('Linda Isabel', 'Sanchez Granizo', '1323992332', 'linda', 'linda123', '0983334756', 'linda@gmail.com')

go

--Ingreso estudiantes
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Maria Carmelina', 'Loor Palma', '1308302262')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Maria Virginia', 'Mendoza Loor', '1313928687')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Abel Jose', 'Cedeño Mendoza', '1322316961')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Mario Jose', 'Ubilla Aguilar', '1672229812')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Maria Carmelina', 'Vaca Vaca', '1308302222')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Brando Rafael', 'Mero Cepeda', '1023410101')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Jose Antonio', 'Macias Macias','1390123545')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Mayerly Juliana', 'Jama Espinosa', '1622652384')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Mariuxi Nahomi', 'Mendoza Palma', '1311112262')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Abel Jose', 'Cedeño Mendoza', '1010455101')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Mario Jose', 'Ubilla Aguilar','1323452341')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Misahel Luis', 'Barcia Espinales', '1306842341')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Juan Joel', 'Pico Zornosa', '1307772262')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Brando Joel', 'Mero Guro', '1312384632')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Jose Jose', 'Zambrano Zambrano', '1315554443')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Maria Amelia', 'Perez Lino', '1374446542')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Maria Carmelina', 'Loor Palma', '1308355262')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Jhonnathan David', 'Lopez Bravo', '1702832751')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Domenica Fernanda', 'Pico Pico', '1283462731')
insert into estudiante(est_nombres, est_apellidos, est_cedula) values('Luis Joel', 'Mendez Loor', '1232435435')

go
--Ingreso profesores
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Maria Fernanda', 'Méndez Loor', '131227328')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Maria Carmelina', 'Loor Palma', '130831162')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Maria Virginia', 'Mendoza Loor', '1313928687')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Abel Jose', 'Cedeño Mendoza', '1322316961')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Mario Jose', 'Ubilla Aguilar', '1672229812')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula)values('Maria Carmelina', 'Vaca Vaca', '1308302222')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Brando Rafael', 'Mero Cepeda', '1023410101')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Jose Antonio', 'Macias Macias','1390123545')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Mayerly Juliana', 'Jama Espinosa', '1622652384')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Mariuxi Nahomi', 'Mendoza Palma', '1311112262')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula)values('Abel Jose', 'Cedeño Mendoza', '1010455101')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Mario Jose', 'Ubilla Aguilar','1323452341')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Misahel Luis', 'Barcia Espinales', '1306842341')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Juan Joel', 'Pico Zornosa', '1307772262')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula)values('Brando Joel', 'Mero Guro', '1312384632')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula)values('Jose Jose', 'Zambrano Zambrano', '1315554443')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Maria Amelia', 'Perez Lino', '1374446542')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Maria Carmelina', 'Loor Palma', '1308302262')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula)values('Jhonnathan David', 'Lopez Bravo', '1702832751')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Domenica Fernanda', 'Pico Pico', '1283462731')
insert into profesor(pro_nombres, pro_apellidos, pro_cedula) values('Luis Joel', 'Mendez Loor', '1232435435')

go
--Ingreso Clases
insert into clase values('MAT-1','Matematica',5,1)
insert into clase values('QUI-1','Quimica General',4.5,2)
insert into clase values('QUI-2','Quimica analitica',5,3)
insert into clase values('MIC-2','Microbiologia',5,4)
insert into clase values('TER-1','Termodinamica',5,5)
insert into clase values('ELC-2','Electricidad',4.5,6)
insert into clase values('POO-1','Programacion',10,7)
insert into clase values('CAL-1','Calculo diferencial',8,8)
insert into clase values('CAL-2','Calculo Integral',5,9)
insert into clase values('EST-1','Estadistica',5,10)
insert into clase values('EST-2','Estadistica 2',5,11)
insert into clase values('RED-1','REDES',10,12)
insert into clase values('FIC-1','Fisica General',10,13)
insert into clase values('ETD-1','Estructura de datos',9,14)
insert into clase values('MET-1','Metodos numericos',8,15)
insert into clase values('ING-1','Ingles',5,16)
insert into clase values('REQ-1','Ingenieria de requisitos',6,17)
insert into clase values('GEO-2','Geometria',5,18)
insert into clase values('MTI-1','Metodologia de la investigacion',5,19)
insert into clase values('MDD-1','Mineria de datos',9,20)

go
--Ingreso Tutorias
exec ingresar_tutoria '2020-12-19','14:00:00',2,'MAT-1',20
exec ingresar_tutoria '2020-12-21','14:00:00',2,'QUI-1',19
exec ingresar_tutoria '2020-12-22','8:00:00',2,'QUI-2',18
exec ingresar_tutoria '2020-12-23','10:00:00',2,'MIC-2',17
exec ingresar_tutoria '2020-12-23','14:00:00',2,'TER-1',16
exec ingresar_tutoria '2020-12-24','14:00:00',2,'ELC-2',15
exec ingresar_tutoria '2020-12-24','8:00:00',2,'POO-1',14
exec ingresar_tutoria '2020-12-24','10:00:00',2,'CAL-1',13
exec ingresar_tutoria '2020-12-25','14:00:00',2,'CAL-2',12
exec ingresar_tutoria '2020-12-28','14:00:00',2,'EST-1',11
exec ingresar_tutoria '2020-12-26','8:00:00',2,'EST-2',10
exec ingresar_tutoria '2020-12-28','10:00:00',2,'RED-1',9
exec ingresar_tutoria '2020-12-29','14:00:00',2,'FIC-1',8
exec ingresar_tutoria '2020-12-29','14:00:00',2,'ETD-1',7
exec ingresar_tutoria '2020-12-29','8:00:00',2,'MET-1',6
exec ingresar_tutoria '2020-12-29','10:00:00',2,'ING-1',5
exec ingresar_tutoria '2020-12-30','14:00:00',2,'REQ-1',4
exec ingresar_tutoria '2020-12-30','14:00:00',2,'GEO-2',3
exec ingresar_tutoria '2020-12-30','8:00:00',2,'MTI-1',2
exec ingresar_tutoria '2020-12-30','10:00:00',2,'MDD-1',1