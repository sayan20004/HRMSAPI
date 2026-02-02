-- =============================================
-- HRMS Database - Test Functions and Stored Procedures
-- =============================================

USE HRMSDB;
GO

PRINT '========================================';
PRINT 'Testing Scalar Functions';
PRINT '========================================';

-- Test: Check if email exists
SELECT dbo.fn_CheckEmployeeEmailExists('test@example.com', NULL) AS EmailExists;

-- Test: Get total employee count
SELECT dbo.fn_GetTotalEmployeeCount() AS TotalEmployees;

-- Test: Check if department name exists
SELECT dbo.fn_CheckDepartmentNameExists('IT Department', NULL) AS DeptExists;

-- Test: Validate foreign keys
SELECT dbo.fn_ValidateEmployeeForeignKeys(1, 1, 1) AS ValidationError;

-- Test: Count employees by department
SELECT dbo.fn_CountEmployeesByDepartment(1) AS EmployeeCount;

PRINT '========================================';
PRINT 'Testing Table-Valued Functions';
PRINT '========================================';

-- Test: Get all employees
SELECT * FROM dbo.tvf_GetAllEmployees();

-- Test: Get employee by ID
SELECT * FROM dbo.tvf_GetEmployeeById(1);

-- Test: Get all departments
SELECT * FROM dbo.tvf_GetAllDepartments();

-- Test: Get all designations
SELECT * FROM dbo.tvf_GetAllDesignations();

-- Test: Get all posts
SELECT * FROM dbo.tvf_GetAllPosts();

-- Test: Search employees
SELECT * FROM dbo.tvf_SearchEmployees('John');

PRINT '========================================';
PRINT 'Testing Stored Procedures - READ';
PRINT '========================================';

-- Test: Get all employees (SP calling TVF)
EXEC sp_GetAllEmployees;

-- Test: Get employee by ID (SP calling TVF)
EXEC sp_GetEmployeeById @Id = 1;

-- Test: Get all departments (SP calling TVF)
EXEC sp_GetAllDepartments;

-- Test: Get all designations (SP calling TVF)
EXEC sp_GetAllDesignations;

-- Test: Get all posts (SP calling TVF)
EXEC sp_GetAllPosts;

PRINT '========================================';
PRINT 'Testing Stored Procedures - CREATE';
PRINT '========================================';

-- Test: Create Department
DECLARE @DeptResult INT, @DeptMessage NVARCHAR(500);
EXEC sp_CreateDepartment 
    @Name = 'Test Department',
    @Code = 'TEST',
    @Result = @DeptResult OUTPUT,
    @Message = @DeptMessage OUTPUT;
SELECT @DeptResult AS Result, @DeptMessage AS Message, 'Department' AS Operation;
GO

-- Test: Create Designation
DECLARE @DesigResult INT, @DesigMessage NVARCHAR(500);
EXEC sp_CreateDesignation 
    @Name = 'Test Designation',
    @Level = 1,
    @Result = @DesigResult OUTPUT,
    @Message = @DesigMessage OUTPUT;
SELECT @DesigResult AS Result, @DesigMessage AS Message, 'Designation' AS Operation;
GO

-- Test: Create Post
DECLARE @PostResult INT, @PostMessage NVARCHAR(500);
EXEC sp_CreatePost 
    @Name = 'Test Post',
    @Result = @PostResult OUTPUT,
    @Message = @PostMessage OUTPUT;
SELECT @PostResult AS Result, @PostMessage AS Message, 'Post' AS Operation;
GO

-- Test: Create Employee (with validation via scalar functions)
DECLARE @EmpResult INT, @EmpMessage NVARCHAR(500);
EXEC sp_CreateEmployee 
    @FullName = 'Test Employee',
    @Email = 'test.employee@example.com',
    @MobileNumber = '9876543210',
    @Address = '123 Test St',
    @DateOfBirth = '1990-01-01',
    @DepartmentId = 1,
    @DesignationId = 1,
    @PostId = 1,
    @Result = @EmpResult OUTPUT,
    @Message = @EmpMessage OUTPUT;
SELECT @EmpResult AS Result, @EmpMessage AS Message, 'Employee' AS Operation;
GO

PRINT '========================================';
PRINT 'Testing Stored Procedures - UPDATE';
PRINT '========================================';

-- Test: Update Department (assuming ID 1 exists)
DECLARE @UpdateDeptResult INT, @UpdateDeptMessage NVARCHAR(500);
EXEC sp_UpdateDepartment 
    @Id = 1,
    @Name = 'Updated Department Name',
    @Code = 'UPD',
    @Result = @UpdateDeptResult OUTPUT,
    @Message = @UpdateDeptMessage OUTPUT;
SELECT @UpdateDeptResult AS Result, @UpdateDeptMessage AS Message, 'Update Department' AS Operation;
GO

-- Test: Update Designation (assuming ID 1 exists)
DECLARE @UpdateDesigResult INT, @UpdateDesigMessage NVARCHAR(500);
EXEC sp_UpdateDesignation 
    @Id = 1,
    @Name = 'Updated Designation',
    @Level = 2,
    @Result = @UpdateDesigResult OUTPUT,
    @Message = @UpdateDesigMessage OUTPUT;
SELECT @UpdateDesigResult AS Result, @UpdateDesigMessage AS Message, 'Update Designation' AS Operation;
GO

-- Test: Update Post (assuming ID 1 exists)
DECLARE @UpdatePostResult INT, @UpdatePostMessage NVARCHAR(500);
EXEC sp_UpdatePost 
    @Id = 1,
    @Name = 'Updated Post',
    @Result = @UpdatePostResult OUTPUT,
    @Message = @UpdatePostMessage OUTPUT;
