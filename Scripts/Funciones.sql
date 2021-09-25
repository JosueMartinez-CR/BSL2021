USE [Banco]
GO


--FUNCIONES BASICAS DE BENEFICIARIO
CREATE PROCEDURE InsertarBeneficiario (
	@NumeroCuenta varchar(32),
	@Identificacion varchar(32),
	@Parentesco int, 
	@Porcentaje int
	)
AS
BEGIN
	IF EXISTS (SELECT * FROM [dbo].[Persona] WHERE [ValorDocumentoIdentidad]=@Identificacion)
		BEGIN

		-- Mapeo @@TempBeneficiario-Beneficiario
		INSERT INTO [dbo].[Beneficiario](
			[IdentificacionCliente], 
			[IdentificacionCuenta], 
			[NumeroCuenta], 
			[Porcentaje],
			[ValorDocumentoIdentidadBeneficiario],
			[ValorParentesco]
			)
		SELECT C.IdentificacionCliente,
			C.IdCuentaAhorro,
			C.NumeroCuenta,
			@Porcentaje,
			@Identificacion,
			@Parentesco
		FROM [dbo].[CuentaAhorro] C
		WHERE @NumeroCuenta=C.NumeroCuenta

		SELECT * FROM [dbo].[Beneficiario] WHERE [ValorDocumentoIdentidadBeneficiario]='777777'

		SELECT * FROM [dbo].[Persona] WHERE	[ValorDocumentoIdentidad]=@Identificacion

		END

	ELSE 
		BEGIN

		INSERT INTO [dbo].[Persona](
			[Nombre],
			[ValorDocumentoIdentidad],
			[TipoIdentidad],
			[FechaDeNacimiento],
			[Email],
			[Telefono1],
			[Telefono2])
		SELECT 
			'No conocido',					
			@Identificacion,								
			1,							
			'1901-01-01',
			'na@na.com',
			'00000000',					
			'00000000'

		-- Mapeo @@TempBeneficiario-Beneficiario
		INSERT INTO [dbo].[Beneficiario](
			[IdentificacionCliente], 
			[IdentificacionCuenta], 
			[NumeroCuenta], 
			[Porcentaje],
			[ValorDocumentoIdentidadBeneficiario],
			[ValorParentesco]
			)
		SELECT C.IdentificacionCliente,
			C.IdCuentaAhorro,
			C.NumeroCuenta,
			@Porcentaje,
			@Identificacion,
			@Parentesco
		FROM [dbo].[CuentaAhorro] C
		WHERE @NumeroCuenta=C.NumeroCuenta

		END
END;
GO

CREATE PROCEDURE EditarBeneficiario (
	@IdentificacionAntigua varchar(32),
	@Nombre varchar(64),
	@Identificacion varchar(32),
	@Parentesco int, 
	@Porcentaje int,
	@FechaNacimiento varchar(32),
	@Email varchar(32),
	@Telefono1 int,
	@Telefono2 int
	)
AS
BEGIN

	/*USE Banco
	GO

	DECLARE @IdentificacionAntigua varchar(32) = '106261426'
	DECLARE @Nombre varchar(64)='PANCHO'
	DECLARE @Identificacion varchar(32)='88888888'
	DECLARE @Parentesco int=2
	DECLARE @Porcentaje int=0
	DECLARE @FechaNacimiento varchar(32)='2000-01-01'
	DECLARE @Email varchar(32)='pancho@pancho.com'
	DECLARE @Telefono1 int='000000'
	DECLARE @Telefono2 int='000000'
	*/

	DECLARE @IdBuscado2 int;
	SELECT @IdBuscado2 = B.IdPersona
	FROM [dbo].[Persona] B
	WHERE B.ValorDocumentoIdentidad=@IdentificacionAntigua;

	UPDATE [dbo].[Persona]
	SET [Nombre]=@Nombre,
		[ValorDocumentoIdentidad]=@Identificacion,
		[FechaDeNacimiento]=@FechaNacimiento,
		[Email]=@Email,
		[Telefono1]=@Telefono1,
		[Telefono2]=@Telefono2
	WHERE [IdPersona]=@IdBuscado2

	DECLARE @IdBuscado int;
	SELECT @IdBuscado = B.IdBeneficiario
	FROM [dbo].[Beneficiario] B
	WHERE B.ValorDocumentoIdentidadBeneficiario=@IdentificacionAntigua;

	UPDATE [dbo].[Beneficiario]
	SET [Porcentaje]=@Porcentaje,
		[ValorDocumentoIdentidadBeneficiario]=@Identificacion,
		[ValorParentesco]=@Parentesco
	WHERE [IdBeneficiario]=@IdBuscado

END;
GO


CREATE PROCEDURE EliminarBeneficiario (@Identificacion varchar(32), @value int)
AS
BEGIN
	DECLARE @CurrentTime DATE=GETDATE();

	UPDATE [dbo].[Beneficiario]
	SET [Activo]=@value,
		[Porcentaje]=@value,
		[FechaDesactivacion]=@CurrentTime
	WHERE [ValorDocumentoIdentidadBeneficiario]=@Identificacion

	SELECT * FROM Beneficiario
