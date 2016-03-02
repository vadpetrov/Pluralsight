using System;
using Microsoft.Practices.Unity;
using System.Linq;

namespace RepositoryTest
{
    class Program
    {
        static void Main(string[] args)
        {

            var conn = IocContainer.Container.Resolve<IDbConnectionFactory>().Create();
            var repo = new FCDatabaseContext(conn);

            var reviews = repo.Reviews.
                GetAll()                
                .Join(repo.Restaurants.GetAll(),
                outerKey => outerKey.RestaurantID,
                innerKey => innerKey.ID,
                (review, restaurant) => new Review
                {       
                    ID = review.ID,
                    Rating = review.Rating,
                    DiningDate = review.DiningDate,
                    Body = review.Body,
                    Restaurant = restaurant
                });            
            
            foreach (var p in reviews.OrderBy(p => p.Restaurant.Name))
            {
                //Console.WriteLine("{0} - {1}", "Date", p.DiningDate.ToShortDateString());
                //Console.WriteLine("{0} - {1}", "Body", p.Body);
                //Console.WriteLine("{0}", p.Restaurant.Name);
                Console.WriteLine("{0} Dining Date:{1}", p.Restaurant.Name, p.DiningDate);
            }

            var reviews1 = repo.Reviews
                .GetAll();
                
                

            var aa = 1;

            /*
            var products = repo.Products.GetAll();

            foreach (var p in products.OrderBy(p => p.Name))
            {
                Console.WriteLine("{0} - {1}: {2}", "Product", p.Name, p.Price);
            }

            Console.WriteLine();

            var restaurants = repo.Restaurants.GetAll();

            foreach (var p in restaurants.OrderBy(r=>r.Address.State))
            {
                Console.WriteLine("{0} - {1}: {2}", "Restaurant", p.Name, p.Address.State);
            }
            */

            /*
            var pr = new ProductRepository(con);
            var products = pr.GetAll();
            var b = pr.FindById(7);
            foreach (var p in products.OrderBy(p => p.Name))
            {
                Console.WriteLine("{0} - {1}: {2}", "Product", p.Name, p.Price);
            }
            */

            //var c = pr.Add(new Product()
            //{
            //    Name = "Slow Roasted Tomato & Basil Soup",
            //    Description = null,
            //    Price = 2.79m
            //});
            Console.ReadKey();
        }
    }
}
