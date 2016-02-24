using System;
using System.Collections.Generic;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Text;

namespace NewWebAPI.Models
{
    public interface IDbContext
    {
        IQueryable<Restaurant> Restaurants { get; }
        IQueryable<Review> Reviews { get; }
        IQueryable<Order> Orders { get; }
        IQueryable<Client> Clients { get; }
        IQueryable<OrderItem> OrderItems { get; }
        IQueryable<Product> Products { get; }
        

        int SaveChanges();
        T Attach<T>(T entity) where T : class;
        T Add<T>(T entity) where T : class;
        T Delete<T>(T entity) where T : class;
    }
}
