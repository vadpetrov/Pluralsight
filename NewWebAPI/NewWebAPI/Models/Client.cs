using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class Client
    {
        public int ID { get; set; }
        public string UserName { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
    }
}