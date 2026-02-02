using HRMSAPI.Data;
using HRMSAPI.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace HRMSAPI.Services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly ApplicationDbContext _context;

        public EmployeeService(ApplicationDbContext context)
        {
            _context = context;
        }

        // Function to get all employees (calls Stored Procedure which calls TVF)
        public async Task<List<Employee>> GetAllEmployeesAsync()
        {
            return await _context.Set<Employee>()
                .FromSqlRaw("EXEC sp_GetAllEmployees")
                .ToListAsync();
        }

        // Function to get employee by ID (calls Stored Procedure which calls TVF)
        public async Task<Employee?> GetEmployeeByIdAsync(int id)
        {
            return await _context.Set<Employee>()
                .FromSqlRaw("EXEC sp_GetEmployeeById @Id={0}", id)
                .FirstOrDefaultAsync();
        }

        // Function to create employee (calls Stored Procedure)
        public async Task<(int Result, string Message, int EmployeeId)> CreateEmployeeAsync(Employee employee)
        {
            var resultParam = new SqlParameter
            {
                ParameterName = "@Result",
                SqlDbType = SqlDbType.Int,
                Direction = ParameterDirection.Output
            };

            var messageParam = new SqlParameter
            {
                ParameterName = "@Message",
                SqlDbType = SqlDbType.NVarChar,
                Size = 500,
                Direction = ParameterDirection.Output
            };

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC sp_CreateEmployee @FullName, @Email, @MobileNumber, @Address, @DateOfBirth, @DepartmentId, @DesignationId, @PostId, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@FullName", employee.FullName),
                new SqlParameter("@Email", employee.Email),
                new SqlParameter("@MobileNumber", (object)employee.MobileNumber ?? DBNull.Value),
                new SqlParameter("@Address", (object)employee.Address ?? DBNull.Value),
                new SqlParameter("@DateOfBirth", (object)employee.DateOfBirth ?? DBNull.Value),
                new SqlParameter("@DepartmentId", (object)employee.DepartmentId ?? DBNull.Value),
                new SqlParameter("@DesignationId", (object)employee.DesignationId ?? DBNull.Value),
                new SqlParameter("@PostId", (object)employee.PostId ?? DBNull.Value),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";
            
            return (result, message, result);
        }

        // Function to update employee (calls Stored Procedure)
        public async Task<(int Result, string Message)> UpdateEmployeeAsync(Employee employee)
        {
            var resultParam = new SqlParameter
            {
                ParameterName = "@Result",
                SqlDbType = SqlDbType.Int,
                Direction = ParameterDirection.Output
            };

            var messageParam = new SqlParameter
            {
                ParameterName = "@Message",
                SqlDbType = SqlDbType.NVarChar,
                Size = 500,
                Direction = ParameterDirection.Output
            };

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC sp_UpdateEmployee @Id, @FullName, @Email, @MobileNumber, @Address, @DateOfBirth, @DepartmentId, @DesignationId, @PostId, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", employee.Id),
                new SqlParameter("@FullName", employee.FullName),
                new SqlParameter("@Email", employee.Email),
                new SqlParameter("@MobileNumber", (object)employee.MobileNumber ?? DBNull.Value),
                new SqlParameter("@Address", (object)employee.Address ?? DBNull.Value),
                new SqlParameter("@DateOfBirth", (object)employee.DateOfBirth ?? DBNull.Value),
                new SqlParameter("@DepartmentId", (object)employee.DepartmentId ?? DBNull.Value),
                new SqlParameter("@DesignationId", (object)employee.DesignationId ?? DBNull.Value),
                new SqlParameter("@PostId", (object)employee.PostId ?? DBNull.Value),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to delete employee (calls Stored Procedure)
        public async Task<(int Result, string Message)> DeleteEmployeeAsync(int id)
        {
            var resultParam = new SqlParameter
            {
                ParameterName = "@Result",
                SqlDbType = SqlDbType.Int,
                Direction = ParameterDirection.Output
            };

            var messageParam = new SqlParameter
            {
                ParameterName = "@Message",
                SqlDbType = SqlDbType.NVarChar,
                Size = 500,
                Direction = ParameterDirection.Output
            };

            await _context.Database.ExecuteSqlRawAsync(
                "EXEC sp_DeleteEmployee @Id, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", id),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }
    }
}
