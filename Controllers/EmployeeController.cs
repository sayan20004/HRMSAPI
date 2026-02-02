using Microsoft.AspNetCore.Mvc;
using HRMSAPI.Models;
using Microsoft.AspNetCore.Authorization;
using HRMSAPI.Services;

namespace HRMSAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmployeeController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;

        public EmployeeController(IEmployeeService employeeService)
        {
            _employeeService = employeeService;
        }

        [HttpGet]
        public async Task<IActionResult> GetEmployees()
        {
            // Call function which calls Stored Procedure → TVF
            var employees = await _employeeService.GetAllEmployeesAsync();
            return Ok(employees);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetEmployee(int id)
        {
            // Call function which calls Stored Procedure → TVF
            var employee = await _employeeService.GetEmployeeByIdAsync(id);
            if (employee == null) return NotFound();
            return Ok(employee);
        }

        [HttpPost]
        public async Task<IActionResult> CreateEmployee([FromBody] Employee employee)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            // Call function which calls Stored Procedure (INSERT)
            var (result, message, employeeId) = await _employeeService.CreateEmployeeAsync(employee);

            if (result < 0)
                return BadRequest(message);

            employee.Id = employeeId;
            return CreatedAtAction(nameof(GetEmployee), new { id = employeeId }, employee);
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateEmployee(int id, [FromBody] Employee employee)
        {
            if (id != employee.Id) return BadRequest();

            // Call function which calls Stored Procedure (UPDATE)
            var (result, message) = await _employeeService.UpdateEmployeeAsync(employee);

            if (result < 0)
                return BadRequest(message);

            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteEmployee(int id)
        {
            // Call function which calls Stored Procedure (DELETE)
            var (result, message) = await _employeeService.DeleteEmployeeAsync(id);

            if (result < 0)
                return BadRequest(message);

            return NoContent();
        }
    }
}