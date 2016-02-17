using OdeToFood.Infrastructure;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OdeToFood.Controllers
{
    //[Authorize]
    //[Log]
    public class CuisineController : Controller
    {
        [HttpGet]
        //[Authorize(Roles="Admin")]
        public ActionResult Search(string name = "*")
        {
            //if (name == "*")
            //{
            //    return Json(new {cuisineName= name},JsonRequestBehavior.AllowGet);
            //    //return File(Server.MapPath("~/Content/Site.css"),"text/css");
            //    //return RedirectToRoute("Cuisine", new {name = "german"});
            //    //return RedirectToAction("Search", "Cuisine", new {name = "belgium"});
            //}
            //return Content(Server.HtmlEncode(name));

            //name = Server.HtmlEncode(name);
            //var name1 = RouteData.Values["name"];
            //return Content("Cuisine Search Controller - " + name);
            //return RedirectPermanent("http://www.microsoft.com");
            //return RedirectToAction("Index", "Home");


            //throw new Exception("oops!");

            name = Server.HtmlEncode(name);
            return Content(name);
        }
    }
}
