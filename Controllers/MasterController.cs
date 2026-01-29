using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using HRMSAPI.Data;
using HRMSAPI.Models;
using Microsoft.AspNetCore.Authorization;

namespace HRMSAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class MasterController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public MasterController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet("departments")]
        public async Task<IActionResult> GetDepartments()
        {
            return Ok(await _context.Departments.ToListAsync());
        }

        [HttpPost("departments")]
        public async Task<IActionResult> AddDepartment([FromBody] Department dept)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            _context.Departments.Add(dept);
            await _context.SaveChangesAsync();
            return Ok(dept);
        }

        [HttpGet("designations")]
        public async Task<IActionResult> GetDesignations()
        {
            return Ok(await _context.Designations.ToListAsync());
        }

        [HttpPost("designations")]
        public async Task<IActionResult> AddDesignation([FromBody] Designation desig)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            _context.Designations.Add(desig);
            await _context.SaveChangesAsync();
            return Ok(desig);
        }
    }
}