using AutoMapper;
using Microsoft.AspNet.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using TheWorld.Data;
using TheWorld.Models;
using TheWorld.ViewModels;
using TheWorld.Factories;
using Microsoft.Extensions.Logging;
using Microsoft.AspNet.Authorization;

namespace TheWorld.Controllers.Api
{
    [Authorize]
    [Route("api/trips")]
    public class TripController : BaseController //Controller
    {   
        public TripController(IWorldRepository repository, ILogger<TripController> logger, IModelFactory modelFactory):
            base(repository,logger,modelFactory)
        {
           
        }

        //[HttpGet("api/trips")]
        [HttpGet("")]
        public JsonResult Get()
        {
            var trips = Repository.GetUserTripsWithStops(User.Identity.Name);
            var results = Mapper.Map<IEnumerable<TripViewModel>>(trips);

            //var results = _repository.GetAllTripsWithStops()
            //    .Select(t => _modelFactory.Create(t));

            return Json(results);
        }

        //[HttpPost("api/trips")]
        [HttpPost("")]
        public JsonResult Post([FromBody]TripViewModel model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    //var newTrip = _modelFactory.Create(model);
                    var newTrip = Mapper.Map<Trip>(model);

                    if(Repository.GetAllTrips().Where(t => t.Name == newTrip.Name).Any())
                    {
                        Response.StatusCode = (int)HttpStatusCode.BadRequest;
                        return Json(new { Message = "Trip already exists" });
                    }


                    newTrip.UserName = User.Identity.Name;
                    
                    //Save to Database                    
                    Logger.LogInformation("Attempting to save new trip");                   

                    Repository.AddTrip(newTrip);

                    if (Repository.SaveAll())
                    {
                        Response.StatusCode = (int)HttpStatusCode.Created;
                        return Json(Mapper.Map<TripViewModel>(newTrip));
                    }
                }
            }
            catch (Exception ex)
            {   
                Logger.LogError("Failed to save new trip", ex);
                Response.StatusCode = (int)HttpStatusCode.BadRequest;
                return Json(new { Maessage = ex.Message, ex });
            }
            Response.StatusCode = (int)HttpStatusCode.BadRequest;
            //return Json("Failed");
            return Json(new { Maessage = "Failed", ModelState = ModelState });
        }
    }
}
