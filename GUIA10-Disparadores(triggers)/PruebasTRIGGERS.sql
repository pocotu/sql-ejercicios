create trigger tr_Prestamo_ReferenciaIntegridad
  on PRESTAMO
  for INSERT
as
begin
-- Recuperar el código del prestatario del registro insertado
declare @CodPrestatario varchar(15);
select @CodPrestatario = CodPrestatario
  from INSERTED;

-- Verificar si CodPrestatario existe en la tabla PRESTATARIO_RURAL.
if not EXISTS (select CodPrestatario 
                 from PRESTATARIO_RURAL
                 where CodPrestatario = @CodPrestatario) 
  -- Verificar si CodPrestatario existe en la tabla PRESTATARIO_CIUDAD.
  if not EXISTS (select CodPrestatario 
                   from PRESTATARIO_CIUDAD
                   where CodPrestatario = @CodPrestatario) 
    -- Deshacer o cancelar la insersión del registro en la tabla PRESTAMO
    ROLLBACK;
end;

----------------------------------------------------------------
create trigger tr_Prestatario_Rural_ModificarCodPrestatario
  on PRESTATARIO_RURAL
  for UPDATE
as
begin
-- Recuperar el código del prestatario antes de la modificación y después de
-- la modificación.
declare @CodPrestatarioAntes varchar(15);
select @CodPrestatarioAntes = CodPrestatario 
  from DELETED;

declare @CodPrestatarioDespues varchar(15);
select @CodPrestatarioDespues = CodPrestatario 
  from INSERTED;

-- Verificar si se modificó el código de prestatario
if @CodPrestatarioAntes <> @CodPrestatarioDespues
  -- Verificar si existen préstamos para @CodPrestatarioAntes 
  if EXISTS (select CodPrestatario 
               from PRESTAMO
               where CodPrestatario = @CodPrestatarioAntes) 
     -- Existen prestamos, luego actualizar el atributo CodPrestatario 
     UpDate PRESTAMO
       set CodPrestatario = @CodPrestatarioDespues
       where CodPrestatario = @CodPrestatarioAntes;
end;

------------------------------------------
create trigger tr_Prestamo_Restriccion_LimitePrestamo
  on PRESTAMO
  for INSERT

as

begin
-- Recuperar el código del prestatario y el importe del registro insertado
declare @CodPrestatario varchar(15);
declare @ImportePrestamo numeric(15,2);
select @CodPrestatario = CodPrestatario, @ImportePrestamo = ImportePrestamo
  from INSERTED;

-- Recuperar ”LimitePrestamo” del prestatario @CodPrestatario, 
-- haciendo uso del procedimiento almacenado sp_LimitePrestamo
declare @LimitePrestamo numeric(15,2);
exec sp_LimitePrestamo @CodPrestatario, @LimitePrestamo OUTPUT;

-- Verificar si importe de préstamo es permitido o no
if @ImportePrestamo > @LimitePrestamo
  -- Deshacer o cancelar el préstamo
  ROLLBACK;

end;

-------------------------------------------------------------
create procedure sp_LimitePrestamo 
                 @CodPrestatario varchar(15), 
                 @LimitePrestamo Numeric(15,2) OUTPUT
as
begin
-- Inicializar @LimitePrestamo
set @LimitePrestamo = 0;

-- Recuperar Limite de préstamo asumiendo que @CodPrestatario pertenece a la
-- tabla PRESTATARIO_RURAL
select @LimitePrestamo = LimitePrestamo
  from PRESTATARIO_RURAL
  where CodPrestatario = @CodPrestatario;

-- Si @LimitePrestamo = 0, entonces @CodPrestatario posiblemente pertenece a la
-- tabla PRESTATARIO_CIUDAD
if @LimitePrestamo = 0
select @LimitePrestamo = LimitePrestamo
  from PRESTATARIO_RURAL
  where CodPrestatario = @CodPrestatario;
end;

---------------------------------------------------
create trigger tr_Prestatario_Insert
  on PRESTATARIO_RURAL
  for INSERT
as
begin
-- Recuperar el código del prestatario y el importe del registro insertado
INSERT INTO HISTORICO(Usuario, Fecha, Tabla, Operacion, Observaciones)
  values(user, GetDate(),’PRESTATARIO’,’INSERT’,NULL);
end;

------------------------------------------------------------
-- ACTIVIDADES ---
------------------------------------------------------------
create trigger tr_Prestatario_Ciudad_ModificarCodPrestatario
on PRESTATARIO_CIUDAD
for UPDATE
as
begin
    -- Recuperar el código del prestatario antes y después de la modificación
    declare @CodPrestatarioAntes varchar(15);
    select @CodPrestatarioAntes = CodPrestatario 
      from DELETED;

    declare @CodPrestatarioDespues varchar(15);
    select @CodPrestatarioDespues = CodPrestatario 
      from INSERTED;

    -- Verificar si se modificO el código de prestatario
    if @CodPrestatarioAntes <> @CodPrestatarioDespues
        -- Verificar si existen prEstamos para @CodPrestatarioAntes 
        if EXISTS (select CodPrestatario 
                   from PRESTAMO
                   where CodPrestatario = @CodPrestatarioAntes) 
            -- Existen préstamos, luego actualizar el atributo CodPrestatario en PRESTAMO
            UPDATE PRESTAMO
            set CodPrestatario = @CodPrestatarioDespues
            where CodPrestatario = @CodPrestatarioAntes;
end;

-- PRUEBAS
-- Insertar un prestatario en PRESTATARIO_CIUDAD
INSERT INTO PRESTATARIO_CIUDAD (CodPrestatario, Nombres, Direccion, Telefono, LimitePrestamo)
VALUES ('P08', 'Perez Gomez Maria', 'Calle Lima 123', '123456789', 5000);

-- Insertar un préstamo asociado a 'P08' en la tabla PRESTAMO
INSERT INTO PRESTAMO (DocPrestamo, FechaPrestamo, ImportePrestamo, FechaVcto, CodPrestatario)
VALUES ('PR10010', '2024-11-11', 2000.00, '2024-12-11', 'P08');

-- Modificar el CodPrestatario en PRESTATARIO_CIUDAD
UPDATE PRESTATARIO_CIUDAD
SET CodPrestatario = 'P08A'
WHERE CodPrestatario = 'P08';

-- Verificar si el CodPrestatario se actualizó en la tabla PRESTAMO
SELECT * FROM PRESTAMO WHERE DocPrestamo = 'PR10010';

