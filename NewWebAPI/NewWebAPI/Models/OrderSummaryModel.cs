using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class OrderSummaryModel
    {
        public int OrderID { get; set; }
        public DateTime OrderDate { get; set; }
        public IEnumerable<KeyValuePair<string,decimal>> Products { get; set; }
        public decimal TotalAmount { get; set; }
    }
}