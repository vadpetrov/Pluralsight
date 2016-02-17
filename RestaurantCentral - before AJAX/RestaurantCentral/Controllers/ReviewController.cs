using RestaurantCentral.Queries;
using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace RestaurantCentral.Controllers
{
    public class ReviewController : Controller
    {
        RCDB _db = new RCDB();

        public ActionResult Index()
        {
            var review = _db.Reviews.FindTheLatest(20);
            return View(review);
        }

        public ActionResult Create()
        {
            return View(new Review());
        }

        [HttpPost]
        public ActionResult Create(int RestaurantID, Review newReview)
        {
            try
            {

                var restaurant = _db.Restaurants.Single(r => r.ID == RestaurantID);
                newReview.Created = DateTime.Now;
                restaurant.Reviews.Add(newReview);
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }

        }

        public ActionResult Edit(int id)
        {
            var review = _db.Reviews.FindById(id);
            return View(review);
        }

        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection)
        //public ActionResult Edit(int id, Review r)
        {
            /*
            var review = _db.Reviews.FindById(id);
            review.Body = r.Body;
            review.Rating = r.Rating;
            review.DiningDate = r.DiningDate;
            _db.SaveChanges();
            return RedirectToAction("Index");
            */

            var review = _db.Reviews.FindById(id);
            if (TryUpdateModel(review))
            {
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(review);
            /*
            try
            {
                var review = _db.Reviews.FindById(id);
                TryUpdateModel(review);
 
                return RedirectToAction("Index");
            }
            catch
            {
                return View();
            }
            */
        }
    }
}
