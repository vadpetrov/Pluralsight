using OdeToFood.Models;
using OdeToFood.Queries;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace OdeToFood.Controllers
{
    public class ReviewsController : Controller
    {
        //FoodDb _db = new FoodDb();
        OdeToFoodDB _db = new OdeToFoodDB();

        [ChildActionOnly]
        public ActionResult BestReview()
        {
            var model = _db.Reviews.FindTheBest();
            return PartialView("_Review", model);
        }


        //
        // GET: /Review/

        public ActionResult Index()
        {
            var model = _db.Reviews.FindTheLatest(3);
            return View(model);
        }
        public ActionResult Index1()
        {
            var model = _db.Reviews.FindTheLatest(3);
            return View(model);
        }

        //
        // GET: /Review/Details/5

        public ActionResult Details(int id)
        {
            return View();
        }

        //
        // GET: /Review/Create

        public ActionResult Create()
        {
            return View(new Review());
        } 

        //
        // POST: /Review/Create

        [HttpPost]
        public ActionResult Create(int restaurantID, Review newReview)
        {
            try
            {
                var restaurant = _db.Restaurants.Single(r => r.ID == restaurantID);
                restaurant.Reviews.Add(newReview);
                _db.SaveChanges();
                return RedirectToAction("Index1");
            }
            catch
            {
                return View();
            }
        }
        
        //
        // GET: /Review/Edit/5
 
        public ActionResult Edit(int id)
        {
            var review = _db.Reviews.FindById(id);
            return View(review);
        }

        //
        // POST: /Review/Edit/5

        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection)
        {
            var review = _db.Reviews.FindById(id);
            if (TryUpdateModel(review))
            {
                return RedirectToAction("Index1");
            }
            return View(review);
            /*
            try
            {
                var review = _db.Reviews.FindById(id);
                TryUpdateModel(review);
 
                return RedirectToAction("Index1");
            }
            catch
            {
                return View();
            }
            */
        }

        //
        // GET: /Review/Delete/5
 
        public ActionResult Delete(int id)
        {
            return View();
        }

        //
        // POST: /Review/Delete/5

        [HttpPost]
        public ActionResult Delete(int id, FormCollection collection)
        {
            try
            {
                // TODO: Add delete logic here
 
                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
        }
    }
}