SELECT @UpdatePostResult AS Result, @UpdatePostMessage AS Message, 'Update Post' AS Operation;
GO

-- Test: Update Employee (assuming ID 1 exists)
DECLARE @UpdateEmpResult INT, @UpdateEmpMessage NVARCHAR(500);
EXEC sp_UpdateEmployee 
    @Id = 1,
    @FullName = 'Updated Employee Name',
    @Email = 'updated.employee@example.com',
    @MobileNumber = '9876543211',
    @Address = '456 Updated St',
    @DateOfBirth = '1990-06-15',
    @DepartmentId = 1,
    @DesignationId = 1,
    @PostId = 1,
    @Result = @UpdateEmpResult OUTPUT,
    @Message = @UpdateEmpMessage OUTPUT;
SELECT @UpdateEmpResult AS Result, @UpdateEmpMessage AS Message, 'Update Employee' AS Operation;
GO

PRINT '========================================';
PRINT 'Testing Validation - Duplicate Checks';
PRINT '========================================';

-- Test: Try to create employee with duplicate email
DECLARE @DupEmailResult INT, @DupEmailMessage NVARCHAR(500);
EXEC sp_CreateEmployee 
    @FullName = 'Duplicate Email Test',
    @Email = 'test.employee@example.com', -- Should already exist
    @MobileNumber = '1111111111',
    @Result = @DupEmailResult OUTPUT,
    @Message = @DupEmailMessage OUTPUT;
SELECT @DupEmailResult AS Result, @DupEmailMessage AS Message, 'Duplicate Email Test' AS Operation;
GO

-- Test: Try to create department with duplicate name
DECLARE @DupDeptResult INT, @DupDeptMessage NVARCHAR(500);
EXEC sp_CreateDepartment 
    @Name = 'IT', -- Assuming 'IT' already exists
    @Code = 'IT2',
    @Result = @DupDeptResult OUTPUT,
    @Message = @DupDeptMessage OUTPUT;
SELECT @DupDeptResult AS Result, @DupDeptMessage AS Message, 'Duplicate Department Test' AS Operation;
GO

PRINT '========================================';
PRINT 'Testing Foreign Key Validation';
PRINT '========================================';

-- Test: Try to create employee with invalid department ID
DECLARE @InvalidFKResult INT, @InvalidFKMessage NVARCHAR(500);
EXEC sp_CreateEmployee 
    @FullName = 'Invalid FK Test',
    @Email = 'invalid.fk@example.com',
    @MobileNumber = '2222222222',
    @DepartmentId = 9999, -- Invalid ID
    @DesignationId = 1,
    @PostId = 1,
    @Result = @InvalidFKResult OUTPUT,
    @Message = @InvalidFKMessage OUTPUT;
SELECT @InvalidFKResult AS Result, @InvalidFKMessage AS Message, 'Invalid Foreign Key Test' AS Operation;
GO

PRINT '========================================';
PRINT 'Testing DELETE with Dependency Checks';
PRINT '========================================';

-- Test: Try to delete department that has employees
DECLARE @DeleteDeptResult INT, @DeleteDeptMessage NVARCHAR(500);
EXEC sp_DeleteDepartment 
    @Id = 1, -- Assuming this has employees
    @Result = @DeleteDeptResult OUTPUT,
    @Message = @DeleteDeptMessage OUTPUT;
SELECT @DeleteDeptResult AS Result, @DeleteDeptMessage AS Message, 'Delete Department with Dependencies' AS Operation;
GO

-- Test: Delete employee (should succeed)
DECLARE @DeleteEmpResult INT, @DeleteEmpMessage NVARCHAR(500);
EXEC sp_DeleteEmployee 
    @Id = 999, -- Non-existent ID
    @Result = @DeleteEmpResult OUTPUT,
    @Message = @DeleteEmpMessage OUTPUT;
SELECT @DeleteEmpResult AS Result, @DeleteEmpMessage AS Message, 'Delete Non-Existent Employee' AS Operation;
GO

PRINT '========================================';
PRINT 'Verification Queries';
PRINT '========================================';

-- List all scalar functions
SELECT 
    ROUTINE_NAME AS FunctionName,
    ROUTINE_TYPE AS Type
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION' 
    AND DATA_TYPE = 'int' OR DATA_TYPE = 'bit' OR DATA_TYPE = 'nvarchar'
ORDER BY ROUTINE_NAME;

-- List all table-valued functions
SELECT 
    ROUTINE_NAME AS FunctionName,
    ROUTINE_TYPE AS Type
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION' 
    AND DATA_TYPE = 'TABLE'
ORDER BY ROUTINE_NAME;

-- List all stored procedures
SELECT 
    ROUTINE_NAME AS ProcedureName
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME LIKE 'sp_%'
ORDER BY ROUTINE_NAME;

-- Count summary
SELECT 
    'Scalar Functions' AS ObjectType,
    COUNT(*) AS Count
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION' 
    AND DATA_TYPE != 'TABLE'

UNION ALL

SELECT 
    'Table-Valued Functions' AS ObjectType,
    COUNT(*) AS Count
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'FUNCTION' 
    AND DATA_TYPE = 'TABLE'

UNION ALL

SELECT 
    'Stored Procedures' AS ObjectType,
    COUNT(*) AS Count
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_TYPE = 'PROCEDURE'
    AND ROUTINE_NAME LIKE 'sp_%';

PRINT '========================================';
PRINT 'All Tests Completed!';
PRINT '========================================';
