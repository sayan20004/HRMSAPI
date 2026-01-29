using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HRMSAPI.Models
{
    public class Employee
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string FullName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        public string MobileNumber { get; set; } = string.Empty;

        public string Address { get; set; } = string.Empty;

        public DateTime? DateOfBirth { get; set; }

        public DateTime JoinDate { get; set; } = DateTime.UtcNow;

        [Required]
        public int DepartmentId { get; set; }
        
        [ForeignKey("DepartmentId")]
        public Department? Department { get; set; }

        [Required]
        public int DesignationId { get; set; }

        [ForeignKey("DesignationId")]
        public Designation? Designation { get; set; }

        public bool IsActive { get; set; } = true;
    }
}