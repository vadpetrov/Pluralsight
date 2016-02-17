using OdeToFood.Infrastructure;
using OdeToFood.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace OdeToFood
{
    // Note: For instructions on enabling IIS6 or IIS7 classic mode, 
    // visit http://go.microsoft.com/?LinkId=9394801

    public class MvcApplication : System.Web.HttpApplication
    {
        public static void RegisterGlobalFilters(GlobalFilterCollection filters)
        {
           filters.Add(new HandleErrorAttribute());
           filters.Add(new LogAttribute());
        }

        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                "Cuisine",
                "cuisine/{name}",
                new { controller = "Cuisine", action = "Search", name = UrlParameter.Optional} // Parameter defaults
                );

            routes.MapRoute(
                "Default", // Route name
                "{controller}/{action}/{id}", // URL with parameters
                new { controller = "Home", action = "Index", id = UrlParameter.Optional } // Parameter defaults
            );
        }

        protected void Application_Start()
        {
            //PrepopulateData();
           //Database.SetInitializer(new DropCreateDatabaseIfModelChanges<OdeToFoodDB>());
            //Database.SetInitializer(new OdeToFoodDBInitiliazer());
            
            AreaRegistration.RegisterAllAreas();

            // Use LocalDB for Entity Framework by default
            //Database.DefaultConnectionFactory = new SqlConnectionFactory(@"Data Source=(localdb)\v11.0; Integrated Security=True; MultipleActiveResultSets=True");

            RegisterGlobalFilters(GlobalFilters.Filters);
            RegisterRoutes(RouteTable.Routes);
        }

        private void PrepopulateData()
        {
            var context = new OdeToFoodDB();
            context.Restaurants.Add(new RestaurantRow
            {
                Name = "Marrakesh",
                Address = new Address
                {
                    City = "Washington",
                    State = "D.C.",
                    Country = "USA"
                }
            });

            context.Restaurants.Add(new RestaurantRow
            {
                Name = "Sabatino's",
                Address = new Address
                {
                    City = "Baltimore",
                    State = "MD",
                    Country = "USA"
                }
            });

            context.Restaurants.Add(new RestaurantRow
            {
                Name = "The Kings Contrivance",
                Address = new Address
                {
                    City = "Columbia",
                    State = "MD",
                    Country = "USA"
                }
            });

            context.SaveChanges();
        }
    }

    public class OdeToFoodDBInitiliazer : DropCreateDatabaseIfModelChanges<OdeToFoodDB>
    {
        protected override void Seed(OdeToFoodDB context)
        {
            base.Seed(context);

            context.Restaurants.Add(new RestaurantRow
            {
                Name = "Marrakesh",
                Address = new Address
                {
                    City = "Washington",
                    State = "D.C.",
                    Country = "USA"
                }
            });

            context.Restaurants.Add(new RestaurantRow
            {
                Name = "Sabatino's",
                Address = new Address
                {
                    City = "Baltimore",
                    State = "MD",
                    Country = "USA"
                }
            });

            context.Restaurants.Add(new RestaurantRow
            {
                Name = "The Kings Contrivance",
                Address = new Address
                {
                    City = "Columbia",
                    State = "MD",
                    Country = "USA"
                }
            });

            context.SaveChanges();
        }

    }
}