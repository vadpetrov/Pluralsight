using NewWebAPI.Models;
using NewWebAPI.Queries;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Cors;

namespace NewWebAPI.Controllers
{
    [RoutePrefix("api/stats")]
    //p1 - domains : "http://foo.com", p2 - headers : "X-OURAPP" , p3  - methods : "GET,POST"
    //[EnableCors("*","*","GET")]
    public class StatsController : BaseApiController
    {
        public StatsController(IDbContext db): base(db)
        {
            
        }

        //[Route("api/stats")]
        [Route("")]
        //[EnableCors("*", "*", "GET")]
        //[DisableCors()]

        public IHttpActionResult Get()
        {
            var results = new
            {
                NumRestaurants = Repository.GetAllRestaurants().Count(),
                NumOrders = Repository.GetAllOrders().Count()
            };
            return Ok(results);
        }

        /*
        public HttpResponseMessage Get()
        {
            var results = new
                {
                    NumRestaurants = Repository.GetAllRestaurants().Count(),
                    NumOrders = Repository.GetAllOrders().Count()
                };
            return Request.CreateResponse(HttpStatusCode.OK, results);
        }
        */



        //Mehtod Level
        //[Route("api/stats/{id}")]

        //Controller level
        //[Route("{id}")]

        //Override prefix on controller level
        [Route("~/api/stat/{id:int}")]
        public IHttpActionResult Get(int id)
        {
            if (id == 1)
            {
                return Ok(new { NumRestaurants = Repository.GetAllRestaurants().Count() });
            }

            if (id == 2)
            {   
                return Ok(new { NumOrders = Repository.GetAllOrders().Count() });
            }

            return NotFound();
        }

        /*
        public HttpResponseMessage Get(int id)
        {
            if (id == 1)
            {
                return Request.CreateResponse(HttpStatusCode.OK,
                                              new {NumRestaurants = Repository.GetAllRestaurants().Count()});
            }

            if (id == 2)
            {
                return Request.CreateResponse(HttpStatusCode.OK,
                                              new {NumOrders = Repository.GetAllOrders().Count()});
            }

            return Request.CreateResponse(HttpStatusCode.NotFound);
        }
        */




        [Route("~/api/stat/{name:alpha}")]
        public IHttpActionResult Get(string name)
        {
            if (name == "restaurants")
            {
                return Ok(new { NumRestaurants = Repository.GetAllRestaurants().Count() });
            }

            if (name == "orders")
            {
                return Ok(new { NumOrders = Repository.GetAllOrders().Count() });
            }

            return NotFound();
        }

        /*
        public HttpResponseMessage Get(string name)
        {
            if (name == "restaurants")
            {
                return Request.CreateResponse(HttpStatusCode.OK,
                                              new { NumRestaurants = Repository.GetAllRestaurants().Count() });
            }

            if (name == "orders")
            {
                return Request.CreateResponse(HttpStatusCode.OK,
                                              new { NumOrders = Repository.GetAllOrders().Count() });
            }

            return Request.CreateResponse(HttpStatusCode.NotFound);
        }
        */


        //[Route("~/api/stats/orders")]
        [Route("orders")]
        public IHttpActionResult GetOrders()
        {
            return Ok(new {NumOrders = Repository.GetAllOrders().Count()});
        }

        [Route("restaurants")]
        public IHttpActionResult GetRestaurants()
        {
            return Ok(new { NumRestaurants = Repository.GetAllRestaurants().Count() });
        }
        
        /*
        //[Route("~/api/stats/orders")]
        [Route("orders")]          
        public HttpResponseMessage GetOrders()
        {
            return Request.CreateResponse(HttpStatusCode.OK,
                                          new {NumOrders = Repository.GetAllOrders().Count()});

        }
        [Route("restaurants")]
        public HttpResponseMessage GetRestaurants()
        {
            return Request.CreateResponse(HttpStatusCode.OK,
                                          new { NumRestaurants = Repository.GetAllRestaurants().Count() });

        }
        */
    }
}
