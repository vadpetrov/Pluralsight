using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace RestaurantCentral.Queries
{
    public static class RestaurantQueries
    {
        public static Restaurant FindById(this IQueryable<Restaurant> restaurants , int id)
        {
            return restaurants.SingleOrDefault(r => r.ID == id);
        }
        public static IQueryable<Restaurant> FindByState(this IQueryable<Restaurant> restaurants, string state)
        {
            return restaurants
                .Where(r => r.Address.State == state || state == null)
                .OrderBy(r => r.Name);
        }

    }
}