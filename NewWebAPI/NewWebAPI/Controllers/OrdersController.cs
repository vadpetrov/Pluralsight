using NewWebAPI.Services;
using NewWebAPI.Models;
using NewWebAPI.Queries;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public class OrdersController : BaseApiController
    {
        private IRCIdentityService _identityService;

        public OrdersController(IDbContext db, IRCIdentityService identityService)
            : base(db)
        {
            _identityService = identityService;
        }

        public IEnumerable<OrderModel> Get(DateTime? orderDate = null)
        {
            //var username = Thread.CurrentPrincipal.Identity.Name;
            var username = _identityService.CurrentUserName;
            IQueryable<Order> query;
            
            if (orderDate == null)
            {
                query = Repository.GetOrders(username);
            }
            else
            {
                query = Repository.GetOrders(username,(DateTime)orderDate);
            }
            var results = query
                .OrderByDescending(o => o.OrderDate)
                .Take(2)
                .ToList()
                .Select(o => ModelFactory.Create(o));
            return results;
        }

        public OrderModel Get(int orderid)
        {
            var userid = _identityService.CurrentUserID;
            var results = Repository.GetOrder(orderid);

            if (results.Client.ID == userid)
            {
                return ModelFactory.Create(results);
            }
            return new OrderModel();
        }
    }
}
