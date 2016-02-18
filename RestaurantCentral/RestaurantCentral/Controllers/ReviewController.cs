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
        //RCDB _db = new RCDB();


        private IDbContext _db;


        //public ReviewController()
        //{
        //    _db = new RCDB();
        //}

        public ReviewController(IDbContext db)
        {
            _db = db;
        }

        public ActionResult Index()
        {
            var review = _db.Reviews.FindTheLatest(3);
            return View(review);
        }

        public ActionResult Create()
        {
            return View(new Review());
        }


        [HttpPost]
        public ActionResult Create(int RestaurantID, Review newReview)
        {
            if (ModelState.IsValid)
            {
                var restaurant = _db.Restaurants.FindById(RestaurantID);
                newReview.Created = DateTime.Now;
                newReview.Body = Sanitizer.GetSafeHtmlFragment(newReview.Body);
                _db.Add(newReview);
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            newReview.InitRestaurant();
            return View(newReview);
        }

        [HttpPost]
        public ActionResult Create1(int RestaurantID, Review newReview)
        {
            try
            {
                var _db = new RCDB1("RCDB");
                var restaurant = _db.Restaurants.Single(r => r.ID == RestaurantID);
                newReview.Created = DateTime.Now;
                newReview.Body = Sanitizer.GetSafeHtmlFragment(newReview.Body);
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
        public ActionResult Edit(Review review)
        {

            //try
            //{
            //    review.Body = Sanitizer.GetSafeHtmlFragment(review.Body);
            //    _db.Attach(review);
            //    _db.SaveChanges();
            //    return RedirectToAction("Index");
            //}
            //catch (System.Data.Entity.Validation.DbEntityValidationException ex)
            //{
            //    System.Text.StringBuilder sb = new System.Text.StringBuilder();

            //    foreach (var failure in ex.EntityValidationErrors)
            //    {
            //        sb.AppendFormat("{0} failed validation\n", failure.Entry.Entity.GetType());
            //        foreach (var error in failure.ValidationErrors)
            //        {
            //            sb.AppendFormat("- {0} : {1}", error.PropertyName, error.ErrorMessage);
            //            sb.AppendLine();
            //        }
            //    }

            //    throw new System.Data.Entity.Validation.DbEntityValidationException(
            //        "Entity Validation Failed - errors follow:\n" +
            //        sb.ToString(), ex
            //        );
            //}

            if (ModelState.IsValid)
            {
                review.Body = Sanitizer.GetSafeHtmlFragment(review.Body);
                _db.Attach(review);
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            review.InitRestaurant();
            return View(review);
        }

        /*
        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public ActionResult Edit2(Review review)
        {
            if (ModelState.IsValid)
            {
                review.Body = Sanitizer.GetSafeHtmlFragment(review.Body);
                _db.Entry(review).State = EntityState.Modified;
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            //var a = new RCDB();
            //a.Entry()
            return View(review);
        }
        */

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        //[ValidateInput(false)]
        //public ActionResult Edit(int id, FormCollection collection)
        public ActionResult Edit333(int id, Review review)
        //public ActionResult Edit(Review review)
        {
            /*
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
            var restaurant = _db.Restaurants.FindById(review.RestaurantID);
            review.Restaurant = restaurant;
            return View(review);
            */

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
            return View(review);
        }
    }
}
