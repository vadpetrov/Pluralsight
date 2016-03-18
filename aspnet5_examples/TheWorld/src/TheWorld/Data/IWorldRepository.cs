using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TheWorld.Models;

namespace TheWorld.Data
{    public interface IWorldRepository
    {
        IEnumerable<Trip> GetAllTrips();
        IEnumerable<Trip> GetAllTripsWithStops();
        //Trip GetTripByName(string tripName);
        Trip GetTripByName(string tripName, string userName);
        Trip GetTripById(int tripId, string userName);

        IEnumerable<Trip> GetUserTripsWithStops(string name);



        void AddTrip(Trip newTrip);
        void AddStop(string tripName, string userName, Stop newStop);
        //void AddStop(string tripName, Stop newStop);
        bool SaveAll();
        
    }
}
