using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public class ClientController : BaseApiController
    {
        public ClientController(IDbContext db):base(db)
        {
            
        }

        public HttpResponseMessage Get()
        {
            return null;
        }
    }
}
