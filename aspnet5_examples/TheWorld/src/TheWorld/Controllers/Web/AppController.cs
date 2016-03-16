using Microsoft.AspNet.Authorization;
using Microsoft.AspNet.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TheWorld.Data;
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
