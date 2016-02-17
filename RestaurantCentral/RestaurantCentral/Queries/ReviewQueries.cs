using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace RestaurantCentral.Queries
{
    public static class ReviewQueries
    {
        public static IEnumerable<Review> FindTheLatest(this IQueryable<Review> reviews, int numberOfReviews)
        {
            return reviews.OrderByDescending(r => r.DiningDate)
                          .Take(numberOfReviews).ToList();
        }
        public static Review FindById(this IQueryable<Review> reviews, int id)
        {
            return reviews.Single(r => r.ID == id);
        }
    }
}