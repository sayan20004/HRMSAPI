using Microsoft.AspNetCore.Mvc;
using HRMSAPI.Models;
using HRMSAPI.Services;

namespace HRMSAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MasterController : ControllerBase
    {
        private readonly IMasterService _masterService;

        public MasterController(IMasterService masterService)
        {
            _masterService = masterService;
        }

        // --- DEPARTMENTS ---
        [HttpGet("departments")]
        public async Task<IActionResult> GetDepartments()
        {
            // Call function which calls Stored Procedure → TVF
            var departments = await _masterService.GetAllDepartmentsAsync();
            return Ok(departments);
        }

        [HttpPost("departments")]
        public async Task<IActionResult> CreateDepartment([FromBody] Department dept)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Call function which calls Stored Procedure (INSERT)
            var (result, message) = await _masterService.CreateDepartmentAsync(dept);

            if (result < 0)
                return Conflict(message);

            dept.Id = result;
            return Ok(dept);
        }

        [HttpPut("departments/{id}")]
        public async Task<IActionResult> UpdateDepartment(int id, [FromBody] Department dept)
        {
            if (id != dept.Id) return BadRequest();

            // Call function which calls Stored Procedure (UPDATE)
            var (result, message) = await _masterService.UpdateDepartmentAsync(dept);

            if (result < 0)
                return BadRequest(message);

            return Ok(new { message });
        }

        [HttpDelete("departments/{id}")]
        public async Task<IActionResult> DeleteDepartment(int id)
        {
            // Call function which calls Stored Procedure (DELETE)
            var (result, message) = await _masterService.DeleteDepartmentAsync(id);

            if (result < 0)
                return BadRequest(message);

            return Ok(new { message });
        }

        // --- DESIGNATIONS ---
        [HttpGet("designations")]
        public async Task<IActionResult> GetDesignations()
        {
            // Call function which calls Stored Procedure → TVF
            var designations = await _masterService.GetAllDesignationsAsync();
            return Ok(designations);
        }

        [HttpPost("designations")]
        public async Task<IActionResult> CreateDesignation([FromBody] Designation desig)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Call function which calls Stored Procedure (INSERT)
            var (result, message) = await _masterService.CreateDesignationAsync(desig);

            if (result < 0)
                return Conflict(message);

            desig.Id = result;
            return Ok(desig);
        }

        [HttpPut("designations/{id}")]
        public async Task<IActionResult> UpdateDesignation(int id, [FromBody] Designation desig)
        {
            if (id != desig.Id) return BadRequest();

            // Call function which calls Stored Procedure (UPDATE)
            var (result, message) = await _masterService.UpdateDesignationAsync(desig);

            if (result < 0)
                return BadRequest(message);

            return Ok(new { message });
        }

        [HttpDelete("designations/{id}")]
        public async Task<IActionResult> DeleteDesignation(int id)
        {
            // Call function which calls Stored Procedure (DELETE)
            var (result, message) = await _masterService.DeleteDesignationAsync(id);

            if (result < 0)
                return BadRequest(message);

            return Ok(new { message });
        }

        // --- POSTS ---
        [HttpGet("posts")]
        public async Task<IActionResult> GetPosts()
        {
            // Call function which calls Stored Procedure → TVF
            var posts = await _masterService.GetAllPostsAsync();
            return Ok(posts);
        }

        [HttpPost("posts")]
        public async Task<IActionResult> CreatePost([FromBody] Post post)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Call function which calls Stored Procedure (INSERT)
            var (result, message) = await _masterService.CreatePostAsync(post);

            if (result < 0)
                return Conflict(message);

            post.Id = result;
            return Ok(post);
        }

        [HttpPut("posts/{id}")]
        public async Task<IActionResult> UpdatePost(int id, [FromBody] Post post)
        {
            if (id != post.Id) return BadRequest();

            // Call function which calls Stored Procedure (UPDATE)
            var (result, message) = await _masterService.UpdatePostAsync(post);

            if (result < 0)
                return BadRequest(message);

            return Ok(new { message });
        }

        [HttpDelete("posts/{id}")]
        public async Task<IActionResult> DeletePost(int id)
        {
            // Call function which calls Stored Procedure (DELETE)
            var (result, message) = await _masterService.DeletePostAsync(id);

            if (result < 0)
                return BadRequest(message);

            return Ok(new { message });
        }
    }
}
