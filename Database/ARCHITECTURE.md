# HRMS Architecture - Complete Flow Documentation

## 🎯 Architecture Overview

**Complete Request Flow:**
```
HTTP Request → Controller → Service Function → Stored Procedure → Table-Valued Function → Database
```

## 📊 Data Flow Diagram

### READ Operations (GET):
```
Controller.GetEmployees()
    ↓
Service.GetAllEmployeesAsync()
    ↓
"EXEC sp_GetAllEmployees"
    ↓
sp_GetAllEmployees (Stored Procedure)
    ↓
SELECT * FROM tvf_GetAllEmployees() (Table-Valued Function)
    ↓
SELECT with JOINs from Database Tables
    ↓
Returns Result Set
```

### WRITE Operations (INSERT/UPDATE/DELETE):
```
Controller.CreateEmployee()
    ↓
Service.CreateEmployeeAsync()
    ↓
"EXEC sp_CreateEmployee @Params, @Result OUTPUT, @Message OUTPUT"
    ↓
sp_CreateEmployee (Stored Procedure)
    ↓
- Validates using Scalar Functions
- INSERT INTO Employees
- Returns @Result (ID) and @Message
    ↓
Returns (Result, Message, EmployeeId) to Controller
```

## 🗂️ Database Layer

### Scalar Functions (Validation)
- `fn_CheckEmployeeEmailExists` - Check duplicate email
- `fn_CheckEmployeeMobileExists` - Check duplicate mobile
- `fn_GetTotalEmployeeCount` - Get employee count
- `fn_CheckDepartmentNameExists` - Check duplicate department

### Table-Valued Functions (SELECT with JOINs)
- `tvf_GetAllEmployees()` - Returns employees with dept/designation/post names
- `tvf_GetEmployeeById(@Id)` - Returns single employee with joins
- `tvf_GetAllDepartments()` - Returns all departments
- `tvf_GetAllDesignations()` - Returns all designations
- `tvf_GetAllPosts()` - Returns all posts

### Stored Procedures - READ (Call TVFs)
```sql
-- These SPs provide consistent interface by wrapping TVFs
sp_GetAllEmployees          → Calls tvf_GetAllEmployees()
sp_GetEmployeeById          → Calls tvf_GetEmployeeById(@Id)
sp_GetAllDepartments        → Calls tvf_GetAllDepartments()
sp_GetAllDesignations       → Calls tvf_GetAllDesignations()
sp_GetAllPosts              → Calls tvf_GetAllPosts()
```

### Stored Procedures - WRITE (CUD Operations)
```sql
-- INSERT
sp_CreateEmployee           → Validates + INSERT + Returns @Result, @Message
sp_CreateDepartment         → Validates + INSERT + Returns @Result, @Message
sp_CreateDesignation        → INSERT + Returns @Result, @Message
sp_CreatePost               → INSERT + Returns @Result, @Message

-- UPDATE
sp_UpdateEmployee           → Validates + UPDATE + Returns @Result, @Message
sp_UpdateDepartment         → Validates + UPDATE + Returns @Result, @Message
sp_UpdateDesignation        → UPDATE + Returns @Result, @Message

-- DELETE
sp_DeleteEmployee           → Soft delete + Returns @Result, @Message
sp_DeleteDepartment         → Check references + DELETE + Returns @Result, @Message
sp_DeleteDesignation        → Check references + DELETE + Returns @Result, @Message
sp_DeletePost               → Check references + DELETE + Returns @Result, @Message
```

## 💻 C# Service Layer

### EmployeeService.cs
```csharp
// READ - Calls SP which calls TVF
GetAllEmployeesAsync()      → EXEC sp_GetAllEmployees
GetEmployeeByIdAsync(id)    → EXEC sp_GetEmployeeById @Id

// WRITE - Calls SP with OUTPUT parameters
CreateEmployeeAsync()       → EXEC sp_CreateEmployee @Params, @Result OUT, @Message OUT
UpdateEmployeeAsync()       → EXEC sp_UpdateEmployee @Params, @Result OUT, @Message OUT
DeleteEmployeeAsync()       → EXEC sp_DeleteEmployee @Id, @Result OUT, @Message OUT
```

### MasterService.cs
```csharp
// DEPARTMENTS
GetAllDepartmentsAsync()    → EXEC sp_GetAllDepartments
CreateDepartmentAsync()     → EXEC sp_CreateDepartment @Params, @Result OUT, @Message OUT
UpdateDepartmentAsync()     → EXEC sp_UpdateDepartment @Params, @Result OUT, @Message OUT
DeleteDepartmentAsync()     → EXEC sp_DeleteDepartment @Id, @Result OUT, @Message OUT

// DESIGNATIONS
GetAllDesignationsAsync()   → EXEC sp_GetAllDesignations
CreateDesignationAsync()    → EXEC sp_CreateDesignation @Params, @Result OUT, @Message OUT
UpdateDesignationAsync()    → EXEC sp_UpdateDesignation @Params, @Result OUT, @Message OUT
DeleteDesignationAsync()    → EXEC sp_DeleteDesignation @Id, @Result OUT, @Message OUT

// POSTS
GetAllPostsAsync()          → EXEC sp_GetAllPosts
CreatePostAsync()           → EXEC sp_CreatePost @Name, @Result OUT, @Message OUT
DeletePostAsync()           → EXEC sp_DeletePost @Id, @Result OUT, @Message OUT
```

## 🎮 Controller Layer

