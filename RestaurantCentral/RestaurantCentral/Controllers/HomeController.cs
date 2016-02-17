using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using RestaurantCentral.Queries;
using RestaurantCentral.Models;
using System.Threading;

namespace RestaurantCentral.Controllers
{
    public class HomeController : Controller
    {
        RCDB _db = new RCDB();

        public ActionResult Index()
        {
            ViewBag.Message = "Welcome Restaurant Central.";

            return View();
        }

        public ActionResult About()
        {
            return View();
        }

        public PartialViewResult LatestReview()
        {
            Thread.Sleep(200);
            var review = _db.Reviews.FindTheLatest(1).Single();
            return PartialView("_Review", review);
        }

        public PartialViewResult Search(string q)
        {
            var restaurants = _db.Restaurants
                                 .Where(r => r.Name.Contains(q) ||
                                             string.IsNullOrEmpty(q))
                                 .OrderBy(r => r.Name)
                                 .Take(10);

            return PartialView("_RestaurantSearchResults", restaurants);
        }

        public ActionResult QuickSearch(string term)
        {
            var restaurants = _db.Restaurants
                                 .Where(r => r.Name.Contains(term))
                                 .Take(10)
                                 .Select(r => new { label = r.Name });
            return Json(restaurants, JsonRequestBehavior.AllowGet);
        }

        public ActionResult JsonSearch(string q)
        {
            var restaurants = _db.Restaurants
                                 .Where(r => r.Name.Contains(q) ||
                                             String.IsNullOrEmpty(q))
                                 .Take(10)
                                 .Select(r => new
                                 {
                                     r.Name,
                                     r.Address.City,
                                     r.Address.Country
                                 });
            return Json(restaurants, JsonRequestBehavior.AllowGet);
        }


    }
}
