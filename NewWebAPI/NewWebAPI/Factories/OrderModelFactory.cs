using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http.Routing;

namespace NewWebAPI.Factories
{
    public class OrderModelFactory
    {
        RestaurantModelFactory _restaurantModelFactory;
        ClientModelFactory _clientModelFactory;
        UrlHelper _urlHelper;

        public OrderModelFactory(HttpRequestMessage request)
        {
             _urlHelper = new UrlHelper(request);
             _restaurantModelFactory = new RestaurantModelFactory(request);
            _clientModelFactory = new ClientModelFactory();
        }
        
        public OrderModel Create(Order order)
        {
            return new OrderModel()
                {
                    Url = OrderUrl(order),
                    OrderID = order.ID,
                    OrderDate = order.OrderDate,
                    RestaurantID = order.RestaurantID,
                    ClientID = order.ClientID,
                    Restaurant = _restaurantModelFactory.Create(order.Restaurant),
                    Client = _clientModelFactory.Create(order.Client)
                };
        }

        private string OrderUrl(Order order)
        {
            return _urlHelper.Link("Orders", new { orderid = order.ID });
        }

    }
}