### EmployeeController.cs
```csharp
GET    /api/employee              → GetEmployees()         → _employeeService.GetAllEmployeesAsync()
GET    /api/employee/{id}         → GetEmployee(id)        → _employeeService.GetEmployeeByIdAsync(id)
POST   /api/employee              → CreateEmployee()       → _employeeService.CreateEmployeeAsync()
PUT    /api/employee/{id}         → UpdateEmployee()       → _employeeService.UpdateEmployeeAsync()
DELETE /api/employee/{id}         → DeleteEmployee()       → _employeeService.DeleteEmployeeAsync()
```

### MasterController.cs
```csharp
// DEPARTMENTS
GET    /api/master/departments           → _masterService.GetAllDepartmentsAsync()
POST   /api/master/departments           → _masterService.CreateDepartmentAsync()
PUT    /api/master/departments/{id}      → _masterService.UpdateDepartmentAsync()
DELETE /api/master/departments/{id}      → _masterService.DeleteDepartmentAsync()

// DESIGNATIONS
GET    /api/master/designations          → _masterService.GetAllDesignationsAsync()
POST   /api/master/designations          → _masterService.CreateDesignationAsync()
PUT    /api/master/designations/{id}     → _masterService.UpdateDesignationAsync()
DELETE /api/master/designations/{id}     → _masterService.DeleteDesignationAsync()

// POSTS
GET    /api/master/posts                 → _masterService.GetAllPostsAsync()
POST   /api/master/posts                 → _masterService.CreatePostAsync()
DELETE /api/master/posts/{id}            → _masterService.DeletePostAsync()
```

## 🔄 Complete Example Flow

### Example: Create Employee

1. **HTTP Request**
```http
POST /api/employee
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "mobileNumber": "1234567890"
}
```

2. **Controller** (EmployeeController.cs)
```csharp
public async Task<IActionResult> CreateEmployee([FromBody] Employee employee)
{
    var (result, message, employeeId) = await _employeeService.CreateEmployeeAsync(employee);
    
    if (result < 0) return BadRequest(message);
    
    employee.Id = employeeId;
    return CreatedAtAction(nameof(GetEmployee), new { id = employeeId }, employee);
}
```

3. **Service** (EmployeeService.cs)
```csharp
public async Task<(int, string, int)> CreateEmployeeAsync(Employee employee)
{
    await _context.Database.ExecuteSqlRawAsync(
        "EXEC sp_CreateEmployee @FullName, @Email, ..., @Result OUTPUT, @Message OUTPUT",
        parameters...
    );
    
    int result = (int)resultParam.Value;
    string message = messageParam.Value?.ToString() ?? "";
    
    return (result, message, result);
}
```

4. **Database** (sp_CreateEmployee)
```sql
CREATE PROCEDURE sp_CreateEmployee
    @FullName NVARCHAR(MAX),
    @Email NVARCHAR(256),
    @Result INT OUTPUT,
    @Message NVARCHAR(500) OUTPUT
AS
BEGIN
    -- Validate using scalar function
    IF dbo.fn_CheckEmployeeEmailExists(@Email, NULL) = 1
    BEGIN
        SET @Result = -1;
        SET @Message = 'Email already exists';
        RETURN;
    END
    
    -- Insert data
    INSERT INTO Employees (FullName, Email, ...)
    VALUES (@FullName, @Email, ...);
    
    SET @Result = SCOPE_IDENTITY();
    SET @Message = 'Employee created successfully';
END
```

5. **HTTP Response**
```json
{
  "id": 123,
  "fullName": "John Doe",
  "email": "john@example.com",
  "mobileNumber": "1234567890"
}
```

## ✅ Architecture Benefits

1. **Consistent Interface**: All operations use `EXEC sp_*` pattern
2. **Separation of Concerns**: 
   - Controllers handle HTTP
   - Services handle business logic
   - SPs handle database operations
   - TVFs handle complex queries with joins
3. **Reusability**: SPs can be called from multiple places
4. **Security**: SQL injection protection, parameterized queries
5. **Performance**: Compiled execution plans in database
6. **Maintainability**: Business logic in one place (database)
7. **Testability**: Each layer can be tested independently

## 📁 File Structure

```
HRMSAPI/
├── Controllers/
│   ├── EmployeeController.cs    → Calls EmployeeService
│   └── MasterController.cs      → Calls MasterService
├── Services/
│   ├── IEmployeeService.cs      → Interface
│   ├── EmployeeService.cs       → Calls sp_* with EXEC
│   ├── IMasterService.cs        → Interface
│   └── MasterService.cs         → Calls sp_* with EXEC
└── Database/
    ├── StoredProceduresAndFunctions.sql  → All DB objects
    ├── README.md                         → Setup instructions
    └── TestQueries.sql                   → Test suite
```

## 🚀 Execution Instructions

1. **Execute SQL Script** (in SSMS or Azure Data Studio):
```sql
USE HRMSDB;
GO
-- Execute entire StoredProceduresAndFunctions.sql
```

2. **Register Services** (Program.cs):
```csharp
builder.Services.AddScoped<IEmployeeService, EmployeeService>();
builder.Services.AddScoped<IMasterService, MasterService>();
```

3. **Run Application**:
```bash
cd HRMSAPI && dotnet run
```

4. **Test Endpoints** using Swagger at:
```
https://localhost:5001/swagger
```

## 🎯 Key Takeaways

- **All READ operations**: Controller → Service → `EXEC sp_Get*` → TVF → Database
- **All WRITE operations**: Controller → Service → `EXEC sp_Create/Update/Delete*` → Database
- **Consistent pattern**: Everything uses stored procedures
- **Wrapped TVFs**: SPs call TVFs for consistency
- **Clean code**: Controllers are 3-5 lines per method
- **Enterprise-ready**: Scalable, maintainable, secure architecture
