using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace NewWebAPI.Models
{
    public class Restaurant
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public Address Address { get; set; }
        public DateTime AddDate { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }


        [NotMapped]
        public virtual string ImageUrl { get; set; }

        public Restaurant()
        {
            Address = new Address();
            if (Reviews == null) Reviews = new List<Review>();
            ImageUrl = "../../Content/images/restaurant.jpg";
        }
    }
}