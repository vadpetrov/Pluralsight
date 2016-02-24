using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Factories
{
    public class AddressModelFactory
    {
        public Address Create(string city, string state, string country, string street)
        {
            return new Address()
            {
                City = city,
                State = state,
                Country = country,
                Street = street
            };
        }
    }
}