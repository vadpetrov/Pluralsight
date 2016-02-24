using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class OrderModel
    {
        public string Url { get; set; }
        public int OrderID { get; set; }
        public DateTime OrderDate { get; set; }
        public int ClientID { get; set; }
        public int RestaurantID { get; set; }
        public IEnumerable<OrderItemModel> Items { get; set; }
        public RestaurantModel Restaurant { get; set; }
        public ClientModel Client { get; set; }
    }
}