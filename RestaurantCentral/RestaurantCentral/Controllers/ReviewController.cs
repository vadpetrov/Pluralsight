using System.Data;
using RestaurantCentral.Queries;
using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Microsoft.Security.Application;

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

        [Authorize]
        public ActionResult Edit(int id)
        {
            var review = _db.Reviews.FindById(id);
            return View(review);
        }

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        //[ValidateInput(false)]
        //public ActionResult Edit(int id, FormCollection collection)
        public ActionResult Edit(int id, Review review)
        //public ActionResult Edit(Review review)
        {
            //if (ModelState.IsValid)
            //{
            //    review.Created = DateTime.Now;
            //    _db.Entry(review).State = EntityState.Modified;
            //    _db.SaveChanges();
            //    return RedirectToAction("Index");
            //}
            //return View(review);

            if (ModelState.IsValid)
            {
                var item = _db.Reviews.FindById(id);
                item.Body = Sanitizer.GetSafeHtmlFragment(review.Body);
                item.Rating = review.Rating;
                item.DiningDate = review.DiningDate;
                _db.Entry(item).State = EntityState.Modified;
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(review);

            /*
            var review = _db.Reviews.FindById(id);
            if (TryUpdateModel(review))
            {
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
             * 
            return View(review);
            */
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
