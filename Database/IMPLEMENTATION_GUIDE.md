# HRMS Database Implementation Guide

## Overview
This HRMS application uses a **Stored Procedure + Function-based architecture** for all CRUD operations (except authentication). The architecture ensures:

- **Authentication Operations**: Use Entity Framework (Register, Login, Logout)
- **All Other CRUD Operations**: Use Stored Procedures with Scalar and Table-Valued Functions

## Architecture Flow

```
Controller → Service Layer → Stored Procedure → Functions (Scalar/TVF) → Database
```

### Example Flow for GET Operation:
1. **Controller** receives HTTP request
2. **Service** calls Stored Procedure: `sp_GetAllEmployees`
3. **Stored Procedure** calls Table-Valued Function: `tvf_GetAllEmployees()`
4. **TVF** executes SELECT query with JOINs
5. Result returns through the chain

### Example Flow for CREATE Operation:
1. **Controller** receives HTTP POST request
2. **Service** calls Stored Procedure: `sp_CreateEmployee`
3. **Stored Procedure** uses:
   - **Scalar Function** `fn_CheckEmployeeEmailExists()` - validates email
   - **Scalar Function** `fn_CheckEmployeeMobileExists()` - validates mobile
   - **Scalar Function** `fn_ValidateEmployeeForeignKeys()` - validates references
4. **Stored Procedure** executes INSERT
5. Returns result with success/error message

## Database Objects Created

### Scalar Functions (Business Logic Validation)
- `fn_CheckEmployeeEmailExists` - Check if employee email exists
- `fn_CheckEmployeeMobileExists` - Check if employee mobile exists
- `fn_CheckDepartmentNameExists` - Check if department name exists
- `fn_CheckDesignationNameExists` - Check if designation name exists
- `fn_CheckPostNameExists` - Check if post name exists
- `fn_ValidateEmployeeForeignKeys` - Validate Department, Designation, Post IDs
- `fn_GetTotalEmployeeCount` - Get total employee count
- `fn_CountEmployeesByDepartment` - Count employees in a department
- `fn_CountEmployeesByDesignation` - Count employees with a designation
- `fn_CountEmployeesByPost` - Count employees in a post

### Table-Valued Functions (Data Retrieval)
- `tvf_GetAllEmployees` - Get all employees with joined data
- `tvf_GetEmployeeById` - Get single employee with details
- `tvf_GetAllDepartments` - Get all departments
- `tvf_GetDepartmentById` - Get department by ID
- `tvf_GetAllDesignations` - Get all designations
- `tvf_GetDesignationById` - Get designation by ID
- `tvf_GetAllPosts` - Get all posts
- `tvf_GetPostById` - Get post by ID
- `tvf_GetEmployeesByDepartment` - Get employees filtered by department
- `tvf_SearchEmployees` - Search employees by name or email

### Stored Procedures

#### Employee Operations
- `sp_GetAllEmployees` - Retrieves all employees (calls TVF)
- `sp_GetEmployeeById` - Retrieves employee by ID (calls TVF)
- `sp_CreateEmployee` - Creates new employee (uses scalar functions for validation)
- `sp_UpdateEmployee` - Updates employee (uses scalar functions for validation)
- `sp_DeleteEmployee` - Deletes employee

#### Department Operations
- `sp_GetAllDepartments` - Retrieves all departments (calls TVF)
- `sp_CreateDepartment` - Creates new department (uses scalar function)
- `sp_UpdateDepartment` - Updates department (uses scalar function)
- `sp_DeleteDepartment` - Deletes department (uses scalar function to check dependencies)

#### Designation Operations
- `sp_GetAllDesignations` - Retrieves all designations (calls TVF)
- `sp_CreateDesignation` - Creates new designation (uses scalar function)
- `sp_UpdateDesignation` - Updates designation (uses scalar function)
- `sp_DeleteDesignation` - Deletes designation (uses scalar function to check dependencies)

#### Post Operations
- `sp_GetAllPosts` - Retrieves all posts (calls TVF)
- `sp_CreatePost` - Creates new post (uses scalar function)
- `sp_UpdatePost` - Updates post (uses scalar function)
- `sp_DeletePost` - Deletes post (uses scalar function to check dependencies)

## Execution Instructions

### Step 1: Execute the SQL Script

#### Option A: Using SQL Server Management Studio (SSMS)
```sql
-- 1. Open SSMS and connect to your SQL Server instance
-- 2. Open the file: StoredProceduresAndFunctions.sql
-- 3. Ensure you're connected to the HRMSDB database
-- 4. Press F5 or click Execute
```

#### Option B: Using Command Line
```bash
cd HRMSAPI/Database
chmod +x execute_sql.sh
./execute_sql.sh
```

#### Option C: Using sqlcmd
```bash
sqlcmd -S localhost -d HRMSDB -U your_username -P your_password -i StoredProceduresAndFunctions.sql
```

#### Option D: From VS Code Terminal
```bash
# Navigate to Database folder
cd HRMSAPI/Database

# Execute the SQL script (Windows with SQL Server)
sqlcmd -S localhost -d HRMSDB -E -i StoredProceduresAndFunctions.sql
```

### Step 2: Verify Installation

```sql
-- Check if all functions are created
SELECT ROUTINE_NAME, ROUTINE_TYPE 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'FUNCTION'
ORDER BY ROUTINE_NAME;

-- Check if all stored procedures are created
SELECT ROUTINE_NAME 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;
```

