using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace OdeToFood.Models
{
    public class RestaurantReview
    {
        public string  Name { get; set; }
        public int Rating { get; set; }
    }

    public class RestaurantReviews
    {
        public int ID { get; set; }
        public Restaurant Restaurant { get; set; }
        public int Rating { get; set; }
        public string Body { get; set; }
        public DateTime Created { get; set; }
    }
}