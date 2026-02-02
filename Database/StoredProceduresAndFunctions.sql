-- =============================================
-- HRMS Database Stored Procedures and Functions
-- =============================================

USE HRMSDB;
GO

-- =============================================
-- SCALAR FUNCTIONS
-- =============================================

-- Function to check if email exists for employee
CREATE OR ALTER FUNCTION dbo.fn_CheckEmployeeEmailExists
(
    @Email NVARCHAR(256),
    @ExcludeId INT = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM Employees 
        WHERE Email = @Email 
        AND (@ExcludeId IS NULL OR Id != @ExcludeId)
    )
        SET @Exists = 1;
    
    RETURN @Exists;
END
GO

-- Function to check if mobile exists for employee
CREATE OR ALTER FUNCTION dbo.fn_CheckEmployeeMobileExists
(
    @MobileNumber NVARCHAR(MAX),
    @ExcludeId INT = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM Employees 
        WHERE MobileNumber = @MobileNumber 
        AND (@ExcludeId IS NULL OR Id != @ExcludeId)
    )
        SET @Exists = 1;
    
    RETURN @Exists;
END
GO

-- Function to get total employee count
CREATE OR ALTER FUNCTION dbo.fn_GetTotalEmployeeCount()
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Employees;
    RETURN @Count;
END
GO

-- Function to check if department name exists
CREATE OR ALTER FUNCTION dbo.fn_CheckDepartmentNameExists
(
    @Name NVARCHAR(MAX),
    @ExcludeId INT = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM Departments 
        WHERE Name = @Name 
        AND (@ExcludeId IS NULL OR Id != @ExcludeId)
    )
        SET @Exists = 1;
    
    RETURN @Exists;
END
GO

-- Function to check if designation name exists
CREATE OR ALTER FUNCTION dbo.fn_CheckDesignationNameExists
(
    @Name NVARCHAR(MAX),
    @ExcludeId INT = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM Designations 
        WHERE Name = @Name 
        AND (@ExcludeId IS NULL OR Id != @ExcludeId)
    )
        SET @Exists = 1;
    
    RETURN @Exists;
END
GO

