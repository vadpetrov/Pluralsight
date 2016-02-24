using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Microsoft.Practices.Unity;
using Microsoft.Practices.Unity.Configuration;
using Microsoft.Practices.ServiceLocation;
using NewWebAPI.IoC.Resolvers;
using NewWebAPI.Models;
using NewWebAPI.Services;

namespace NewWebAPI.IoC
{
    public static class IocContainer
    {
        private static IUnityContainer _container;

        static IocContainer()
        {
            Initialize();
        }
        static void Initialize()
        {
            _container = new UnityContainer();
            //_container.RegisterType<IDbContext, RCDB>(new HierarchicalLifetimeManager());
            //_container.RegisterType<IRCIdentityService, RCIdentityService>(new HierarchicalLifetimeManager());
            _container.LoadConfiguration();
        }

        public static UnityResolver UnityResolver
        {
            get { return new UnityResolver(_container); }
        }
    }
}