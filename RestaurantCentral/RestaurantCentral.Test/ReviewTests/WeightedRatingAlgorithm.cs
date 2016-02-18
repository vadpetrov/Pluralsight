using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RestaurantCentral.Test.ReviewTests
{
    class WeightedRatingAlgorithm : IRatingAlgorithm
    {
        public RateResult Compute(IList<Review> reviews)
        {
            var result = new RateResult();            
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
    }
}
