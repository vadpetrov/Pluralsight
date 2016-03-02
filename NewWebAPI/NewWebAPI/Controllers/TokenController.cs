using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public class TokenController : BaseApiController
    {
        public TokenController(IDbContext db) : base (db)
        {
            
        }

        public HttpResponseMessage Post([FromBody] TokenRequestModel model)
        {
            //var user = Repository.GetApiUsers()
            return null;
        }
    }
}
