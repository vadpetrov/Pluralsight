using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class Product
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int ID { get; set; }

        public string Name { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }

        [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
        public DateTime AddDate { get; set; }
    }
}