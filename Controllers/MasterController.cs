using Microsoft.AspNetCore.Mvc;
using HRMSAPI.Data;
using HRMSAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HRMSAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class MasterController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MasterController(ApplicationDbContext context)
        {
            _context = context;
        }

        // --- DEPARTMENTS ---
        [HttpGet("departments")]
        public async Task<IActionResult> GetDepartments() => Ok(await _context.Departments.ToListAsync());

        [HttpPost("departments")]
        public async Task<IActionResult> CreateDepartment([FromBody] Department dept)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            _context.Departments.Add(dept);
            await _context.SaveChangesAsync();
            return Ok(dept);
        }

        // --- DESIGNATIONS ---
        [HttpGet("designations")]
        public async Task<IActionResult> GetDesignations() => Ok(await _context.Designations.ToListAsync());

        [HttpPost("designations")]
        public async Task<IActionResult> CreateDesignation([FromBody] Designation desig)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            _context.Designations.Add(desig);
            await _context.SaveChangesAsync();
            return Ok(desig);
        }

        // --- POSTS (NEW) ---
        [HttpGet("posts")]
        public async Task<IActionResult> GetPosts() => Ok(await _context.Posts.ToListAsync());

        [HttpPost("posts")]
        public async Task<IActionResult> CreatePost([FromBody] Post post)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            _context.Posts.Add(post);
            await _context.SaveChangesAsync();
            return Ok(post);
        }
    }
}