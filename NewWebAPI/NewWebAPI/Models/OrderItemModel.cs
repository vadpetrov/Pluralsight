using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class OrderItemModel
    {
        public int OrderID { get; set; }
        public int ItemID { get; set; }
        public ProductModel Product { get; set; }
    }
}