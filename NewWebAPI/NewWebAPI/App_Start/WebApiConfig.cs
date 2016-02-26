using NewWebAPI.Filters;
using Newtonsoft.Json.Serialization;
using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Web.Http;
using WebApiContrib.Formatting.Jsonp;

//using Microsoft.Practices.Unity;
//using Microsoft.Practices.Unity.Configuration;
//using Microsoft.Practices.ServiceLocation;
//using NewWebAPI.Resolver;

namespace NewWebAPI
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {

            //var container = new UnityContainer();
            //container.RegisterType<IDbContext, RCDB>(new HierarchicalLifetimeManager());
            //container.LoadConfiguration();
            //config.DependencyResolver = new UnityResolver(container);
            config.DependencyResolver = IoC.IocContainer.UnityResolver;


            config.Routes.MapHttpRoute(
                name: "Restaurants",
                routeTemplate: "api/rc/restaurants/{restaurantid}",
                defaults: new { controller = "restaurants", restaurantid = RouteParameter.Optional }
                //,constraints: new { id = @"\d+" }//one or more digits
            );
            config.Routes.MapHttpRoute(
                name: "Reviews",
                routeTemplate: "api/rc/restaurants/{restaurantid}/reviews/{id}",
                defaults: new { controller = "reviews", id = RouteParameter.Optional }
            );
            config.Routes.MapHttpRoute(
                name: "Orders",
                routeTemplate: "api/client/orders/{orderid}",
                defaults: new { controller = "orders", orderid = RouteParameter.Optional }
            );
            config.Routes.MapHttpRoute(
                name: "OrdersItems",
                routeTemplate: "api/client/orders/{orderid}/items/{id}",
                defaults: new { controller = "orderitems", id = RouteParameter.Optional }
            );
            config.Routes.MapHttpRoute(
                name: "OrderSummary",
                routeTemplate: "api/client/orders/{orderid}/summary",
                defaults: new { controller = "ordersummary"}
            );


            //config.Routes.MapHttpRoute(
            //    name: "Products",
            //    routeTemplate: "api/products/{id}",
            //    defaults: new { controller = "products", id = RouteParameter.Optional }
            //);

            config.Routes.MapHttpRoute(
                name: "Products",
                routeTemplate: "api/products/{id}/{action}/{entityid}",
                defaults: new
                    {
                        controller = "products",
                        id = RouteParameter.Optional,
                        entityid = RouteParameter.Optional,
                        action = "DefaultAction"
                    }
            );

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );



            //VP1 -- makes JSON the default webApi response type
            //config.Formatters.JsonFormatter.SupportedMediaTypes.Add(new MediaTypeHeaderValue("text/html"));
           
            //VP2
            //var appXmlType = config.Formatters.XmlFormatter.SupportedMediaTypes.FirstOrDefault(t => t.MediaType == "application/xml");
            //config.Formatters.XmlFormatter.SupportedMediaTypes.Remove(appXmlType);

            //VP3
            GlobalConfiguration.Configuration.Formatters.JsonFormatter.MediaTypeMappings.Add(new RequestHeaderMapping("Accept", "text/html", StringComparison.InvariantCultureIgnoreCase, true, "application/json"));

            var jsonFormatter = config.Formatters.OfType<JsonMediaTypeFormatter>().FirstOrDefault();
            jsonFormatter.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();

            //Add support JSONP
            var jsonpformatter = new JsonpMediaTypeFormatter(jsonFormatter,"cb");
            config.Formatters.Insert(0,jsonpformatter);

            


            //custom code
            //Forse HTTPS on entire API
#if !DEBUG
            config.Filters.Add(new RequireHttpsAttribute());
#endif


            // Uncomment the following line of code to enable query support for actions with an IQueryable or IQueryable<T> return type.
            // To avoid processing unexpected or malicious queries, use the validation settings on QueryableAttribute to validate incoming queries.
            // For more information, visit http://go.microsoft.com/fwlink/?LinkId=279712.
            //config.EnableQuerySupport();

            // To disable tracing in your application, please comment out or remove the following line of code
            // For more information, refer to: http://www.asp.net/web-api
            config.EnableSystemDiagnosticsTracing();
        }
    }
}
