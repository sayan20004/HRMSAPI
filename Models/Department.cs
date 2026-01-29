using System.ComponentModel.DataAnnotations;

namespace HRMSAPI.Models
{
    public class Department
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public string? Code { get; set; }
    }
}