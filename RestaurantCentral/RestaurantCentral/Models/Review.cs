using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace RestaurantCentral.Models
{
    public class Review: IValidatableObject
    {
        public virtual int ID { get; set; }
        public virtual int RestaurantID { get; set; }

        [Range(1,10)]
        public virtual int Rating { get; set; }

        [Required]
        //[Required(ErrorMessage = "Reuired field")]
        //[Required(ErrorMessageResourceType = typeof(Views.Home.HomeResources), ErrorMessageResourceName = "ReviewBodyErrorMessage")]
        [DataType(DataType.MultilineText)]
        [AllowHtml]
        public virtual string Body { get; set; }


        [DisplayName("Dining Date")]
        [DisplayFormat(DataFormatString ="{0:d}",ApplyFormatInEditMode = true)]
        [DataType(DataType.Date)]
        public virtual DateTime DiningDate { get; set; }
        
        public virtual DateTime? Created { get; set; }

        public virtual Restaurant Restaurant { get; set; }

        public IEnumerable<ValidationResult> Validate(ValidationContext validationContext)
        {
            var field = new[] {"DiningDate"};

            if (DiningDate > DateTime.Now)
            {
                yield return  new ValidationResult("Dining date can not be in the future.",field);
            }
            if (DiningDate < DateTime.Now.AddYears(-2))
            {
                yield return new ValidationResult("Dining date can not be to far in the past.",field);
            }
        }
    }

}