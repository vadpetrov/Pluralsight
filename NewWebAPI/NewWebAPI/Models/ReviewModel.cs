using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NewWebAPI.Models
{
    public class ReviewModel
    {
        public string Url { get; set; }
        public int ID { get; set; }
        public int RestaurantID { get; set; }
        public int Rating { get; set; }
        public DateTime DiningDate { get; set; }
        public string Body { get; set; }
        public DateTime Created { get; set; }
    }
}
