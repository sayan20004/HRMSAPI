using HRMSAPI.Models;

namespace HRMSAPI.Services
{
    public interface IEmployeeService
    {
        Task<List<Employee>> GetAllEmployeesAsync();
        Task<Employee?> GetEmployeeByIdAsync(int id);
        Task<(int Result, string Message, int EmployeeId)> CreateEmployeeAsync(Employee employee);
        Task<(int Result, string Message)> UpdateEmployeeAsync(Employee employee);
        Task<(int Result, string Message)> DeleteEmployeeAsync(int id);
    }
}
