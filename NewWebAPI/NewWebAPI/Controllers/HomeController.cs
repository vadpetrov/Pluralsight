using NewWebAPI.Models;
using NewWebAPI.Queries;
using NewWebAPI.Factories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Net.Http;

namespace NewWebAPI.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var repo = new RCDB();
            //var mf = new EFModelFactory(repo);

            var results = repo.GetAllRestaurantsWithReviewes()
                              .OrderBy(r => r.Name)
                              .ToList()
                              .Select(r => new Restaurant()
                                  {
                                      ID = r.ID,
                                      Name = r.Name,
                                      Address = r.Address,
                                      Reviews = r.Reviews.OrderByDescending(rv=>rv.DiningDate).ToList()
                                  }
                              );


                            //.OrderByDescending(r => r.Reviews.OrderByDescending(i => i.DiningDate))
            
                              //.ThenBy(r => r.Reviews.OrderByDescending(i => i.DiningDate))
                              //.Select(r => mf.Create(r));

            return View(results);
        }
    }
}
