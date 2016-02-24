using NewWebAPI.Factories;
using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace NewWebAPI.Controllers
{
    public abstract class BaseApiController : ApiController
    {
        IDbContext _db;
        private EFModelFactory _modelFactory;

        //RestaurantModelFactory _restaurantModelFactory;
        //ReviewModelFactory _reviewModelFactory;
        //OrderModelFactory _orderModelFactory;

        public BaseApiController(IDbContext db)
        {
            _db = db;
        }

        protected IDbContext Repository 
        {
            get { return _db; }
        }

        protected EFModelFactory ModelFactory
        {
            get
            {
                if (_modelFactory == null)
                {
                    _modelFactory = new EFModelFactory(this.Request);
                }
                return _modelFactory;
            }
        }


        /*
        protected RestaurantModelFactory RestaurantModelFactory
        {
            get
            {
                if (_restaurantModelFactory == null)
                {
                    _restaurantModelFactory = new RestaurantModelFactory(this.Request);
                }
                return _restaurantModelFactory;
            }
        }

        protected ReviewModelFactory ReviewModelFactory
        {
            get
            {
                if (_reviewModelFactory == null)
                {
                    _reviewModelFactory = new ReviewModelFactory(this.Request);
                }
                return _reviewModelFactory;
            }
        }

        protected OrderModelFactory OrderModelFactory
        {
            get
            {
                if (_orderModelFactory == null)
                {
                    _orderModelFactory = new OrderModelFactory(this.Request);
                }
                return _orderModelFactory;
            }
        }
        */
    }
}
