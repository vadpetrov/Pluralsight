using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http.Routing;

namespace NewWebAPI.Factories
{
    public class ReviewModelFactory
    {
        UrlHelper _urlHelper;

        public ReviewModelFactory(HttpRequestMessage request)
        {
             _urlHelper = new UrlHelper(request);
        }

        public ReviewModel Create(DataRow review)
        {
            return new ReviewModel()
            {
                Url = ReviewUrl(review),
                ID = (int)review["ID"],
                RestaurantID = (int)review["RestaurantID"],
                Body = review["Body"].ToString(),
                Rating = (int)review["Rating"],
                DiningDate = (DateTime)review["DiningDate"],
                Created = (DateTime)review["Created"]
            };
        }

        public ReviewModel Create(Review review)
        {
            return new ReviewModel()
            {
                Url = ReviewUrl(review),
                ID = review.ID,
                RestaurantID = review.RestaurantID,
                Body = review.Body,
                Rating = review.Rating,
                DiningDate = review.DiningDate,
                Created = review.Created
            };
        }

        private string ReviewUrl(Review review)
        {
            return _urlHelper.Link("Reviews", new
                {
                    restaurantid = review.Restaurant.ID,
                    id = review.ID
                });
        }
        private string ReviewUrl(DataRow review)
        {
            return _urlHelper.Link("Reviews", new
                {
                    restaurantid = (int) review["RestaurantID"],
                    id = (int) review["ID"]
                });
        }
    }
}