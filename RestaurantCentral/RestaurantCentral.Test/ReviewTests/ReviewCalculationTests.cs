using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using NUnit.Framework;
using RestaurantCentral.Models;


namespace RestaurantCentral.Test.ReviewTests
{
    [TestFixture]
    public class TestClass
    {
        [Test]
        public void Simple_Averaging_For_One_Review()
        {
            var data = BuildRestaurantForReview(4);
            /*
            var data = new Restaurant();
            data.Reviews = new List<Review>();
            data.Reviews.Add(new Review() { Rating = 4 });
            */
            var rater = new RestaurantRater(data);
            //var result = rater.ComputeSimpleRate(10);
            var result = rater.ComputeRate(new SimpleRatingAlgorithm(), 10);

            Assert.AreEqual(4, result.Rating);
        }
        [Test]
        public void Simple_Averaging_For_Two_Reviews()
        {

            var data = BuildRestaurantForReview(4, 8);
            /*
            var data = new Restaurant();
            data.Reviews = new List<Review>();
            data.Reviews.Add(new Review() { Rating = 4 });
            data.Reviews.Add(new Review() { Rating = 8 });
            */

            var rater = new RestaurantRater(data);
            //var result = rater.ComputeSimpleRate(10);
            var result = rater.ComputeRate(new SimpleRatingAlgorithm(), 10);

            Assert.AreEqual(6, result.Rating);
        }

        [Test]
        public void Weighted_Averaging_For_Two_Reviews()
        {
            var data = BuildRestaurantForReview(3, 9);
            var rater = new RestaurantRater(data);
            var result = rater.ComputeRate(new WeightedRatingAlgorithm(), 10);

            Assert.AreEqual(5, result.Rating);
        }

        [Test]
        public void Rating_Includes_Only_First_N_Reviews()
        {
            var data = BuildRestaurantForReview(1, 1, 1, 10, 10, 10);

            var rater = new RestaurantRater(data);
            var result = rater.ComputeRate(new SimpleRatingAlgorithm(), 3);

            Assert.AreEqual(1, result.Rating);
        }

        private Restaurant BuildRestaurantForReview(params int[] ratings)
        {
            var result = new Restaurant();
            result.Reviews = ratings
                .Select(r => new Review { Rating = r })
                .ToList();
            return result;
        }
    }
}
