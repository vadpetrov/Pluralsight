using NewWebAPI.Models;
using NewWebAPI.Queries;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public class ProductsController : BaseApiController
    {
        public ProductsController(IDbContext db)
            : base(db)
        {
            
        }
        [ActionName("DefaultAction")]
        public IEnumerable<ProductModel> Get()
        {
            var results = Repository.GetProducts()
                                    .OrderBy(p => p.Name)
                                    .ToList()
                                    .Select(p => ModelFactory.Create(p));
            return results;
        }
        /// <summary>
        /// Get Product by id
        /// </summary>
        /// <param name="id">ProductID input param</param>
        /// <returns></returns>
        [ActionName("DefaultAction")]
        public HttpResponseMessage Get(int id)
        {
            var results = Repository.GetProduct(id);
            if (results == null)
            {
                return Request.CreateResponse(HttpStatusCode.NotFound);
            }
            var product = ModelFactory.Create(results);

            return Request.CreateResponse(HttpStatusCode.OK, product);
        }

        #region Multiple gets
        [HttpGet]
        [ActionName("Investors")]
        public object Investors(int id)
        {
            return "Investors " + id.ToString();
        }

        [HttpGet]
        [ActionName("Investors")]
        public object Investors(int id, int entityid)
        {
            return "Investors "  + id.ToString() + " - " + entityid.ToString();
        }
        //http://blog.appliedis.com/2013/03/25/web-api-mixing-traditional-verb-based-routing/


        [HttpGet]
        [ActionName("Deals")]
        public object Deals(int id)
        {
            return "Deals " + id.ToString();
        }

        [HttpGet]
        [ActionName("Deals")]
        public object Deals(int id, int entityid)
        {
            return "Deals " + id.ToString() + " - " + entityid.ToString();
        }
        #endregion

        //public object Create([FromBody]ProductModel model)

        public HttpResponseMessage Post(int id, [FromBody] ProductModel model)
        {
            try
            {
                var entity = ModelFactory.Parse(model);
                if (entity == null)
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                                       "Could not read Product entry in body.");

                var product = Repository.GetProduct(id);
                if (product == null)
                    return Request.CreateResponse(HttpStatusCode.NotFound);

                product.Description = entity.Description;
                product.Name = entity.Name;
                product.Price = entity.Price;

                product = Repository.Attach(product);
                Repository.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.Created, ModelFactory.Create(product));
            }
            catch (Exception ex)
            {
                //return Request.CreateResponse(HttpStatusCode.BadRequest);
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }
        }
        
        public HttpResponseMessage Create([FromBody]ProductModel model)
        {
            try
            {
                var entity = ModelFactory.Parse(model);
                if (entity == null)
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                                       "Could not read Product entry in body.");

                if(Repository.GetProducts().Any(p=>p.Name.ToLower() == entity.Name.ToLower()))
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                                       "Product already exists");

                entity = Repository.Add(entity);
                Repository.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.Created, ModelFactory.Create(entity));
            }
            catch(Exception ex)
            {
                //return Request.CreateResponse(HttpStatusCode.BadRequest);
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest,ex);
            }
        }
    }
}
