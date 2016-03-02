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
    public class RestaurantModelFactory
    {
        ReviewModelFactory _reviewModelFactory;
        AddressModelFactory _addressModelFactory;
        UrlHelper _urlHelper;

        public RestaurantModelFactory(HttpRequestMessage request)
        {
            _reviewModelFactory = new ReviewModelFactory(request);
            _addressModelFactory = new AddressModelFactory();
            _urlHelper = new UrlHelper(request);
        }

        public RestaurantModel Create(Restaurant restaurant)
        {
            return new RestaurantModel()
                {
                    //Url = RestaurantUrl(restaurant),
                    ID = restaurant.ID,
                    Name = restaurant.Name,
                    Created = restaurant.AddDate,
                    Address = restaurant.Address,
                    ImgUrl = "../../Content/images/restaurant.jpg",
                    Reviews = restaurant.Reviews.Select(rr => _reviewModelFactory.Create(rr))
                };
        }

        public RestaurantModel Create(DataRow restaurant)
        {
            return new RestaurantModel()
                {
                    //Url = RestaurantUrl(restaurant),
                    ID = (int)restaurant["ID"],
                    Name = restaurant["Name"].ToString(),
                    Created = (DateTime)restaurant["AddDate"],

                    Address = _addressModelFactory.Create(
                        restaurant["City"].ToString(), restaurant["state"].ToString(),
                        restaurant["country"].ToString(), restaurant["street"].ToString()),
                    ImgUrl = "../../Content/images/restaurant1.jpg",
                    Reviews = new List<ReviewModel>()
                };
        }
        public RestaurantModel Create(DataRow restaurant, IQueryable<DataRow> reviews)
        {
            return new RestaurantModel()
                {
                    //Url = RestaurantUrl(restaurant),
                    ID = (int)restaurant["ID"],
                    Name = restaurant["Name"].ToString(),
                    Created = (DateTime)restaurant["AddDate"],

                    Address = _addressModelFactory.Create(
                        restaurant["City"].ToString(), restaurant["state"].ToString(),
                        restaurant["country"].ToString(), restaurant["street"].ToString()),
                    ImgUrl = "../../Content/images/restaurant1.jpg",
                    Reviews = reviews.Select(rr => _reviewModelFactory.Create(rr))
                };
        }

        private string RestaurantUrl(Restaurant restaurant)
        {
            return _urlHelper.Link("Restaurants", new { restaurantid = restaurant.ID });
        }
        private string RestaurantUrl(DataRow restaurant)
        {
            return _urlHelper.Link("Restaurant", new { restaurantid = (int)restaurant["ID"] });
        }
    }
}