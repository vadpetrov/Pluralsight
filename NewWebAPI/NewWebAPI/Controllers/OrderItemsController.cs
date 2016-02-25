using NewWebAPI.Models;
using NewWebAPI.Services;
using NewWebAPI.Queries;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public class OrderItemsController : BaseApiController
    {
        private IRCIdentityService _identityService;

        public OrderItemsController(IDbContext db, IRCIdentityService identityService)
            : base(db)
        {
            _identityService = identityService;
        }

        public IEnumerable<OrderItemModel> Get(int orderid)
        {
            var userid = _identityService.CurrentUserID;
            var results = Repository.GetOrderItems(userid, orderid)
                                    .OrderByDescending(oi => oi.Product.Name)
                                    .ToList()
                                    .Select(oi => ModelFactory.Create(oi));
            return results;
        }
        public HttpResponseMessage Get(int orderid, int id)
        {
            var userid = _identityService.CurrentUserID;
            var result = Repository.GetOrderItem(userid, orderid, id);

            if (result == null)
            {
                return Request.CreateResponse(HttpStatusCode.NotFound);
            }

            var orderItem = ModelFactory.Create(result);
            return Request.CreateResponse(HttpStatusCode.OK, orderItem);
        }

        public HttpResponseMessage Post(int orderid, [FromBody]OrderItemModel model)
        {
            try
            {
                var entity = ModelFactory.Parse(model);

                if (entity == null)
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                                       "Could not read OrderItem entry in body.");
                
                var order = Repository.GetOrder(_identityService.CurrentUserID, orderid);

                if (order == null)
                    return Request.CreateResponse(HttpStatusCode.NotFound);

                if (order.Items.Any(i => i.ItemID == entity.ItemID))
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                       "Duplicate items not allowed.");

                order.Items.Add(entity);

                if (Repository.SaveChanges() > 0)
                {
                    return Request.CreateResponse(HttpStatusCode.Created, ModelFactory.Create(entity));
                }
                else
                {
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                       "Could not save to the database.");
                }
                
            }
            catch (Exception ex)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);

            }
        }

        public HttpResponseMessage Delete(int orderid, int id)
        {
            try
            {
                var orderItem = Repository.GetOrderItem(_identityService.CurrentUserID, orderid, id);
                
                if (orderItem == null)
                {
                    return Request.CreateResponse(HttpStatusCode.NotFound);
                }
                
                Repository.Delete(orderItem);
                if (Repository.SaveChanges() > 0)
                {
                    return Request.CreateResponse(HttpStatusCode.OK);
                }
                else
                {
                    return Request.CreateResponse(HttpStatusCode.BadRequest);
                }
            }
            catch (Exception ex)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }
        }
    }
}
