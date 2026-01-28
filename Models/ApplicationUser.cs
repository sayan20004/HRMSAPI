using Microsoft.AspNetCore.Identity;

namespace HRMSAPI.Models
{
    public class ApplicationUser : IdentityUser
    {
        public string FullName { get; set; } = string.Empty;
        public string? OTP { get; set; }
        public DateTime? OTPExpiration { get; set; }
    }
}