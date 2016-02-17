using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace RestaurantCentral.Models
{
    public class RCDB : DbContext
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
    }
}