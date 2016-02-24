using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class Order
    {
        public int ID { get; set; }
        public DateTime OrderDate { get; set; }
        public int RestaurantID { get; set; }
        public int ClientID { get; set; }
        public virtual Restaurant Restaurant { get; set; }
        public virtual Client Client { get; set; }
        public virtual ICollection<OrderItem> Items { get; set; }

        public Order()
        {
            if (Items == null) Items = new List<OrderItem>();
        }
    }
}