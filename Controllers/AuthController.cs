using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using HRMSAPI.Models;
using HRMSAPI.Models.DTOs;
using Microsoft.AspNetCore.Authorization;

namespace HRMSAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IConfiguration _configuration;

        public AuthController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userExists = await _userManager.FindByEmailAsync(model.Email);
            if (userExists != null)
                return Conflict(new { message = "A user with this email address already exists. Please use a different email or try logging in." });

            var user = new ApplicationUser
            {
                UserName = model.Email,
                Email = model.Email,
                FullName = model.FullName
            };

            var result = await _userManager.CreateAsync(user, model.Password);

            if (!result.Succeeded)
                return BadRequest(result.Errors);

            return Ok(new { message = "User registered successfully!" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user != null && await _userManager.CheckPasswordAsync(user, model.Password))
            {
                var (token, expiration) = GenerateJwtToken(user, model.RememberMe);
                return Ok(new AuthResponseDto
                {
                    Token = token,
                    Email = user.Email!,
                    FullName = user.FullName,
                    Expiration = expiration
                });
            }
            return Unauthorized(new { message = "Invalid email or password" });
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            // 1. Try finding by ID (Standard)
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId);

            // 2. Fallback: Try finding by Email if ID lookup failed
            if (user == null)
            {
                var email = User.FindFirst(ClaimTypes.Email)?.Value;
                if (!string.IsNullOrEmpty(email))
                {
                    user = await _userManager.FindByEmailAsync(email);
                }
            }

            // 3. Fallback: Try finding by 'sub' claim (which is often Email)
            if (user == null)
            {
                var sub = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
                if (!string.IsNullOrEmpty(sub))
                {
                    user = await _userManager.FindByEmailAsync(sub);
                }
            }

            if (user == null) return NotFound("User not found in database.");

            return Ok(new { user.FullName, user.Email });
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] RegisterDto model)
        {
            // 1. Try finding by ID
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId);

            // 2. Fallback: Try finding by Email
            if (user == null)
            {
                var email = User.FindFirst(ClaimTypes.Email)?.Value;
                if (!string.IsNullOrEmpty(email)) user = await _userManager.FindByEmailAsync(email);
            }

            if (user == null) return NotFound("User not found.");

            user.FullName = model.FullName;
            var result = await _userManager.UpdateAsync(user);

            if (!result.Succeeded) return BadRequest(result.Errors);

            return Ok(new { message = "Profile updated successfully" });
        }

        [Authorize]
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordDto model)
        {
            // 1. Try finding by ID
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId);

            // 2. Fallback: Try finding by Email
            if (user == null)
            {
                var email = User.FindFirst(ClaimTypes.Email)?.Value;
                if (!string.IsNullOrEmpty(email)) user = await _userManager.FindByEmailAsync(email);
            }

            if (user == null) return NotFound("User not found.");

            var result = await _userManager.ChangePasswordAsync(user, model.OldPassword, model.NewPassword);

            if (!result.Succeeded) return BadRequest(result.Errors);

            return Ok(new { message = "Password changed successfully" });
        }

        private (string token, DateTime expiration) GenerateJwtToken(ApplicationUser user, bool rememberMe)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                // We store Email in Sub (Subject) and ClaimTypes.Email
                new Claim(JwtRegisteredClaimNames.Sub, user.Email!),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                // We store ID in NameIdentifier
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.Email, user.Email!)
            };

            var expiryMinutes = rememberMe
                ? Convert.ToDouble(_configuration["Jwt:RememberMeExpiryInMinutes"])
                : Convert.ToDouble(_configuration["Jwt:ExpiryInMinutes"]);

            var expiration = DateTime.UtcNow.AddMinutes(expiryMinutes);

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: expiration,
                signingCredentials: credentials
            );

            return (new JwtSecurityTokenHandler().WriteToken(token), expiration);
        }
    }
}