using NewWebAPI.Models;
using NewWebAPI.Queries;
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
        private IDbContext _repo;

        public EFModelFactory(HttpRequestMessage request, IDbContext repo)
        {
            _urlHelper = new UrlHelper(request);
            _repo = repo;
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
                    Url = ControllerUrl(item),
                    OrderUrl = ControllerUrl(item.Order),
                    OrderID = item.OrderID,
                    ItemID = item.ItemID,
                    Quantity = item.Quantity,
                    ClientID = item.Order.Client.ID,
                    Product = Create(item.Product)
                };
        }

        public ProductModel Create(Product product)
        {
            return new ProductModel()
                {
                    Url = ControllerUrl(product),
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

        
        public Product Parse(ProductModel model)
        {
            try
            {
                var entry = new Product();

                if (model.ID != default(int))
                {
                    entry.ID = model.ID;
                }

                if (!string.IsNullOrEmpty(model.Name))
                {
                    entry.Name = model.Name;
                }

                if (model.Price != default(decimal))
                {
                    entry.Price = model.Price;
                }
                entry.Description = model.Description;
                return entry;
            }
            catch
            {
                return null;
            }
        }
        public OrderItem Parse(OrderItemModel model)
        {
            try
            {
                var entry = new OrderItem();

                //full object parsing
                if (!string.IsNullOrWhiteSpace(model.OrderUrl))
                {
                    if (model.ItemID != default(int))
                    {
                        entry.ItemID = model.ItemID;
                    }

                    var uri = new Uri(model.OrderUrl);
                    var orderId = int.Parse(uri.Segments.Last());
                    var order = _repo.GetOrder(model.ClientID, orderId);
                    var product = _repo.GetProduct(entry.ItemID);
                    entry.OrderID = orderId;
                    entry.Order = order;
                    entry.Product = product;
                }
                //partial parsing
                if (model.Quantity != default(int))
                {
                    entry.Quantity = model.Quantity;
                }
                return entry;
            }
            catch
            {
                return null;
            }
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
        private string ControllerUrl(Product product)
        {
            return _urlHelper.Link("Products", new { id = product.ID });
        }
        private string ControllerUrl(OrderItem item)
        {
            return _urlHelper.Link("OrdersItems", new { orderid = item.Order.ID, id = item.ItemID });
        }



        public OrderSummaryModel CreateSummary(Order order)
        {
            return new OrderSummaryModel()
                {
                    OrderID = order.ID,
                    OrderDate = order.OrderDate,
                    Products = order.Items.Select(i=>CreateSummary(i)),
                    TotalAmount = order.Items.Sum(i=>i.Product.Price * i.Quantity)
                };
        }

        public KeyValuePair<string, decimal> CreateSummary(OrderItem item)
        {
            return new KeyValuePair<string, decimal>(item.Product.Name, item.Product.Price * item.Quantity);
        }
    }
}