using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace NewWebAPI.Models
{
    public class Review
    {
        public int ID { get; set; }
        public int RestaurantID { get; set; }
        public int Rating { get; set; }
        public string Body { get; set; }
        public DateTime DiningDate { get; set; }
        public DateTime Created { get; set; }
        public virtual Restaurant Restaurant { get; set; }

        public Review()
        {
            //if(Restaurant == null) Restaurant = new Restaurant();
        }
    }
}