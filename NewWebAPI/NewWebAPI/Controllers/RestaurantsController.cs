using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using NewWebAPI.Queries;
using NewWebAPI.Factories;

using System.Data.Entity;
using System.Web.Http.Routing;
using NewWebAPI.Filters;

namespace NewWebAPI.Controllers
{
    public class RestaurantsController : BaseApiController
    {

        public RestaurantsController(IDbContext db) : base(db)
        {

        }

        private const int PAGE_SIZE = 2;

        
        public object Get(bool includeReviews = true, int page = 1)
        {
            IQueryable<Restaurant> query;

            if (includeReviews)
            {
                query = Repository.GetAllRestaurantsWithReviewes();
            }
            else
            {
                query = Repository.GetAllRestaurants();
            }

            var baseQuery = query.OrderBy(r => r.Name);
            var totalCount = baseQuery.Count();
            var totalPages = (int)Math.Ceiling((double) totalCount/PAGE_SIZE);

            var helper = new UrlHelper(Request);

            var prevUrl = page > 1 ? helper.Link("restaurants", new { includeReviews = includeReviews, page = page - 1 }) : "";

            var nextUrl = page < totalPages ? helper.Link("restaurants", new { includeReviews = includeReviews, page = page + 1 }) : "";
            

            var results = baseQuery
                .Skip(PAGE_SIZE*(page - 1))
                .Take(PAGE_SIZE)
                .ToList()
                .Select(r => ModelFactory.Create(r));

            return new
                {
                    TotalCount = totalCount,
                    TotalPages = totalPages,
                    PrevPageUrl = prevUrl.ToLower(),
                    NextPageUrl = nextUrl.ToLower(),
                    Results = results,
                };
        }

        public RestaurantModel Get(int restaurantid)
        {
            var result = ModelFactory.Create(Repository.GetRestaurant(restaurantid));
            return result;
        }

        /*
        public IEnumerable<RestaurantModel> Get(bool includeReviews = true)
        {
            IQueryable<Restaurant> query;

            if (includeReviews)
            {
                query = _db.GetAllRestaurantsWithReviewes();
            }
            else
            {
                query = _db.GetAllRestaurants();

            }
            var results = query.OrderBy(r => r.Name)
                               .Take(2)
                               .ToList()
                               .Select(r => _modelFactory.Create(r));
            return results;
        }
        public RestaurantModel Get(int id)
        {
            var result = _modelFactory.Create(_db.GetRestaurant(id));
            return result;
        }        
        */





        //public IEnumerable<RestuarantModel> Get()
        //{
        //    var results = _db.GetAllRestaurantsWithReviewes()
        //              .OrderBy(r => r.Name)
        //              .Take(2)
        //              .ToList()
        //              .Select(r => _modelFactory.Create(r));

        //    return results;
        //}


        /*
        public IEnumerable<RestaurantModel> Get()
        {
            DataTable dt = new DataTable("restaurants");
            DataSet ds = new DataSet("res_rv");

            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["RCDB"].ConnectionString))
            {
                using (var command = new SqlCommand("select * from Restaurants a; select * from Reviews", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.CommandTimeout = 0;
                    connection.Open();
                    using (var da = new SqlDataAdapter(command))
                    {
                        da.Fill(ds);
                    }
                }
            }

            var result = ds.Tables[0]
                .AsEnumerable()
                .AsQueryable()
                .Select(r => _modelFactory.Create(r,
                    ds.Tables[1]
                    .AsEnumerable()
                    .AsQueryable()
                    .Where(rr => (int)rr["RestaurantID"] == (int)r["ID"])
                    ));

            //var result = dt.AsEnumerable().AsQueryable().Select(r => _modelFactory.Create(r));
            //return result.Where(r => r.Name.ToLower().Contains("Ta".ToLower()));//.ToList();

            return result;
        }
        */







        //public IEnumerable<RestuarantModel> Get()
        //{
        //    return _db.GetAllRestaurantsWithReviewes()
        //              .OrderBy(r => r.Name)
        //              .Take(2)
        //              .Select(r => new RestuarantModel()
        //                  {
        //                      ID = r.ID,
        //                      Name = r.Name,
        //                      Created = r.AddDate,
        //                      Address = r.Address,
        //                      ImgUrl = "../../Content/images/restaurant.jpg",
        //                      Reviews = r.Reviews.Select(rr => new ReviewModel()
        //                          {
        //                              ID = rr.ID,
        //                              Body = rr.Body,
        //                              Rating = rr.Rating,
        //                              DiningDate = rr.DiningDate,
        //                              Created = rr.Created
        //                          })
        //                  });
        //}



        //public IEnumerable<object> Get()
        //{
        //    return _db.GetAllRestaurantsWithReviewes()
        //              .OrderBy(r => r.Name)
        //              //.Take(2)
        //              .Select(r => new
        //              {
        //                  ID = r.ID,
        //                  Name = r.Name,
        //                  Created = r.AddDate,
        //                  Address = r.Address,
        //                  ImgUrl = "../../Content/images/restaurant.jpg",
        //                  Reviews = r.Reviews
        //              });
        //}



        //public IEnumerable<Restaurant> Get()
        //{
        //    return _db.GetAllRestaurantsWithReviewes()
        //              .OrderBy(r => r.Name)
        //              .Take(2);
        //}


        //public IEnumerable<Restaurant> Get()
        //{
        //    return _db.Restaurants
        //       .OrderBy(r => r.Name)
        //       .Take(4);
        //}



        // private IDbConnection _connection;

        //public RestaurantsController()
        //{
        //    _connection = new SqlConnection(ConfigurationManager.ConnectionStrings["RCDB"].ConnectionString);
        //}

        //public RestaurantsController(string connectionString)
        //{
        //    _connection = new SqlConnection(connectionString);
        //}

        /*
        public IEnumerable<Restaurant> Get()
        {
            DataTable dt = new DataTable("restaurants");

            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["RCDB"].ConnectionString))
            //using(_connection)
            {
                using (var command = new SqlCommand("select * from Restaurants a", connection))
                {
                    command.CommandType = CommandType.Text;
                    command.CommandTimeout = 0;
                    connection.Open();
                    using (var da = new SqlDataAdapter(command))
                    {
                        da.Fill(dt);
                    }
                }
            }

            return dt.AsEnumerable().AsQueryable()
                     .Select(r => new Restaurant
                         {
                             ID = (int)r["ID"],
                             Name = r["Name"].ToString(),
                             Address = new Address()
                             {
                                 City = r["City"].ToString(),
                                 State = r["State"].ToString(),
                                 Country = r["Country"].ToString(),
                             },
                             AddDate = (DateTime)r["AddDate"]
                         })
                     .OrderBy(r => r.Name)
                     .Take(2);
    */


        /*
        var db = new RCDB();

        var results = db.Restaurants
                       .OrderBy(r => r.Name)
                       .Take(5);
                       .ToList();
            */
        // }
    }
}
