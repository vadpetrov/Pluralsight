using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using System.Web.Mvc;
using RestaurantCentral.Controllers;
using RestaurantCentral.Models;

namespace RestaurantCentral.Test.ReviewTests
{
    [TestFixture]
    public class ReviewsControllerTests
    {
        FakeDbContext _db;

        [SetUp]
        public void Setup()
        {
            _db = new FakeDbContext();

            _db.Restaurants = new[]
                {
                    new Restaurant() {ID = 1, Name = "Restoran 1"},
                    new Restaurant() {ID = 2, Name = "Restoran 2"},
                    new Restaurant() {ID = 3, Name = "Restoran 3"},
                    new Restaurant() {ID = 4, Name = "Restoran 4"},
                    new Restaurant() {ID = 5, Name = "Restoran 5"}
                }.AsQueryable();

            _db.Reviews = new[] { 
                    new Review(){ID = 1, RestaurantID = 1, Body = "SSS",DiningDate = new DateTime(2015,2,13),Rating = 9}, 
                    new Review(){ID = 2, RestaurantID = 2, Body = "SSSas32",DiningDate = new DateTime(2014,11,7),Rating = 3}, 
                    new Review(){ID = 3, RestaurantID = 3, Body = "SassaSS",DiningDate = new DateTime(2015,5,24),Rating = 6}, 
                    new Review(){ID = 4, RestaurantID = 1, Body = "asfasd" ,DiningDate = new DateTime(2010,2,8),Rating = 10}
            }.AsQueryable();
        }

        [Test]
        public void Index_Action_Model_Is_Three_Reviews()
        {
            var controller = new ReviewController(_db);
            var result = controller.Index() as System.Web.Mvc.ViewResult;
            var model = result.Model as IEnumerable<Review>;

            Assert.AreEqual(3, model.Count());
        }

        [Test]
        public void Edit_Action_Saves_Updated_Review()
        {
            var editedReview = new Review();
            var controller = new ReviewController(_db);
            controller.Edit(editedReview);

            Assert.IsTrue(_db.Reviews.Contains(editedReview));
        }

        [Test]
        public void Edit_Action_Saves_Changes()
        {
            var editedReview = new Review();
            var controller = new ReviewController(_db);
            controller.Edit(editedReview);

            Assert.IsTrue(_db.ChangesSaved);
        }
    }
}
