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
        public string Email { get; set; } = string.Empty;

        public string MobileNumber { get; set; } = string.Empty;

        public string Address { get; set; } = string.Empty;

        public DateTime? DateOfBirth { get; set; }

        // Foreign Keys
        public int? DepartmentId { get; set; }
        [ForeignKey("DepartmentId")]
        public Department? Department { get; set; }

        public int? DesignationId { get; set; }
        [ForeignKey("DesignationId")]
        public Designation? Designation { get; set; }

        // --- ADDED POST RELATION ---
        public int? PostId { get; set; }
        [ForeignKey("PostId")]
        public Post? Post { get; set; }
    }
}