using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using HRMSAPI.Models;
using HRMSAPI.Models.DTOs;
using HRMSAPI.Services;
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
        private readonly IEmailService _emailService;

        public AuthController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IConfiguration configuration,
            IEmailService emailService)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _configuration = configuration;
            _emailService = emailService;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var userExists = await _userManager.FindByEmailAsync(model.Email);
            if (userExists != null)
                return Conflict(new { message = "A user with this email address already exists." });

            var user = new ApplicationUser
            {
                UserName = model.Email,
                Email = model.Email,
                FullName = model.FullName
            };

            var result = await _userManager.CreateAsync(user, model.Password);

            if (!result.Succeeded)
                return BadRequest(result.Errors);

            var otp = new Random().Next(100000, 999999).ToString();
            user.OTP = otp;
            user.OTPExpiration = DateTime.UtcNow.AddMinutes(10);
            await _userManager.UpdateAsync(user);

            await _emailService.SendEmailAsync(user.Email, "Registration OTP", $"Your OTP is: {otp}");

            return Ok(new { message = "OTP sent to email." });
        }

        [HttpPost("verify-register-otp")]
        public async Task<IActionResult> VerifyRegisterOtp([FromBody] VerifyOtpDto model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null) return NotFound(new { message = "User not found" });

            if (user.OTP != model.Otp || user.OTPExpiration < DateTime.UtcNow)
            {
                return BadRequest(new { message = "Invalid or expired OTP" });
            }

            user.OTP = null;
            user.OTPExpiration = null;
            user.EmailConfirmed = true;
            await _userManager.UpdateAsync(user);

            return Ok(new { message = "Email verified successfully" });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user != null && await _userManager.CheckPasswordAsync(user, model.Password))
            {
                var otp = new Random().Next(100000, 999999).ToString();
                user.OTP = otp;
                user.OTPExpiration = DateTime.UtcNow.AddMinutes(10);
                await _userManager.UpdateAsync(user);

                // Use '!' to assert email is not null (since we found the user by email)
                await _emailService.SendEmailAsync(user.Email!, "Login OTP", $"Your Login OTP is: {otp}");

                return Ok(new { message = "OTP sent to email." });
            }
            return Unauthorized(new { message = "Invalid email or password" });
        }

        [HttpPost("verify-login-otp")]
        public async Task<IActionResult> VerifyLoginOtp([FromBody] VerifyOtpDto model)
        {
            var user = await _userManager.FindByEmailAsync(model.Email);
            if (user == null) return NotFound(new { message = "User not found" });

            // FIX 1: Verify OTP using Database fields (Removed incorrect IEmailService call)
            if (user.OTP != model.Otp || user.OTPExpiration < DateTime.UtcNow)
            {
                return BadRequest(new { message = "Invalid or expired OTP" });
            }

            // Clear OTP
            user.OTP = null;
            user.OTPExpiration = null;
            await _userManager.UpdateAsync(user);

            // FIX 2: Generate Token with Correct Expiration based on RememberMe
            var (token, expiration) = GenerateJwtToken(user, model.RememberMe);

            return Ok(new AuthResponseDto
            {
                Token = token,
                Email = user.Email!,
                FullName = user.FullName,
                Expiration = expiration
            });
        }

        [Authorize]
        [HttpGet("profile")]
        public async Task<IActionResult> GetProfile()
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId!);

            if (user == null)
            {
                var email = User.FindFirst(ClaimTypes.Email)?.Value;
                if (!string.IsNullOrEmpty(email)) user = await _userManager.FindByEmailAsync(email);
            }

            if (user == null) return NotFound("User not found.");

            return Ok(new { user.FullName, user.Email });
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile([FromBody] RegisterDto model)
        {
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId!);

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
            var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            var user = await _userManager.FindByIdAsync(userId!);

            if (user == null) return NotFound("User not found.");

            var result = await _userManager.ChangePasswordAsync(user, model.OldPassword, model.NewPassword);

            if (!result.Succeeded) return BadRequest(result.Errors);

            return Ok(new { message = "Password changed successfully" });
        }

        // FIX 3: Corrected Token Generation Logic
        private (string token, DateTime expiration) GenerateJwtToken(ApplicationUser user, bool rememberMe)
        {
            var securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
            var credentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Email!),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.NameIdentifier, user.Id),
                new Claim(ClaimTypes.Name, user.FullName),
                new Claim(ClaimTypes.Email, user.Email!)
            };

            // Calculate Expiration: 7 Days if RememberMe is true, else 1 Hour
            var expiration = DateTime.UtcNow.Add(rememberMe ? TimeSpan.FromDays(7) : TimeSpan.FromHours(1));

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