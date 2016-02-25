using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
     //[Table("OrderItems")]
    public class OrderItem
    {
        [Key]
        [Column(Order=0)]
        public int OrderID { get; set; }
    
        [Key]
        [Column(Order=1)]
        public int ItemID { get; set; }

        public virtual Product Product { get; set; }
        public virtual Order Order { get; set; }
    }
}