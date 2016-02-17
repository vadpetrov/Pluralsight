using OdeToFood.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OdeToFood.Controllers
{
    public class HomeController : Controller
    {
        public ViewResult Index()
        {
            //ViewBag.Message = "default data";


            ViewBag.Message = string.Format("{0}::{1}  {2}",
                RouteData.Values["controller"],
                RouteData.Values["action"],
                RouteData.Values["id"]);

            var model = new RestaurantReview()
                {
                    Name = "Tatyana",
                    Rating = 7
                };

            return View(model);
        }

        public ActionResult About()
        {
            ViewBag.Location = "New York, USA";

            return View();
        }
    }
}
