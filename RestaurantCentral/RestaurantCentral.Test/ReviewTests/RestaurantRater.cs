using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RestaurantCentral.Test.ReviewTests
{
    class RestaurantRater
    {
        private Restaurant _restaurant;

        public RestaurantRater(Restaurant restaurant)
        {
            _restaurant = restaurant;
        }

        public RateResult ComputeSimpleRate(int numberOffReviewToUse)
        {
            var resut = new RateResult();
            resut.Rating = (int)_restaurant.Reviews.Average(r => r.Rating);
            return resut;
        }

        public RateResult ComputeWeightedRate(int numberOffReviewToUse)
        {
            var result = new RateResult();
            var reviews = _restaurant.Reviews.ToList();
            var counter = 0;
            var total = 0;

            for (int i = 0; i < reviews.Count; i++)
            {
                if (i < reviews.Count / 2)
                {
                    counter += 2;
                    total += reviews[i].Rating * 2;
                }
                else
                {
                    counter += 1;
                    total += reviews[i].Rating;
                }
            }

            result.Rating = total / counter;
            return result;
        }

        public RateResult ComputeRate(IRatingAlgorithm algorithm, int numberOffReviewToUse)
        {
            return algorithm.Compute(_restaurant.Reviews
                .Take(numberOffReviewToUse).ToList());
        }
    }
}
