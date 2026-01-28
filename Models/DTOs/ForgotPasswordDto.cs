using System.ComponentModel.DataAnnotations;

namespace HRMSAPI.Models.DTOs
{
    public class ForgotPasswordDto
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
    }

    
}