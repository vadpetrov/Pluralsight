using RestaurantCentral.Queries;
using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace RestaurantCentral.Controllers
{
    public class RestaurantController : Controller
    {
        RCDB _db = new RCDB();

        public ActionResult Index(string state=null)
        {   
            ViewBag.States = _db.Restaurants
                .Where(r=>r.Address.State != null)
                .OrderBy(r=>r.Address.State)
                .Select(r=>r.Address.State)
                //.Concat(new string[]{"--All--"})
                .Distinct();

            if (state == "--All--" || state == "") state = null;

            var model = _db.Restaurants.FindByState(state);
            return View(model);
        }
        public ActionResult Create()
        {
            return View(new Restaurant());
        }
        [HttpPost]
        public ActionResult Create(Restaurant model)
        {
            model.AddDate = DateTime.Now;
            _db.Restaurants.Add(model);
            _db.SaveChanges();
            
            return RedirectToAction("Index");
        }

        public ActionResult Edit(int id)
        {
            var model = _db.Restaurants.FindById(id);
            return View(model);
        }

        //[HttpPost]
        //public ActionResult Edit(int id, Restaurant model)
        //{

        //    if (ModelState.IsValid)
        //    {
        //        var d = model.AddDate;
        //        _db.Entry(model).State = EntityState.Modified;
        //        _db.SaveChanges();
        //        return RedirectToAction("Index");
        //    }
        //    return View(model);
        //}

        //[HttpPost]
        //public ActionResult Edit(Restaurant model)
        //{
        //    var restaurant = _db.Restaurants.FindById(model.ID);

        //    if (restaurant == null)
        //    {
        //        return HttpNotFound();
        //    }


        //    if (ModelState.IsValid)
        //    {
        //        restaurant.Name         = model.Name;
        //        restaurant.Address.City = model.Address.City;
        //        restaurant.Address.State = model.Address.State;
        //        restaurant.Address.Country = model.Address.Country;

        //        _db.SaveChanges();

        //        return RedirectToAction("Index");
        //    }
        //    return View(restaurant);
        //}



        [HttpPost]
        public ActionResult Edit(int id, FormCollection collection)
        {
            var model = _db.Restaurants.FindById(id);

            if (TryUpdateModel(model))
            {
                _db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(model);
        }

        //[HttpPost]
        public ActionResult Delete(int id)
        {
            var restaurant = _db.Restaurants.FindById(id);
            _db.Restaurants.Remove(restaurant);
            _db.SaveChanges();
            return RedirectToAction("Index");
        }


        public ActionResult Details(int id)
        {
            var model = _db.Restaurants.FindById(id);
           
            if (model == null)
            {
                return HttpNotFound();
            }

            return View(model);
        }
    }
}
