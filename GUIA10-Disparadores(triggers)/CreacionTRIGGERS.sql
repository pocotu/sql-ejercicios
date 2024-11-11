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