END;
GO

-- SP BENEFICIARIO
CREATE PROCEDURE GetTotalBeneficiarios (@Identificacion varchar(32))
AS
BEGIN
	DECLARE @IdCliente int;
	SELECT @IdCliente = P.IdPersona
	FROM dbo.Persona P
	WHERE P.ValorDocumentoIdentidad=@Identificacion;

	SELECT COUNT(*) FROM [dbo].[Beneficiario] 
	WHERE [IdentificacionCliente]=@IdCliente
	AND [Activo]=1
END;
GO


CREATE PROCEDURE GetBeneficiariosActivosDeCliente (@Identificacion varchar(32))
AS
BEGIN

	DECLARE @IdCliente int;
	SELECT @IdCliente = P.IdPersona
	FROM [dbo].[Persona] P
	WHERE P.ValorDocumentoIdentidad=@Identificacion;

	DECLARE @TempBeneficiario TABLE(
		NumeroCuenta varchar(32),
		Nombre varchar(64),
		Identificacion varchar(32), 
		Parentesco int, 
		Porcentaje int,
		FechaNacimiento varchar(32),
		Email varchar(32),
		Telefono1 int,
		Telefono2 int,
		Activo bit
	)
	INSERT INTO @TempBeneficiario(
		Identificacion,
		NumeroCuenta,
		Parentesco, 
		Porcentaje,
		Activo
	)
	SELECT
		B.ValorDocumentoIdentidadBeneficiario,
		B.NumeroCuenta,
		B.ValorParentesco,
		B.Porcentaje,
		B.Activo
	FROM [dbo].[Beneficiario] B
	WHERE B.IdentificacionCliente=@IdCliente AND Activo=1
	
	SELECT
		T.Identificacion,
		T.NumeroCuenta,
		T.Parentesco, 
		T.Porcentaje,
		P.[Nombre],
		P.[FechaDeNacimiento],
		P.[Email],
		P.[Telefono1],
		P.[Telefono2],
		T.Activo
	FROM @TempBeneficiario T INNER JOIN [dbo].[Persona] P ON T.Identificacion=P.[ValorDocumentoIdentidad]
END;
GO		


CREATE PROCEDURE GetBeneficiariosDeCliente (@Identificacion varchar(32))
AS
BEGIN

	DECLARE @IdCliente int;
	SELECT @IdCliente = P.IdPersona
	FROM [dbo].[Persona] P
	WHERE P.ValorDocumentoIdentidad=@Identificacion;

	DECLARE @TempBeneficiario TABLE(
		NumeroCuenta varchar(32),
		Nombre varchar(64),
		Identificacion varchar(32), 
		Parentesco int, 
		Porcentaje int,
		FechaNacimiento varchar(32),
		Email varchar(32),
		Telefono1 int,
		Telefono2 int,
		Activo bit
	)
	INSERT INTO @TempBeneficiario(
		Identificacion,
		NumeroCuenta,
		Parentesco, 
		Porcentaje,
		Activo
	)
	SELECT
		B.ValorDocumentoIdentidadBeneficiario,
		B.NumeroCuenta,
		B.ValorParentesco,
		B.Porcentaje,
		B.Activo
	FROM [dbo].[Beneficiario] B
	WHERE B.IdentificacionCliente=@IdCliente
	
	SELECT
		T.Identificacion,
		T.NumeroCuenta,
		T.Parentesco, 
		T.Porcentaje,
		P.[Nombre],
		P.[FechaDeNacimiento],
		P.[Email],
		P.[Telefono1],
		P.[Telefono2],
		T.Activo
	FROM @TempBeneficiario T INNER JOIN [dbo].[Persona] P ON T.Identificacion=P.[ValorDocumentoIdentidad]
END;
GO	


CREATE PROCEDURE GetBeneficiario (@Identificacion varchar(32))
AS
BEGIN
	DECLARE @TempBeneficiario TABLE(
		NumeroCuenta varchar(32),
		Nombre varchar(64),
		Identificacion varchar(32), 
		Parentesco int, 
		Porcentaje int,
		FechaNacimiento varchar(32),
		Email varchar(32),
		Telefono1 int,
		Telefono2 int,
		Activo bit
	)
	INSERT INTO @TempBeneficiario(
		Identificacion,
		NumeroCuenta,
		Parentesco, 
		Porcentaje,
		Activo
	)
	SELECT
		@Identificacion,
		B.NumeroCuenta,
		B.ValorParentesco,
		B.Porcentaje,
		B.Activo
	FROM [dbo].[Beneficiario] B
	WHERE B.ValorDocumentoIdentidadBeneficiario=@Identificacion
	
	SELECT
		T.Identificacion,
		T.NumeroCuenta,
		T.Parentesco, 
		T.Porcentaje,
		P.[Nombre],
		P.[FechaDeNacimiento],
		P.[Email],
		P.[Telefono1],
		P.[Telefono2],
		T.Activo
	FROM @TempBeneficiario T INNER JOIN [dbo].[Persona] P ON T.Identificacion=P.[ValorDocumentoIdentidad]
