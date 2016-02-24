using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class RestaurantModel
    {
        public string Url { get; set; }
        public int ID { get; set; }
        public string Name { get; set; }
        public Address Address { get; set; }
        public DateTime  Created { get; set; }
        public string  ImgUrl { get; set; }
        public IEnumerable<ReviewModel>  Reviews { get; set; }
    }
}