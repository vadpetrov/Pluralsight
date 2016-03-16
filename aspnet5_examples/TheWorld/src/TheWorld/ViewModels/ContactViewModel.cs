using System.ComponentModel.DataAnnotations;

namespace TheWorld.ViewModels
{
    public class ContactViewModel
    {
        [Required]
        [StringLength(255, MinimumLength = 5)]
        [Display(Name = "Name")]
        public string Name { get; set; }

        [Required]
        [EmailAddress]
        [Display(Name="Email Address")]
        public string Email { get; set; }

        [Required]
        [StringLength(1024, MinimumLength = 5)]       
        [Display(Name = "Message")]
        public string Message { get; set; }
    }
}
