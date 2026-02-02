using HRMSAPI.Models;

namespace HRMSAPI.Services
{
    public interface IMasterService
    {
        // Department Functions
        Task<List<Department>> GetAllDepartmentsAsync();
        Task<(int Result, string Message)> CreateDepartmentAsync(Department department);
        Task<(int Result, string Message)> UpdateDepartmentAsync(Department department);
        Task<(int Result, string Message)> DeleteDepartmentAsync(int id);

        // Designation Functions
        Task<List<Designation>> GetAllDesignationsAsync();
        Task<(int Result, string Message)> CreateDesignationAsync(Designation designation);
        Task<(int Result, string Message)> UpdateDesignationAsync(Designation designation);
        Task<(int Result, string Message)> DeleteDesignationAsync(int id);

        // Post Functions
        Task<List<Post>> GetAllPostsAsync();
        Task<(int Result, string Message)> CreatePostAsync(Post post);
        Task<(int Result, string Message)> UpdatePostAsync(Post post);
        Task<(int Result, string Message)> DeletePostAsync(int id);
    }
}