END;
GO	


CREATE PROCEDURE GetTodosBeneficiarios
AS
BEGIN
	DECLARE @TempBeneficiario TABLE(
		NumeroCuenta varchar(32),
		Nombre varchar(64),
		Identificacion varchar(32), 
		Parentesco int, 
		Porcentaje int,
		FechaNacimiento varchar(32),
		Email varchar(32),
		Telefono1 int,
		Telefono2 int,
		Activo bit
	)
	INSERT INTO @TempBeneficiario(
		Identificacion,
		NumeroCuenta,
		Parentesco, 
		Porcentaje,
		Activo
	)
	SELECT
		B.ValorDocumentoIdentidadBeneficiario,
		B.NumeroCuenta,
		B.ValorParentesco,
		B.Porcentaje,
		B.Activo
	FROM [dbo].[Beneficiario] B
	
	SELECT
		T.Identificacion,
		T.NumeroCuenta,
		T.Parentesco, 
		T.Porcentaje,
		P.[Nombre],
		P.[FechaDeNacimiento],
		P.[Email],
		P.[Telefono1],
		P.[Telefono2],
		T.Activo
	FROM @TempBeneficiario T INNER JOIN [dbo].[Persona] P ON T.Identificacion=P.[ValorDocumentoIdentidad]
END;
GO


-- CLIENTES

CREATE PROCEDURE GetCliente(@Identificacion varchar(32))
AS
BEGIN
	SELECT * FROM [dbo].[Persona] WHERE [ValorDocumentoIdentidad]=@Identificacion
END;
GO


CREATE PROCEDURE GetTodosClientes
AS
BEGIN
	SELECT * FROM [dbo].[Persona]
END;
GO


-- CUENTAS

CREATE PROCEDURE GetCuenta(@NumeroCuenta varchar(32))
AS
BEGIN
	SELECT * FROM [dbo].[CuentaAhorro] WHERE [NumeroCuenta]=@NumeroCuenta
END;
GO


CREATE PROCEDURE GetCuentasDeCliente(@Identificacion varchar(32))
AS
BEGIN
	DECLARE @IdCliente int;
	SELECT @IdCliente = P.IdPersona
	FROM [dbo].[Persona] P
	WHERE P.ValorDocumentoIdentidad=@Identificacion;
	
	SELECT * FROM [dbo].[CuentaAhorro] WHERE [IdentificacionCliente]=@IdCliente
END;
GO


CREATE PROCEDURE GetTodasCuentas
AS
BEGIN
	SELECT * FROM [dbo].[CuentaAhorro]
END;
GO


-- USUARIOS

CREATE PROCEDURE GetTodosUsuarios
AS
BEGIN
	SELECT * FROM dbo.Usuario;
END;
GO

CREATE PROCEDURE GetUser (@Identificacion varchar(32))
AS
BEGIN 
	SELECT * FROM [dbo].[Usuario] WHERE [ValorDocumentoIdentidad] =	@Identificacion
END;
GO


CREATE PROCEDURE GetUsuariosPuedeVer(@Usuario varchar(16))
AS
BEGIN
	SELECT [NumeroCuenta] FROM [dbo].[UsuarioPuedeVer]
END;
GO


-- PORCENTAJES

CREATE PROCEDURE GetTotalPorcentajes (@Identificacion varchar(32))
AS
BEGIN
		DECLARE @IdCliente int;
		SELECT @IdCliente = P.IdPersona
		FROM [dbo].[Persona] P
		WHERE P.ValorDocumentoIdentidad=@Identificacion;

	SELECT SUM ([Porcentaje]) FROM [dbo].[Beneficiario] WHERE [IdentificacionCliente]=@IdCliente
END;
GO


-- PARENTESCOS

CREATE PROCEDURE GetTodosParentescos
AS
BEGIN
	SELECT * FROM [dbo].[Parentesco]
END;
GO


--VALIDACION

CREATE PROCEDURE ValidarUsuarioContrasena(@Usuario varchar(16), @Pass varchar(32))
AS
BEGIN
	DECLARE @Tabla TABLE (Resultado int, userId VARCHAR(32))

	IF EXISTS (SELECT * FROM [dbo].[Usuario] WHERE @Usuario=Nombre)
		IF EXISTS (SELECT * FROM [dbo].[Usuario] WHERE @Pass=Contrasena)
		BEGIN
			INSERT INTO @Tabla(Resultado,userId) SELECT 1,ValorDocumentoIdentidad FROM [dbo].[Usuario] WHERE @Pass=Contrasena
		END
		ELSE
			INSERT INTO @Tabla(Resultado) SELECT 0
	ELSE
		INSERT INTO @Tabla(Resultado) SELECT 0
	
	SELECT * FROM @Tabla
END;
GO