using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TheWorld.Factories
{
    public class WorldModelFactory : IModelFactory
    {
        //public TripViewModel Create<Trip, TripViewModel>(Trip model)
        //    where Trip : class
        //    where TripViewModel : new()
        //{

        //    return new TripViewModel();
        //}        
        public R Create<T, R>(T model)
            where T : class
            where R : new()
        {
            throw new NotImplementedException();
        }
    }

}
