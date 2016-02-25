using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class OrderItemModel
    {
        public string Url { get; set; }
        public string OrderUrl { get; set; }
        public int OrderID { get; set; }
        public int ItemID { get; set; }
        public int ClientID { get; set; }
        public ProductModel Product { get; set; }

    }
}