using HRMSAPI.Data;
using HRMSAPI.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace HRMSAPI.Services
{
    public class MasterService : IMasterService
    {
        private readonly ApplicationDbContext _context;

        public MasterService(ApplicationDbContext context)
        {
            _context = context;
        }

        #region Department Functions

        // Function to get all departments (calls Stored Procedure which calls TVF)
        public async Task<List<Department>> GetAllDepartmentsAsync()
        {
            return await _context.Set<Department>()
                .FromSqlRaw("EXEC sp_GetAllDepartments")
                .ToListAsync();
        }

        // Function to create department (calls Stored Procedure)
        public async Task<(int Result, string Message)> CreateDepartmentAsync(Department department)
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
                "EXEC sp_CreateDepartment @Name, @Code, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Name", department.Name),
                new SqlParameter("@Code", (object)department.Code ?? DBNull.Value),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to update department (calls Stored Procedure)
        public async Task<(int Result, string Message)> UpdateDepartmentAsync(Department department)
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
                "EXEC sp_UpdateDepartment @Id, @Name, @Code, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", department.Id),
                new SqlParameter("@Name", department.Name),
                new SqlParameter("@Code", (object)department.Code ?? DBNull.Value),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to delete department (calls Stored Procedure)
        public async Task<(int Result, string Message)> DeleteDepartmentAsync(int id)
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
                "EXEC sp_DeleteDepartment @Id, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", id),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        #endregion

        #region Designation Functions

        // Function to get all designations (calls Stored Procedure which calls TVF)
        public async Task<List<Designation>> GetAllDesignationsAsync()
        {
            return await _context.Set<Designation>()
                .FromSqlRaw("EXEC sp_GetAllDesignations")
                .ToListAsync();
        }

        // Function to create designation (calls Stored Procedure)
        public async Task<(int Result, string Message)> CreateDesignationAsync(Designation designation)
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
                "EXEC sp_CreateDesignation @Name, @Level, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Name", designation.Name),
                new SqlParameter("@Level", (object)designation.Level ?? DBNull.Value),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to update designation (calls Stored Procedure)
        public async Task<(int Result, string Message)> UpdateDesignationAsync(Designation designation)
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
                "EXEC sp_UpdateDesignation @Id, @Name, @Level, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", designation.Id),
                new SqlParameter("@Name", designation.Name),
                new SqlParameter("@Level", (object)designation.Level ?? DBNull.Value),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to delete designation (calls Stored Procedure)
        public async Task<(int Result, string Message)> DeleteDesignationAsync(int id)
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
                "EXEC sp_DeleteDesignation @Id, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", id),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        #endregion

        #region Post Functions

        // Function to get all posts (calls Stored Procedure which calls TVF)
        public async Task<List<Post>> GetAllPostsAsync()
        {
            return await _context.Set<Post>()
                .FromSqlRaw("EXEC sp_GetAllPosts")
                .ToListAsync();
        }

        // Function to create post (calls Stored Procedure)
        public async Task<(int Result, string Message)> CreatePostAsync(Post post)
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
                "EXEC sp_CreatePost @Name, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Name", post.Name),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to update post (calls Stored Procedure)
        public async Task<(int Result, string Message)> UpdatePostAsync(Post post)
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
                "EXEC sp_UpdatePost @Id, @Name, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", post.Id),
                new SqlParameter("@Name", post.Name),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        // Function to delete post (calls Stored Procedure)
        public async Task<(int Result, string Message)> DeletePostAsync(int id)
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
                "EXEC sp_DeletePost @Id, @Result OUTPUT, @Message OUTPUT",
                new SqlParameter("@Id", id),
                resultParam,
                messageParam
            );

            int result = (int)resultParam.Value;
            string message = messageParam.Value?.ToString() ?? "";

            return (result, message);
        }

        #endregion
    }
}
