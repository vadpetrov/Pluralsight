using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class ProductV2Model: ProductModel
    {
        public int Version { get; set; }
    }
}