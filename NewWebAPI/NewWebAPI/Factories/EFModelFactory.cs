using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http.Routing;

namespace NewWebAPI.Factories
{
    public class EFModelFactory
    {
        UrlHelper _urlHelper;

        public EFModelFactory(HttpRequestMessage request)
        {
            _urlHelper = new UrlHelper(request);
        }

        public OrderModel Create(Order order)
        {
            return new OrderModel()
            {
                Url = ControllerUrl(order),
                OrderID = order.ID,
                OrderDate = order.OrderDate,
                RestaurantID = order.RestaurantID,
                ClientID = order.ClientID,
                Restaurant = Create(order.Restaurant),
                Client = Create(order.Client),
                Items = order.Items.Select(i=>Create(i))
            };
        }

        public RestaurantModel Create(Restaurant restaurant)
        {
            return new RestaurantModel()
            {
                Url = ControllerUrl(restaurant),
                ID = restaurant.ID,
                Name = restaurant.Name,
                Created = restaurant.AddDate,
                Address = restaurant.Address,
                ImgUrl = "../../Content/images/restaurant.jpg",
                Reviews = restaurant.Reviews.Select(rr => Create(rr))
            };
        }

        public ReviewModel Create(Review review)
        {
            return new ReviewModel()
            {
                Url = ControllerUrl(review),
                ID = review.ID,
                RestaurantID = review.RestaurantID,
                Body = review.Body,
                Rating = review.Rating,
                DiningDate = review.DiningDate,
                Created = review.Created
            };
        }

        public OrderItemModel Create(OrderItem item)
        {
            return new OrderItemModel()
                {
                    OrderID = item.OrderID,
                    ItemID = item.ItemID,
                    Product = Create(item.Product)
                };
        }

        public ProductModel Create(Product product)
        {
            return new ProductModel()
                {
                    ID = product.ID,
                    Name = product.Name,
                    Description = product.Description,
                    Price = product.Price
                };
        }

        public ClientModel Create(Client client)
        {
            return new ClientModel()
            {
                ID = client.ID,
                UserName = client.UserName,
                FirstName = client.FirstName,
                LastName = client.LastName
            };
        }

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

        private string ControllerUrl(Review review)
        {
            return _urlHelper.Link("Reviews", new
            {
                restaurantid = review.Restaurant.ID,
                id = review.ID
            });
        }
        private string ControllerUrl(Restaurant restaurant)
        {
            return _urlHelper.Link("Restaurants", new { restaurantid = restaurant.ID });
        }
        private string ControllerUrl(Order order)
        {
            return _urlHelper.Link("Orders", new { orderid = order.ID });
        }
    }
}