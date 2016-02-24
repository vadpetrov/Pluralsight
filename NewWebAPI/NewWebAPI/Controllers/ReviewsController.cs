using NewWebAPI.Factories;
using NewWebAPI.Models;
using NewWebAPI.Queries;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public class ReviewsController : BaseApiController
    {
        public ReviewsController(IDbContext db):base (db)
        {
            
        }

        public IEnumerable<ReviewModel> Get(int restaurantid)
        {
            var results = Repository.GetReviewsForRestaurant(restaurantid)
                             .ToList()
                             .Select(r => ModelFactory.Create(r))
                             .OrderByDescending(r => r.DiningDate);
            return results;
        }

        public ReviewModel Get(int restaurantid, int id)
        {
            var results = Repository.GetReview(id);
            
            if (results.Restaurant.ID == restaurantid)
            {
                return ModelFactory.Create(results);
            }
            return null;
        }
    }
}
