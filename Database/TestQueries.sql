-- =============================================
-- HRMS - Test Queries for Stored Procedures and Functions
-- =============================================

USE HRMSDB;
GO

-- =============================================
-- TEST SCALAR FUNCTIONS
-- =============================================

PRINT '========== TESTING SCALAR FUNCTIONS ==========';

-- Test: Check if email exists
SELECT 'Email Exists Test' AS TestName, 
       dbo.fn_CheckEmployeeEmailExists('test@example.com', NULL) AS Result;

-- Test: Check if mobile exists
SELECT 'Mobile Exists Test' AS TestName,
       dbo.fn_CheckEmployeeMobileExists('1234567890', NULL) AS Result;

-- Test: Get total employee count
SELECT 'Total Employee Count' AS TestName,
       dbo.fn_GetTotalEmployeeCount() AS Result;

-- Test: Check if department exists
SELECT 'Department Exists Test' AS TestName,
       dbo.fn_CheckDepartmentNameExists('IT', NULL) AS Result;

-- =============================================
-- TEST TABLE-VALUED FUNCTIONS
-- =============================================

PRINT '========== TESTING TABLE-VALUED FUNCTIONS ==========';

-- Test: Get all employees
SELECT 'All Employees' AS TestName, COUNT(*) AS RecordCount
FROM dbo.tvf_GetAllEmployees();

-- Display sample data
SELECT TOP 5 * FROM dbo.tvf_GetAllEmployees();

-- Test: Get employee by ID
SELECT 'Employee By ID' AS TestName, *
FROM dbo.tvf_GetEmployeeById(1);

-- Test: Get all departments
SELECT 'All Departments' AS TestName, *
FROM dbo.tvf_GetAllDepartments();

-- Test: Get all designations
SELECT 'All Designations' AS TestName, *
FROM dbo.tvf_GetAllDesignations();

-- Test: Get all posts
SELECT 'All Posts' AS TestName, *
FROM dbo.tvf_GetAllPosts();

-- =============================================
-- TEST STORED PROCEDURES - EMPLOYEE
-- =============================================

PRINT '========== TESTING EMPLOYEE STORED PROCEDURES ==========';

-- Test 1: Create Employee (Success Case)
DECLARE @EmpResult INT, @EmpMessage NVARCHAR(500);

EXEC sp_CreateEmployee 
    @FullName = 'John Doe',
    @Email = 'john.doe@example.com',
    @MobileNumber = '9876543210',
    @Address = '123 Main Street, City',
    @DateOfBirth = '1990-05-15',
    @DepartmentId = NULL,  -- Will use existing IDs if available
    @DesignationId = NULL,
    @PostId = NULL,
    @Result = @EmpResult OUTPUT,
    @Message = @EmpMessage OUTPUT;

PRINT 'Create Employee Result: ' + CAST(@EmpResult AS VARCHAR(10));
PRINT 'Message: ' + @EmpMessage;
GO

-- Test 2: Try to create duplicate employee (Should Fail)
DECLARE @EmpResult2 INT, @EmpMessage2 NVARCHAR(500);

EXEC sp_CreateEmployee 
    @FullName = 'John Doe Duplicate',
    @Email = 'john.doe@example.com',  -- Duplicate email
    @MobileNumber = '9876543211',
    @Address = '123 Main Street',
    @DateOfBirth = '1990-05-15',
    @DepartmentId = NULL,
    @DesignationId = NULL,
    @PostId = NULL,
    @Result = @EmpResult2 OUTPUT,
    @Message = @EmpMessage2 OUTPUT;

PRINT 'Duplicate Employee Test Result: ' + CAST(@EmpResult2 AS VARCHAR(10));
PRINT 'Message: ' + @EmpMessage2;
GO

-- Test 3: Update Employee
DECLARE @UpdateResult INT, @UpdateMessage NVARCHAR(500);
DECLARE @EmployeeIdToUpdate INT;

-- Get first employee ID
SELECT TOP 1 @EmployeeIdToUpdate = Id FROM Employees;

IF @EmployeeIdToUpdate IS NOT NULL
BEGIN
    EXEC sp_UpdateEmployee 
        @Id = @EmployeeIdToUpdate,
        @FullName = 'John Doe Updated',
        @Email = 'john.doe@example.com',
        @MobileNumber = '9876543210',
        @Address = '456 Updated Street',
        @DateOfBirth = '1990-05-15',
        @DepartmentId = NULL,
        @DesignationId = NULL,
        @PostId = NULL,
        @Result = @UpdateResult OUTPUT,
        @Message = @UpdateMessage OUTPUT;

    PRINT 'Update Employee Result: ' + CAST(@UpdateResult AS VARCHAR(10));
    PRINT 'Message: ' + @UpdateMessage;
END
ELSE
BEGIN
    PRINT 'No employee found to update';
END
GO

-- =============================================
-- TEST STORED PROCEDURES - DEPARTMENT
-- =============================================

PRINT '========== TESTING DEPARTMENT STORED PROCEDURES ==========';

