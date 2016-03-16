using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNet.Mvc;
using Microsoft.Extensions.Logging;
using TheWorld.Factories;
using TheWorld.Data;
using TheWorld.Services;

namespace TheWorld.Controllers
{
    public abstract class BaseController : Controller
    {
        private IMailService _mailService;
        private ILogger<BaseController> _logger;
        private IModelFactory _modelFactory;
        private IWorldRepository _repository;

        
        public BaseController(IWorldRepository repository, ILogger<BaseController> logger, IModelFactory modelFactory)
        {
            _repository = repository;
            _logger = logger;
            _modelFactory = modelFactory;
        }
        public BaseController(IMailService mailService, IWorldRepository repository)
        {
            _mailService = mailService;
            _repository = repository;
        }

        

        public IWorldRepository Repository
        {
            get { return _repository; }
        }

        public IMailService MailService
        {
            get { return _mailService; }
        }
        public IModelFactory ModelFactory
        {
            get
            {
                if (_modelFactory == null)
                {
                    _modelFactory = new WorldModelFactory();
                }
                return _modelFactory;
            }
        }
        public ILogger<BaseController> Logger
        {
            get
            {
                if (_logger == null)
                {
                    _logger = null;// inst New default logger
                }
                return _logger;
            }
        }
    }
}
