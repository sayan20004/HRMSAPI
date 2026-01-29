using System.ComponentModel.DataAnnotations;

namespace HRMSAPI.Models
{
    public class Designation
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;

        public int Level { get; set; }
    }
}