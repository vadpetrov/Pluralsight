using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace RestaurantCentral.Models
{
    public class Restaurant
    {
        public virtual int ID { get; set; }
        public virtual string Name { get; set; }
        public virtual Address Address { get; set; }
        public virtual DateTime AddDate { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }

        [NotMapped]
        public virtual string ImageUrl { get; set; }

        public Restaurant()
        {
            ImageUrl = "../../Content/images/restaurant.jpg";
        }
    }
}