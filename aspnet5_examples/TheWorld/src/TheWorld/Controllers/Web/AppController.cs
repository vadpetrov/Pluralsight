using AutoMapper;
using Microsoft.AspNet.Authorization;
using Microsoft.AspNet.Mvc;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Xsl;
using TheWorld.Data;
using TheWorld.Factories;
using TheWorld.Services;
using TheWorld.ViewModels;

namespace TheWorld.Controllers.Web
{
    public class AppController : BaseController //Controller
    {
        //private IMailService _mailService;
        //private IWorldRepository _repository;

        //public AppController(IMailService mailService, IWorldRepository repository)
        //{
        //    _mailService = mailService;
        //    _repository = repository;
        //}
        public AppController(IMailService mailService, IWorldRepository repository): base(mailService,repository)
        {
            
        }

        public IActionResult Index()
        {
            /*
            //var trips = _repository.GetAllTrips()
            var trips = Repository.GetAllTrips()
                .OrderBy(t=>t.Name)
                .ToList();

            return View(trips);
            */
            return View();
        }

        [Authorize]
        public IActionResult Trips()
        {
            /*
            var trips = Repository.GetAllTrips()
                .OrderBy(t => t.Name)
                .ToList();

            return View(trips);
            */
            return View();
        }

        [Route("app/{tripname}/toexcel")]
        public IActionResult ToExcel(string tripName)
        {
            var trip = Repository.GetTripByName(tripName, User.Identity.Name);
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

        public IActionResult About()
        {
            return View();
        }
        public IActionResult Contact()
        {
            return View();
        }

        [HttpPost]
        public IActionResult Contact(ContactViewModel model)
        {
            if (ModelState.IsValid)
            {
                var email = Startup.Configuration["AppSettings:SiteEmailAddress"];

                if (string.IsNullOrWhiteSpace(email))
                {
                    ModelState.AddModelError("", "Could not send email, configuration problem.");
                }

                //if (_mailService.SendMail(email,
                if (MailService.SendMail(email,
                     email,
                     $"Contact Page from {model.Name} ({model.Email})",
                     model.Message))
                {
                    ModelState.Clear();
                    ViewBag.Message = "Mail sent. Thanks!";
                }
            }
            return View();
        }
    }
}
