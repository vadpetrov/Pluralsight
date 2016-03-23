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
using System.Net.Http;
using System.IO;
using System.Xml.Xsl;
using System.Text;
using System.Xml;
using Microsoft.AspNet.Cors;

namespace TheWorld.Controllers.Api
{
    //[Authorize]
    [Route("api/trips")]
    //[EnableCors("AllowAll")]
    public class TripController : BaseController //Controller
    {   
        public TripController(IWorldRepository repository, ILogger<TripController> logger, IModelFactory modelFactory):
            base(repository,logger,modelFactory)
        {
           
        }

        //[HttpGet("api/trips")]
        [HttpGet]
        [Authorize("Bearer")]
        //[EnableCors()]
        [EnableCors("AllowAll")]
        public JsonResult Get()
        {
            var trips = Repository.GetUserTripsWithStops(User.Identity.Name);
            var results = Mapper.Map<IEnumerable<TripViewModel>>(trips);

            //var results = _repository.GetAllTripsWithStops()
            //    .Select(t => _modelFactory.Create(t));

            return Json(results);
        }

        [HttpGet]
        [Route("~/api/trip/{tripname}/toexcel")]
        public IActionResult ToExcel(string tripName)
        //[Route("~/api/trip/{tripid:int}/toexcel")]
        //public IActionResult ToExcel(int tripId)
        {
            var trip = Repository.GetTripByName(tripName, User.Identity.Name);
            //var trip = Repository.GetTripById(tripId, User.Identity.Name);
            trip.Stops = trip.Stops.OrderBy(s => s.Order)
            .ThenBy(s => s.Name)
            .ToList();

            var tripVM = Mapper.Map<TripViewModel>(trip);
            var modelFactory = new WorldModelFactory();
            var xDoc = modelFactory.ToXml(tripVM);

            byte[] buffer;

            using (var ms = new MemoryStream())
            using (var sw = new StreamWriter(ms, Encoding.UTF8))
            {
                var settings = new XsltSettings(true, true);

                var resolver = new XmlUrlResolver();
                resolver.Credentials = CredentialCache.DefaultCredentials;

                var xslct = new XslCompiledTransform();
                xslct.Load(@"..\Views\App\test.xslt", settings, resolver);

                xslct.Transform(xDoc.CreateReader(), null, sw);

                ms.Seek(0, SeekOrigin.Begin);
                sw.Flush();
                buffer = ms.ToArray();
            }

            return File(buffer, "application/vnd.ms-excel", "ExcelReport.xls");
        }

        //[HttpPost("api/trips")]
        [HttpPost("")]
        [EnableCors("AllowAll")]
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