-- Function to check if post name exists
CREATE OR ALTER FUNCTION dbo.fn_CheckPostNameExists
(
    @Name NVARCHAR(MAX),
    @ExcludeId INT = NULL
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;
    
    IF EXISTS (
        SELECT 1 FROM Posts 
        WHERE Name = @Name 
        AND (@ExcludeId IS NULL OR Id != @ExcludeId)
    )
        SET @Exists = 1;
    
    RETURN @Exists;
END
GO

-- Function to validate employee foreign keys
CREATE OR ALTER FUNCTION dbo.fn_ValidateEmployeeForeignKeys
(
    @DepartmentId INT = NULL,
    @DesignationId INT = NULL,
    @PostId INT = NULL
)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    -- Check Department
    IF @DepartmentId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Departments WHERE Id = @DepartmentId)
    BEGIN
        SET @ErrorMessage = 'Invalid Department ID.';
        RETURN @ErrorMessage;
    END
    
    -- Check Designation
    IF @DesignationId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Designations WHERE Id = @DesignationId)
    BEGIN
        SET @ErrorMessage = 'Invalid Designation ID.';
        RETURN @ErrorMessage;
    END
    
    -- Check Post
    IF @PostId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Posts WHERE Id = @PostId)
    BEGIN
        SET @ErrorMessage = 'Invalid Post ID.';
        RETURN @ErrorMessage;
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to count employees by department
CREATE OR ALTER FUNCTION dbo.fn_CountEmployeesByDepartment(@DepartmentId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Employees WHERE DepartmentId = @DepartmentId;
    RETURN @Count;
END
GO

-- Function to count employees by designation
CREATE OR ALTER FUNCTION dbo.fn_CountEmployeesByDesignation(@DesignationId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Employees WHERE DesignationId = @DesignationId;
    RETURN @Count;
END
GO

-- Function to count employees by post
CREATE OR ALTER FUNCTION dbo.fn_CountEmployeesByPost(@PostId INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Employees WHERE PostId = @PostId;
    RETURN @Count;
END
GO

-- =============================================
-- COMPREHENSIVE VALIDATION FUNCTIONS (For CREATE Operations)
-- =============================================

-- Function to validate employee creation (returns NULL if valid, error message if invalid)
CREATE OR ALTER FUNCTION dbo.fn_ValidateEmployeeCreate
(
    @Email NVARCHAR(256),
    @MobileNumber NVARCHAR(MAX),
    @DepartmentId INT = NULL,
    @DesignationId INT = NULL,
    @PostId INT = NULL
)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    -- Check email uniqueness
    IF dbo.fn_CheckEmployeeEmailExists(@Email, NULL) = 1
    BEGIN
        SET @ErrorMessage = 'Email already exists.';
        RETURN @ErrorMessage;
    END
    
    -- Check mobile uniqueness
    IF dbo.fn_CheckEmployeeMobileExists(@MobileNumber, NULL) = 1
    BEGIN
        SET @ErrorMessage = 'Mobile number already exists.';
        RETURN @ErrorMessage;
    END
    
    -- Validate foreign keys
    SET @ErrorMessage = dbo.fn_ValidateEmployeeForeignKeys(@DepartmentId, @DesignationId, @PostId);
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate employee update (returns NULL if valid, error message if invalid)
CREATE OR ALTER FUNCTION dbo.fn_ValidateEmployeeUpdate
(
    @Id INT,
    @Email NVARCHAR(256),
    @MobileNumber NVARCHAR(MAX),
    @DepartmentId INT = NULL,
    @DesignationId INT = NULL,
    @PostId INT = NULL
)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    -- Check if employee exists
    IF NOT EXISTS (SELECT 1 FROM Employees WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Employee not found.';
        RETURN @ErrorMessage;
    END
    
    -- Check email uniqueness (excluding current employee)
    IF dbo.fn_CheckEmployeeEmailExists(@Email, @Id) = 1
    BEGIN
        SET @ErrorMessage = 'Email already exists for another employee.';
        RETURN @ErrorMessage;
    END
    
    -- Check mobile uniqueness (excluding current employee)
    IF dbo.fn_CheckEmployeeMobileExists(@MobileNumber, @Id) = 1
    BEGIN
        SET @ErrorMessage = 'Mobile number already exists for another employee.';
        RETURN @ErrorMessage;
    END
    
    -- Validate foreign keys
    SET @ErrorMessage = dbo.fn_ValidateEmployeeForeignKeys(@DepartmentId, @DesignationId, @PostId);
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate department create
CREATE OR ALTER FUNCTION dbo.fn_ValidateDepartmentCreate(@Name NVARCHAR(MAX))
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    IF dbo.fn_CheckDepartmentNameExists(@Name, NULL) = 1
    BEGIN
        SET @ErrorMessage = 'Department already exists.';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate department update
CREATE OR ALTER FUNCTION dbo.fn_ValidateDepartmentUpdate(@Id INT, @Name NVARCHAR(MAX))
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    IF NOT EXISTS (SELECT 1 FROM Departments WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Department not found.';
        RETURN @ErrorMessage;
    END
    
    IF dbo.fn_CheckDepartmentNameExists(@Name, @Id) = 1
    BEGIN
        SET @ErrorMessage = 'Department name already exists.';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate department delete
CREATE OR ALTER FUNCTION dbo.fn_ValidateDepartmentDelete(@Id INT)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    DECLARE @EmployeeCount INT;
    
    IF NOT EXISTS (SELECT 1 FROM Departments WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Department not found.';
        RETURN @ErrorMessage;
    END
    
    SET @EmployeeCount = dbo.fn_CountEmployeesByDepartment(@Id);
    IF @EmployeeCount > 0
    BEGIN
        SET @ErrorMessage = 'Cannot delete: Department is assigned to ' + CAST(@EmployeeCount AS NVARCHAR) + ' employee(s).';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate designation create
CREATE OR ALTER FUNCTION dbo.fn_ValidateDesignationCreate(@Name NVARCHAR(MAX))
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    IF dbo.fn_CheckDesignationNameExists(@Name, NULL) = 1
    BEGIN
        SET @ErrorMessage = 'Designation already exists.';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate designation update
CREATE OR ALTER FUNCTION dbo.fn_ValidateDesignationUpdate(@Id INT, @Name NVARCHAR(MAX))
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    IF NOT EXISTS (SELECT 1 FROM Designations WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Designation not found.';
        RETURN @ErrorMessage;
    END
    
    IF dbo.fn_CheckDesignationNameExists(@Name, @Id) = 1
    BEGIN
        SET @ErrorMessage = 'Designation name already exists.';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate designation delete
CREATE OR ALTER FUNCTION dbo.fn_ValidateDesignationDelete(@Id INT)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    DECLARE @EmployeeCount INT;
    
    IF NOT EXISTS (SELECT 1 FROM Designations WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Designation not found.';
        RETURN @ErrorMessage;
    END
    
    SET @EmployeeCount = dbo.fn_CountEmployeesByDesignation(@Id);
    IF @EmployeeCount > 0
    BEGIN
        SET @ErrorMessage = 'Cannot delete: Designation is assigned to ' + CAST(@EmployeeCount AS NVARCHAR) + ' employee(s).';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate post create
CREATE OR ALTER FUNCTION dbo.fn_ValidatePostCreate(@Name NVARCHAR(MAX))
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    IF dbo.fn_CheckPostNameExists(@Name, NULL) = 1
    BEGIN
        SET @ErrorMessage = 'Post already exists.';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate post update
CREATE OR ALTER FUNCTION dbo.fn_ValidatePostUpdate(@Id INT, @Name NVARCHAR(MAX))
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    
    IF NOT EXISTS (SELECT 1 FROM Posts WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Post not found.';
        RETURN @ErrorMessage;
    END
    
    IF dbo.fn_CheckPostNameExists(@Name, @Id) = 1
    BEGIN
        SET @ErrorMessage = 'Post name already exists.';
    END
    
    RETURN @ErrorMessage;
END
GO

-- Function to validate post delete
CREATE OR ALTER FUNCTION dbo.fn_ValidatePostDelete(@Id INT)
RETURNS NVARCHAR(500)
AS
BEGIN
    DECLARE @ErrorMessage NVARCHAR(500) = NULL;
    DECLARE @EmployeeCount INT;
    
    IF NOT EXISTS (SELECT 1 FROM Posts WHERE Id = @Id)
    BEGIN
        SET @ErrorMessage = 'Post not found.';
        RETURN @ErrorMessage;
    END
    
    SET @EmployeeCount = dbo.fn_CountEmployeesByPost(@Id);
    IF @EmployeeCount > 0
    BEGIN
        SET @ErrorMessage = 'Cannot delete: Post is assigned to ' + CAST(@EmployeeCount AS NVARCHAR) + ' employee(s).';
    END
    
    RETURN @ErrorMessage;
END
GO

-- =============================================
-- TABLE-VALUED FUNCTIONS
-- =============================================

-- TVF: Get all employees with department and designation details
CREATE OR ALTER FUNCTION dbo.tvf_GetAllEmployees()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        e.Id,
        e.FullName,
        e.Email,
        e.MobileNumber,
        e.Address,
        e.DateOfBirth,
        e.DepartmentId,
        e.DesignationId,
        e.PostId,
        d.Name AS DepartmentName,
        d.Code AS DepartmentCode,
        des.Name AS DesignationName,
        des.Level AS DesignationLevel,
        p.Name AS PostName
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentId = d.Id
    LEFT JOIN Designations des ON e.DesignationId = des.Id
    LEFT JOIN Posts p ON e.PostId = p.Id
);
GO

-- TVF: Get employee by ID with details
CREATE OR ALTER FUNCTION dbo.tvf_GetEmployeeById(@EmployeeId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        e.Id,
        e.FullName,
        e.Email,
        e.MobileNumber,
        e.Address,
        e.DateOfBirth,
        e.DepartmentId,
        e.DesignationId,
        e.PostId,
        d.Name AS DepartmentName,
        d.Code AS DepartmentCode,
        des.Name AS DesignationName,
        des.Level AS DesignationLevel,
        p.Name AS PostName
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentId = d.Id
    LEFT JOIN Designations des ON e.DesignationId = des.Id
    LEFT JOIN Posts p ON e.PostId = p.Id
    WHERE e.Id = @EmployeeId
);
GO

-- TVF: Get all departments
CREATE OR ALTER FUNCTION dbo.tvf_GetAllDepartments()
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Name, Code
    FROM Departments
);
GO

-- TVF: Get all designations
CREATE OR ALTER FUNCTION dbo.tvf_GetAllDesignations()
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Name, Level
    FROM Designations
);
GO

-- TVF: Get all posts
CREATE OR ALTER FUNCTION dbo.tvf_GetAllPosts()
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Name
    FROM Posts
);
GO

-- TVF: Get department by ID
CREATE OR ALTER FUNCTION dbo.tvf_GetDepartmentById(@DepartmentId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Name, Code
    FROM Departments
    WHERE Id = @DepartmentId
);
GO

-- TVF: Get designation by ID
CREATE OR ALTER FUNCTION dbo.tvf_GetDesignationById(@DesignationId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Name, Level
    FROM Designations
    WHERE Id = @DesignationId
);
GO

-- TVF: Get post by ID
CREATE OR ALTER FUNCTION dbo.tvf_GetPostById(@PostId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT Id, Name
    FROM Posts
    WHERE Id = @PostId
);
GO

-- TVF: Get employees by department
CREATE OR ALTER FUNCTION dbo.tvf_GetEmployeesByDepartment(@DepartmentId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        e.Id,
        e.FullName,
        e.Email,
        e.MobileNumber,
        e.Address,
        e.DateOfBirth,
        e.DepartmentId,
        e.DesignationId,
        e.PostId,
        d.Name AS DepartmentName,
        des.Name AS DesignationName,
        p.Name AS PostName
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentId = d.Id
    LEFT JOIN Designations des ON e.DesignationId = des.Id
    LEFT JOIN Posts p ON e.PostId = p.Id
    WHERE e.DepartmentId = @DepartmentId
);
GO

-- TVF: Search employees by name or email
CREATE OR ALTER FUNCTION dbo.tvf_SearchEmployees(@SearchTerm NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        e.Id,
        e.FullName,
        e.Email,
        e.MobileNumber,
        e.Address,
        e.DateOfBirth,
        e.DepartmentId,
        e.DesignationId,
        e.PostId,
        d.Name AS DepartmentName,
        des.Name AS DesignationName,
        p.Name AS PostName
    FROM Employees e
    LEFT JOIN Departments d ON e.DepartmentId = d.Id
    LEFT JOIN Designations des ON e.DesignationId = des.Id
    LEFT JOIN Posts p ON e.PostId = p.Id
    WHERE e.FullName LIKE '%' + @SearchTerm + '%' 
       OR e.Email LIKE '%' + @SearchTerm + '%'
);
GO

-- =============================================
-- STORED PROCEDURES - READ OPERATIONS (Calling TVFs)
-- =============================================

-- SP: Get All Employees (calls TVF)
CREATE OR ALTER PROCEDURE sp_GetAllEmployees
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM dbo.tvf_GetAllEmployees();
END
GO

-- SP: Get Employee By ID (calls TVF)
CREATE OR ALTER PROCEDURE sp_GetEmployeeById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM dbo.tvf_GetEmployeeById(@Id);
END
GO

-- SP: Get All Departments (calls TVF)
CREATE OR ALTER PROCEDURE sp_GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM dbo.tvf_GetAllDepartments();
END
GO

-- SP: Get All Designations (calls TVF)
CREATE OR ALTER PROCEDURE sp_GetAllDesignations
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM dbo.tvf_GetAllDesignations();
END
GO

-- SP: Get All Posts (calls TVF)
CREATE OR ALTER PROCEDURE sp_GetAllPosts
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT * FROM dbo.tvf_GetAllPosts();
END
GO

-- =============================================
-- STORED PROCEDURES - EMPLOYEE (CUD Operations)
-- =============================================

-- SP: Create Employee
CREATE OR ALTER PROCEDURE sp_CreateEmployee
    @FullName NVARCHAR(MAX),
    @Email NVARCHAR(256),
    @MobileNumber NVARCHAR(MAX),
    @Address NVARCHAR(MAX) = NULL,
    @DateOfBirth DATETIME2 = NULL,
    @DepartmentId INT = NULL,
    @DesignationId INT = NULL,
    @PostId INT = NULL,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use comprehensive validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateEmployeeCreate(@Email, @MobileNumber, @DepartmentId, @DesignationId, @PostId);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- All validations passed, perform INSERT
        INSERT INTO Employees (FullName, Email, MobileNumber, Address, DateOfBirth, DepartmentId, DesignationId, PostId)
        VALUES (@FullName, @Email, @MobileNumber, @Address, @DateOfBirth, @DepartmentId, @DesignationId, @PostId);

        SET @Result = SCOPE_IDENTITY();
        SET @Message = 'Employee created successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Update Employee
CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @Id INT,
    @FullName NVARCHAR(MAX),
    @Email NVARCHAR(256),
    @MobileNumber NVARCHAR(MAX),
    @Address NVARCHAR(MAX) = NULL,
    @DateOfBirth DATETIME2 = NULL,
    @DepartmentId INT = NULL,
    @DesignationId INT = NULL,
    @PostId INT = NULL,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use comprehensive validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateEmployeeUpdate(@Id, @Email, @MobileNumber, @DepartmentId, @DesignationId, @PostId);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- All validations passed, perform UPDATE
        UPDATE Employees
        SET 
            FullName = @FullName,
            Email = @Email,
            MobileNumber = @MobileNumber,
            Address = @Address,
            DateOfBirth = @DateOfBirth,
            DepartmentId = @DepartmentId,
            DesignationId = @DesignationId,
            PostId = @PostId
        WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Employee updated successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Delete Employee
CREATE OR ALTER PROCEDURE sp_DeleteEmployee
    @Id INT,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Check if employee exists
        IF NOT EXISTS (SELECT 1 FROM Employees WHERE Id = @Id)
        BEGIN
            SET @Result = -1;
            SET @Message = 'Employee not found.';
            RETURN;
        END

        DELETE FROM Employees WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Employee deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURES - DEPARTMENT
-- =============================================

-- SP: Create Department
CREATE OR ALTER PROCEDURE sp_CreateDepartment
    @Name NVARCHAR(MAX),
    @Code NVARCHAR(MAX) = NULL,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateDepartmentCreate(@Name);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform INSERT
        INSERT INTO Departments (Name, Code)
        VALUES (@Name, @Code);

        SET @Result = SCOPE_IDENTITY();
        SET @Message = 'Department created successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Update Department
CREATE OR ALTER PROCEDURE sp_UpdateDepartment
    @Id INT,
    @Name NVARCHAR(MAX),
    @Code NVARCHAR(MAX) = NULL,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateDepartmentUpdate(@Id, @Name);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform UPDATE
        UPDATE Departments
        SET Name = @Name, Code = @Code
        WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Department updated successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Delete Department
CREATE OR ALTER PROCEDURE sp_DeleteDepartment
    @Id INT,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateDepartmentDelete(@Id);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform DELETE
        DELETE FROM Departments WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Department deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURES - DESIGNATION
-- =============================================

-- SP: Create Designation
CREATE OR ALTER PROCEDURE sp_CreateDesignation
    @Name NVARCHAR(MAX),
    @Level INT = 1,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateDesignationCreate(@Name);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform INSERT
        INSERT INTO Designations (Name, Level)
        VALUES (@Name, @Level);

        SET @Result = SCOPE_IDENTITY();
        SET @Message = 'Designation created successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Update Designation
CREATE OR ALTER PROCEDURE sp_UpdateDesignation
    @Id INT,
    @Name NVARCHAR(MAX),
    @Level INT = 1,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateDesignationUpdate(@Id, @Name);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform UPDATE
        UPDATE Designations
        SET Name = @Name, Level = @Level
        WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Designation updated successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Delete Designation
CREATE OR ALTER PROCEDURE sp_DeleteDesignation
    @Id INT,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidateDesignationDelete(@Id);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform DELETE
        DELETE FROM Designations WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Designation deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- =============================================
-- STORED PROCEDURES - POST
-- =============================================

-- SP: Create Post
CREATE OR ALTER PROCEDURE sp_CreatePost
    @Name NVARCHAR(MAX),
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidatePostCreate(@Name);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform INSERT
        INSERT INTO Posts (Name)
        VALUES (@Name);

        SET @Result = SCOPE_IDENTITY();
        SET @Message = 'Post created successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Update Post
CREATE OR ALTER PROCEDURE sp_UpdatePost
    @Id INT,
    @Name NVARCHAR(MAX),
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidatePostUpdate(@Id, @Name);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform UPDATE
        UPDATE Posts
        SET Name = @Name
        WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Post updated successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

-- SP: Delete Post
CREATE OR ALTER PROCEDURE sp_DeletePost
    @Id INT,
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Use validation function
        DECLARE @ValidationError NVARCHAR(500);
        SET @ValidationError = dbo.fn_ValidatePostDelete(@Id);
        
        IF @ValidationError IS NOT NULL
        BEGIN
            SET @Result = -1;
            SET @Message = @ValidationError;
            RETURN;
        END

        -- Validation passed, perform DELETE
        DELETE FROM Posts WHERE Id = @Id;

        SET @Result = 1;
        SET @Message = 'Post deleted successfully.';
    END TRY
    BEGIN CATCH
        SET @Result = -999;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

PRINT 'All Stored Procedures and Functions created successfully!';

