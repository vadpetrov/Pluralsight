using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Linq;
using System.Web;

namespace RestaurantCentral.Models
{
    public class RCDB : DbContext, IDbContext
    {
        public DbSet<Restaurant> Restaurants { get; set; }
        public DbSet<Review> Reviews { get; set; }
        
        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Street).HasColumnName("Street");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.City).HasColumnName("City");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Country).HasColumnName("Country");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.State).HasColumnName("State");
            
            base.OnModelCreating(modelBuilder);
        }

        //public virtual new DbEntityEntry<T> Entry<T>(T entity) where T : class
        //{
        //    return base.Entry(entity);
        //}

        IQueryable<Restaurant> IDbContext.Restaurants
        {
            get { return Restaurants; }
        }

        IQueryable<Review> IDbContext.Reviews
        {
            get { return Reviews; }
        }

        public T Attach<T>(T entity) where T : class
        {
            var entry = Entry(entity);
            entry.State = EntityState.Modified;
            //Entry(entity).CurrentValues.SetValues(entity);
            return entity;
        }

        public T Add<T>(T entity) where T : class
        {
            return Set<T>().Add(entity);
        }

        public T Delete<T>(T entity) where T : class
        {
            return Set<T>().Remove(entity);
        }
    }

    public class RCDB1 : DbContext
    {
        public DbSet<Restaurant> Restaurants { get; set; }
        public DbSet<Review> Reviews { get; set; }

        public RCDB1(string connectionStringName):base(connectionStringName)
        {
            //base.Database.Connection.ConnectionString
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Street).HasColumnName("Street");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.City).HasColumnName("City");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Country).HasColumnName("Country");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.State).HasColumnName("State");

            base.OnModelCreating(modelBuilder);
        }
    }
}