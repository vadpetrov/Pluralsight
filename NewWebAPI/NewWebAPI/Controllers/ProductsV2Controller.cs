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
    public class ProductsV2Controller : BaseApiController
    {
        public ProductsV2Controller(IDbContext db)
            : base(db)
        {
            
        }
        [ActionName("DefaultAction")]
        public IEnumerable<ProductV2Model> Get()
        {
            var results = Repository.GetProducts()
                                    .OrderBy(p => p.Name)
                                    .ToList()
                                    .Select(p => ModelFactory.Create2(p));
            return results;
        }
        [ActionName("DefaultAction")]
        public HttpResponseMessage Get(int id)
        {
            var results = Repository.GetProduct(id);
            if (results == null)
            {
                return Request.CreateResponse(HttpStatusCode.NotFound);
            }
            var product = ModelFactory.Create2(results);

            return Request.CreateResponse(HttpStatusCode.OK, product);
        }

        
        public HttpResponseMessage Post(int id, [FromBody] ProductV2Model model)
        {
            try
            {
                var entity = ModelFactory.Parse2(model);
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

                return Request.CreateResponse(HttpStatusCode.Created, ModelFactory.Create2(product));
            }
            catch (Exception ex)
            {
                //return Request.CreateResponse(HttpStatusCode.BadRequest);
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest, ex);
            }
        }
        
        public HttpResponseMessage Create([FromBody]ProductV2Model model)
        {
            try
            {
                var entity = ModelFactory.Parse2(model);
                if (entity == null)
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                                       "Could not read Product entry in body.");

                if(Repository.GetProducts().Any(p=>p.Name.ToLower() == entity.Name.ToLower()))
                    return Request.CreateErrorResponse(HttpStatusCode.BadRequest,
                                                       "Product already exists");

                entity = Repository.Add(entity);
                Repository.SaveChanges();

                return Request.CreateResponse(HttpStatusCode.Created, ModelFactory.Create2(entity));
            }
            catch(Exception ex)
            {
                //return Request.CreateResponse(HttpStatusCode.BadRequest);
                return Request.CreateErrorResponse(HttpStatusCode.BadRequest,ex);
            }
        }
    }
}
