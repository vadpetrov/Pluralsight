using Microsoft.Data.Entity;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TheWorld.Models;

namespace TheWorld.Data
{
    public class WorldRepository: IWorldRepository
    {
        private WorldContext _context;
        private ILogger<WorldRepository> _logger;

        public WorldRepository(WorldContext context, ILogger<WorldRepository> logger)
        {
            _context = context;
            _logger = logger;
        }
        
        public IEnumerable<Trip> GetAllTrips()
        {
            try
            {
                return _context.Trips.OrderBy(t => t.Name).ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError("Could not get trips from database", ex);
                return null;
                //return new List<Trip>();
            }
        }

        public IEnumerable<Trip> GetAllTripsWithStops()
        {
            try
            {
                return _context.Trips
                    .Include(t => t.Stops)
                    .OrderBy(t => t.Name)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError("Could not get trips with stops from database", ex);
                return null;
                //throw;
            }
        }

        public IEnumerable<Trip> GetUserTripsWithStops(string name)
        {
            try
            {
                return _context.Trips
                    .Include(t => t.Stops)
                    .Where(t => t.UserName == name)
                    .OrderBy(t => t.Name)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError("Could not get trips with stops from database", ex);
                return null;
            }
        }

        public void AddTrip(Trip newTrip)
        {
            _context.Add(newTrip);
        }
        public bool SaveAll()
        {
            return _context.SaveChanges() > 0;
        }

        //public Trip GetTripByName(string tripName)
        //{
        //    return _context.Trips
        //        .Include(t => t.Stops)
        //        .Where(t => t.Name == tripName)
        //        .FirstOrDefault();
        //}
        public Trip GetTripByName(string tripName, string userName)
        {
            return _context.Trips
                .Include(t => t.Stops)
                .Where(t => t.Name == tripName && t.UserName == userName)
                .FirstOrDefault();
        }

        public void AddStop(string tripName, string userName, Stop newStop)
        {
            var trip = GetTripByName(tripName, userName);
            newStop.Order = (trip.Stops.Any() ? trip.Stops.Max(s => s.Order) + 1 : 1);
            trip.Stops.Add(newStop);
            _context.Add(newStop);
        }

        //public void AddStop(string tripName, Stop newStop)
        //{
        //    var trip = GetTripByName(tripName);
        //    newStop.Order = trip.Stops.Max(s => s.Order) + 1;
        //    trip.Stops.Add(newStop);
        //    _context.Add(newStop);
        //}
    }
}
