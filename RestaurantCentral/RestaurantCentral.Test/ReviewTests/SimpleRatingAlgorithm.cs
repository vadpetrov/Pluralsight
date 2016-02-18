using RestaurantCentral.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace RestaurantCentral.Test.ReviewTests
{
    class SimpleRatingAlgorithm : IRatingAlgorithm
    {
        public RateResult Compute(IList<Review> reviews)
        {
            var result = new RateResult();
            result.Rating = (int)reviews.Average(r => r.Rating);
            return result;
        }
    }
}
