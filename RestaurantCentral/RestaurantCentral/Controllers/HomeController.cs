using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using RestaurantCentral.Queries;
using RestaurantCentral.Models;
using System.Threading;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace RestaurantCentral.Controllers
{
    //[Authorize(Users="poonam,tim,vp")]//authorize by username
    //[Authorize(Roles="users")]
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
            DataTable dt = new DataTable("restaurants");

            using (var connection = new SqlConnection(ConfigurationManager.ConnectionStrings["RCDB"].ConnectionString))
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
                    //IEnumerable<IDataRecord> idr = GetData(command);
                    //var reader = command. .ExecuteReader();//.Cast<IDataRecord>();
                    //reader.to
                    //MemoryStream ms = new MemoryStream();
                    //foreach (IDataRecord record in idr)
                    //{
                    //    ms.Write(record,);
                    //}
                }
            }

            //var dt = new DataTable("deals");
            return View(dt);
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