-- Test 1: Create Department
DECLARE @DeptResult INT, @DeptMessage NVARCHAR(500);

EXEC sp_CreateDepartment 
    @Name = 'Human Resources',
    @Code = 'HR',
    @Result = @DeptResult OUTPUT,
    @Message = @DeptMessage OUTPUT;

PRINT 'Create Department Result: ' + CAST(@DeptResult AS VARCHAR(10));
PRINT 'Message: ' + @DeptMessage;
GO

-- Test 2: Try to create duplicate department
DECLARE @DeptResult2 INT, @DeptMessage2 NVARCHAR(500);

EXEC sp_CreateDepartment 
    @Name = 'Human Resources',  -- Duplicate
    @Code = 'HR2',
    @Result = @DeptResult2 OUTPUT,
    @Message = @DeptMessage2 OUTPUT;

PRINT 'Duplicate Department Test Result: ' + CAST(@DeptResult2 AS VARCHAR(10));
PRINT 'Message: ' + @DeptMessage2;
GO

-- =============================================
-- TEST STORED PROCEDURES - DESIGNATION
-- =============================================

PRINT '========== TESTING DESIGNATION STORED PROCEDURES ==========';

-- Test: Create Designation
DECLARE @DesigResult INT, @DesigMessage NVARCHAR(500);

EXEC sp_CreateDesignation 
    @Name = 'Senior Manager',
    @Level = 5,
    @Result = @DesigResult OUTPUT,
    @Message = @DesigMessage OUTPUT;

PRINT 'Create Designation Result: ' + CAST(@DesigResult AS VARCHAR(10));
PRINT 'Message: ' + @DesigMessage;
GO

-- =============================================
-- TEST STORED PROCEDURES - POST
-- =============================================

PRINT '========== TESTING POST STORED PROCEDURES ==========';

-- Test: Create Post
DECLARE @PostResult INT, @PostMessage NVARCHAR(500);

EXEC sp_CreatePost 
    @Name = 'Software Engineer',
    @Result = @PostResult OUTPUT,
    @Message = @PostMessage OUTPUT;

PRINT 'Create Post Result: ' + CAST(@PostResult AS VARCHAR(10));
PRINT 'Message: ' + @PostMessage;
GO

-- =============================================
-- TEST DELETE OPERATIONS
-- =============================================

PRINT '========== TESTING DELETE STORED PROCEDURES ==========';

-- Test: Try to delete department with employees (Should Fail)
DECLARE @DelDeptResult INT, @DelDeptMessage NVARCHAR(500);
DECLARE @DeptIdWithEmployees INT;

SELECT TOP 1 @DeptIdWithEmployees = DepartmentId 
FROM Employees 
WHERE DepartmentId IS NOT NULL;

IF @DeptIdWithEmployees IS NOT NULL
BEGIN
    EXEC sp_DeleteDepartment 
        @Id = @DeptIdWithEmployees,
        @Result = @DelDeptResult OUTPUT,
        @Message = @DelDeptMessage OUTPUT;

    PRINT 'Delete Department With Employees Result: ' + CAST(@DelDeptResult AS VARCHAR(10));
    PRINT 'Message: ' + @DelDeptMessage;
END
GO

-- =============================================
-- PERFORMANCE TESTS
-- =============================================

PRINT '========== PERFORMANCE TESTS ==========';

-- Test: Get all employees with details (TVF vs Direct Query)
DECLARE @StartTime DATETIME, @EndTime DATETIME, @Duration INT;

-- Using TVF
SET @StartTime = GETDATE();
SELECT * FROM dbo.tvf_GetAllEmployees();
SET @EndTime = GETDATE();
SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
PRINT 'TVF Performance: ' + CAST(@Duration AS VARCHAR(10)) + ' ms';

-- Using Direct Query
SET @StartTime = GETDATE();
SELECT 
    e.Id, e.FullName, e.Email, e.MobileNumber, e.Address, e.DateOfBirth,
    d.Name AS DepartmentName, des.Name AS DesignationName, p.Name AS PostName
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentId = d.Id
LEFT JOIN Designations des ON e.DesignationId = des.Id
LEFT JOIN Posts p ON e.PostId = p.Id;
SET @EndTime = GETDATE();
SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
PRINT 'Direct Query Performance: ' + CAST(@Duration AS VARCHAR(10)) + ' ms';

-- =============================================
-- CLEANUP (OPTIONAL)
-- =============================================

-- Uncomment below to clean up test data
/*
-- Delete test employee
DELETE FROM Employees WHERE Email = 'john.doe@example.com';

-- Delete test department (only if not assigned)
DELETE FROM Departments WHERE Name = 'Human Resources' AND Code = 'HR';

-- Delete test designation
DELETE FROM Designations WHERE Name = 'Senior Manager';

-- Delete test post
DELETE FROM Posts WHERE Name = 'Software Engineer';

PRINT 'Test data cleaned up';
*/

PRINT '========== ALL TESTS COMPLETED ==========';
