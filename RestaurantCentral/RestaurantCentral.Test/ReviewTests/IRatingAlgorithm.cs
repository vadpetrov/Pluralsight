using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RestaurantCentral.Models;

namespace RestaurantCentral.Test.ReviewTests
{
    interface IRatingAlgorithm
    {
        RateResult Compute(IList<Review> reviews);
    }
}
