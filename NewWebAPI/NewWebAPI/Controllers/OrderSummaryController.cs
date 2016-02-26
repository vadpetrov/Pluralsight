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
    public class OrderSummaryController : BaseApiController
    {
        private IRCIdentityService _identityService;

        public OrderSummaryController(IDbContext db, IRCIdentityService identityService)
            : base(db)
        {
            _identityService = identityService;
        }

        public object Get(int orderId)
        {
            try
            {
                var order = Repository.GetOrder(_identityService.CurrentUserID, orderId);
                if (order == null)
                    return Request.CreateErrorResponse(HttpStatusCode.NotFound, "Order not found.");

                return ModelFactory.CreateSummary(order);
            }
            catch (Exception ex)
            {
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }
        }
    }
}