Expected Results:
- **10 Scalar Functions**
- **10 Table-Valued Functions**
- **16 Stored Procedures**

### Step 3: Test the Implementation

```sql
-- Test: Get all employees (uses SP → TVF)
EXEC sp_GetAllEmployees;

-- Test: Create employee (uses SP → Scalar Functions)
DECLARE @Result INT, @Message NVARCHAR(500);
EXEC sp_CreateEmployee 
    @FullName = 'John Doe',
    @Email = 'john.doe@example.com',
    @MobileNumber = '1234567890',
    @Result = @Result OUTPUT,
    @Message = @Message OUTPUT;
SELECT @Result AS Result, @Message AS Message;

-- Test: Get employee by ID (uses SP → TVF)
EXEC sp_GetEmployeeById @Id = 1;

-- Test: Scalar function directly
SELECT dbo.fn_CheckEmployeeEmailExists('john.doe@example.com', NULL) AS EmailExists;

-- Test: Table-valued function directly
SELECT * FROM dbo.tvf_GetAllEmployees();
```

## Code Structure

### Service Layer Pattern
All services follow this pattern:

```csharp
public async Task<List<Entity>> GetAllEntitiesAsync()
{
    // Calls SP which calls TVF
    return await _context.Set<Entity>()
        .FromSqlRaw("EXEC sp_GetAllEntities")
        .ToListAsync();
}

public async Task<(int Result, string Message)> CreateEntityAsync(Entity entity)
{
    // Setup output parameters
    var resultParam = new SqlParameter { /* ... */ };
    var messageParam = new SqlParameter { /* ... */ };
    
    // Call SP (which uses scalar functions for validation)
    await _context.Database.ExecuteSqlRawAsync(
        "EXEC sp_CreateEntity @Param1, @Param2, @Result OUTPUT, @Message OUTPUT",
        new SqlParameter("@Param1", entity.Property1),
        new SqlParameter("@Param2", entity.Property2),
        resultParam,
        messageParam
    );
    
    return ((int)resultParam.Value, messageParam.Value?.ToString() ?? "");
}
```

### Controller Layer Pattern
All controllers follow this pattern:

```csharp
[HttpGet]
public async Task<IActionResult> GetEntities()
{
    var entities = await _service.GetAllEntitiesAsync();
    return Ok(entities);
}

[HttpPost]
public async Task<IActionResult> CreateEntity([FromBody] Entity entity)
{
    if (!ModelState.IsValid) return BadRequest(ModelState);
    
    var (result, message) = await _service.CreateEntityAsync(entity);
    
    if (result < 0)
        return BadRequest(message);
    
    entity.Id = result;
    return Ok(entity);
}
```

## Benefits of This Architecture

1. **Separation of Concerns**: Business logic in database, application logic in code
2. **Performance**: Compiled stored procedures execute faster
3. **Security**: No direct table access, prevents SQL injection
4. **Reusability**: Functions can be reused across multiple SPs
5. **Maintainability**: Database logic centralized in SQL files
6. **Validation**: Scalar functions provide consistent validation across operations
7. **Data Integrity**: Complex validations handled at database level

## Authentication Exception

Authentication operations (Register, Login, Logout, Password Reset) continue to use **Entity Framework** because:
- They interact with `AspNetUsers` and Identity tables
- Identity framework handles password hashing and validation
- Token generation happens in application layer
- No business logic functions needed for these operations

Files that use Entity Framework:
- [AuthController.cs](../Controllers/AuthController.cs)
- Authentication-related operations in services

## Troubleshooting

### Error: "Invalid object name 'sp_GetAllEmployees'"
**Solution**: Execute the SQL script to create stored procedures

### Error: "Could not find stored procedure 'sp_CreateEmployee'"
**Solution**: Ensure you're connected to the HRMSDB database when executing the script

### Error: "The connection string is invalid"
**Solution**: Check [appsettings.json](../appsettings.json) connection string

### Error: Output parameters return NULL
**Solution**: Ensure parameters are declared with OUTPUT direction in both SQL and C# code

## Performance Considerations

1. **Indexing**: Ensure proper indexes on:
   - Employee.Email
   - Employee.MobileNumber
   - Employee.DepartmentId
   - Employee.DesignationId
   - Employee.PostId

2. **Execution Plans**: Review execution plans for slow queries

3. **Statistics**: Keep statistics updated:
```sql
UPDATE STATISTICS Employees;
UPDATE STATISTICS Departments;
UPDATE STATISTICS Designations;
UPDATE STATISTICS Posts;
```

## Maintenance

### Adding New CRUD Operations
1. Create scalar functions for validation (if needed)
2. Create table-valued function for data retrieval (if needed)
3. Create stored procedures for CRUD operations
4. Update Service interface and implementation
5. Update Controller with new endpoints

### Modifying Existing Operations
1. Update the SQL function/stored procedure
2. Test with direct SQL execution
3. Update C# service layer if parameters changed
4. Test API endpoints

## Summary

Your HRMS application now uses:
- ✅ **Stored Procedures** for all CRUD operations
- ✅ **Table-Valued Functions** for SELECT operations
- ✅ **Scalar Functions** for validations and business logic
- ✅ **Entity Framework** only for authentication operations

This ensures optimal performance, security, and maintainability!
