using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TheWorld.Models;
using TheWorld.ViewModels;

namespace TheWorld.Factories
{
    public static class FactoryExtensions
    {
        public static Trip Create(this IModelFactory factory, TripViewModel model)
        {
            var trip = new Trip
            {
                Id = model.Id,
                Name = model.Name,
                UserName = "sys",
                Created = model.Created,
                Stops = new List<Stop>()
            };
            return trip;
        }
        public static TripViewModel Create(this IModelFactory factory, Trip model)
        {
            var trip = new TripViewModel
            {
                Id = model.Id,
                Name = model.Name,
                Created = model.Created                
            };
            return trip;
        }

        public static Stop Create(this IModelFactory factory, StopViewModel model)
        {
            var stop = new Stop
            {
                Id = model.Id,
                Name = model.Name,
                Arrival = model.Arrival,
                Longitude = model.Longitude,
                Latitude = model.Latitude                
            };
            return stop;
        }
        public static StopViewModel Create(this IModelFactory factory, Stop model)
        {
            var stop = new StopViewModel
            {
                Id = model.Id,
                Name = model.Name,
                Arrival = model.Arrival,
                Longitude = model.Longitude,
                Latitude = model.Latitude                
            };
            return stop;
        }
    }
}
