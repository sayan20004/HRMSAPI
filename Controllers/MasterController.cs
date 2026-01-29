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
        [HttpDelete("departments/{id}")]
        public async Task<IActionResult> DeleteDepartment(int id)
        {
            var dept = await _context.Departments.FindAsync(id);
            if (dept == null) return NotFound("Department not found");

            // Prevent deletion if employees are using it
            if (await _context.Employees.AnyAsync(e => e.DepartmentId == id))
                return BadRequest("Cannot delete: Assigned to existing employees.");

            _context.Departments.Remove(dept);
            await _context.SaveChangesAsync();
            return Ok();
        }

        [HttpDelete("designations/{id}")]
        public async Task<IActionResult> DeleteDesignation(int id)
        {
            var desig = await _context.Designations.FindAsync(id);
            if (desig == null) return NotFound("Designation not found");

            if (await _context.Employees.AnyAsync(e => e.DesignationId == id))
                return BadRequest("Cannot delete: Assigned to existing employees.");

            _context.Designations.Remove(desig);
            await _context.SaveChangesAsync();
            return Ok();
        }
        [HttpGet("departments")]
        public async Task<IActionResult> GetDepartments()
        {
            return Ok(await _context.Departments.ToListAsync());
        }
        [HttpPut("departments/{id}")]
        public async Task<IActionResult> UpdateDepartment(int id, [FromBody] Department dept)
        {
            if (id != dept.Id) return BadRequest("ID mismatch");

            if (!ModelState.IsValid) return BadRequest(ModelState);

            _context.Entry(dept).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.Departments.Any(e => e.Id == id)) return NotFound();
                throw;
            }

            return Ok(dept);
        }

        [HttpPut("designations/{id}")]
        public async Task<IActionResult> UpdateDesignation(int id, [FromBody] Designation desig)
        {
            if (id != desig.Id) return BadRequest("ID mismatch");

            if (!ModelState.IsValid) return BadRequest(ModelState);

            _context.Entry(desig).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!_context.Designations.Any(e => e.Id == id)) return NotFound();
                throw;
            }

            return Ok(desig);
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