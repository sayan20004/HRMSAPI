# HRMS Database Setup - Stored Procedures & Functions

## Overview
This document explains how to set up and use the stored procedures and functions for the HRMS application.

## Architecture
The application now uses:
- **Stored Procedures (SP)**: For all CUD (Create, Update, Delete) operations
- **Table-Valued Functions (TVF)**: For retrieving data with joins
- **Scalar Functions**: For validations and calculations

## Setup Instructions

### Step 1: Execute SQL Script
1. Open SQL Server Management Studio (SSMS)
2. Connect to your SQL Server instance
3. Open the file: `StoredProceduresAndFunctions.sql`
4. Make sure you're using the correct database:
   ```sql
   USE HRMSDB;
   GO
   ```
5. Execute the entire script (F5)

### Step 2: Verify Installation
Run these queries to verify all objects were created:

```sql
-- Check Scalar Functions
SELECT name FROM sys.objects 
WHERE type = 'FN' AND name LIKE 'fn_%'
ORDER BY name;

-- Check Table-Valued Functions
SELECT name FROM sys.objects 
WHERE type = 'IF' AND name LIKE 'tvf_%'
ORDER BY name;

-- Check Stored Procedures
SELECT name FROM sys.objects 
WHERE type = 'P' AND name LIKE 'sp_%'
ORDER BY name;
```

## Database Objects Created

### Scalar Functions
1. **fn_CheckEmployeeEmailExists** - Check if email exists for validation
2. **fn_CheckEmployeeMobileExists** - Check if mobile number exists
3. **fn_GetTotalEmployeeCount** - Get total employee count
4. **fn_CheckDepartmentNameExists** - Check if department name exists

### Table-Valued Functions (TVF)
1. **tvf_GetAllEmployees** - Get all employees with department, designation, and post details
2. **tvf_GetEmployeeById** - Get single employee by ID with all details
3. **tvf_GetAllDepartments** - Get all departments
4. **tvf_GetAllDesignations** - Get all designations
5. **tvf_GetAllPosts** - Get all posts

### Stored Procedures

#### Employee Operations
- **sp_CreateEmployee** - Create new employee with validations
- **sp_UpdateEmployee** - Update employee details
- **sp_DeleteEmployee** - Delete employee

#### Department Operations
- **sp_CreateDepartment** - Create new department
- **sp_DeleteDepartment** - Delete department (with safety checks)

#### Designation Operations
- **sp_CreateDesignation** - Create new designation
- **sp_DeleteDesignation** - Delete designation (with safety checks)

#### Post Operations
- **sp_CreatePost** - Create new post
- **sp_DeletePost** - Delete post (with safety checks)

## API Changes

### What Changed
All controllers (except Auth) now use stored procedures and functions instead of EF Core direct queries.

### Example Usage

#### Get Employees (TVF)
```csharp
var employees = await _context.Set<Employee>()
    .FromSqlRaw("SELECT * FROM dbo.tvf_GetAllEmployees()")
    .ToListAsync();
```

#### Create Employee (SP)
```csharp
await _context.Database.ExecuteSqlRawAsync(
    "EXEC sp_CreateEmployee @FullName, @Email, ..., @Result OUTPUT, @Message OUTPUT",
    parameters...
);
```

## Benefits

### 1. Performance
- Compiled execution plans
- Reduced network traffic
- Optimized joins in TVFs

### 2. Security
- Prevents SQL injection
- Centralized data access logic
- Row-level security capability

### 3. Maintainability
- Business logic in database
- Easier to update logic without redeployment
- Consistent validation rules

### 4. Scalability
- Reduced application server load
- Better transaction management
- Database-level caching

## Testing

### Test Employee Creation
```sql
DECLARE @Result INT, @Message NVARCHAR(500);

EXEC sp_CreateEmployee 
    @FullName = 'Test User',
    @Email = 'test@example.com',
    @MobileNumber = '1234567890',
    @Address = 'Test Address',
    @DateOfBirth = '1990-01-01',
    @DepartmentId = 1,
    @DesignationId = 1,
    @PostId = 1,
    @Result = @Result OUTPUT,
    @Message = @Message OUTPUT;

SELECT @Result AS Result, @Message AS Message;
```

### Test TVF
```sql
-- Get all employees
SELECT * FROM dbo.tvf_GetAllEmployees();

-- Get specific employee
SELECT * FROM dbo.tvf_GetEmployeeById(1);
```

### Test Scalar Function
```sql
-- Check if email exists
SELECT dbo.fn_CheckEmployeeEmailExists('test@example.com', NULL);

-- Get total employees
SELECT dbo.fn_GetTotalEmployeeCount();
```

## Troubleshooting

### Issue: "Could not find stored procedure"
**Solution**: Make sure you executed the SQL script in the correct database (HRMSDB)

### Issue: "Invalid column name"
**Solution**: The TVF returns a custom result set. Ensure your model properties match the TVF output.

### Issue: "Cannot insert duplicate key"
**Solution**: The SP validates duplicates. Check the @Message output parameter for details.

## Future Enhancements

Potential additions:
1. Update stored procedures for Department, Designation, and Post
2. Audit logging functions
3. Soft delete functionality
4. Search/filter TVFs with parameters
5. Performance monitoring functions

## Notes

- Auth operations (Login, Register, Forgot Password, Change Password) still use EF Core as requested
- All SPs use OUTPUT parameters for result status and messages
- TVFs are read-only and cannot perform modifications
- Scalar functions can be used in WHERE clauses and SELECT statements
