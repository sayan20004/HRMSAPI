using System.ComponentModel.DataAnnotations;

namespace HRMSAPI.Models
{
    public class Post
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public string Name { get; set; } = string.Empty;
    }
}