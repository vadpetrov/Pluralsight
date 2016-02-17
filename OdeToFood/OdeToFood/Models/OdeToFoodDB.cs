using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace OdeToFood.Models
{
    public class OdeToFoodDB : DbContext
    {
        public DbSet<RestaurantRow> Restaurants { get; set; }
        public DbSet<Review> Reviews { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<RestaurantRow>()
                .ToTable("restaurants");

            modelBuilder.Entity<RestaurantRow>()
                        .Property(r => r.ID).HasColumnName("restaurant_id");

            modelBuilder.Entity<RestaurantRow>()
                        .Property(r => r.Name).HasColumnName("restaurant_name");

            modelBuilder.Entity<RestaurantRow>()
                        .Property(r => r.Address.State).HasColumnName("state");

            modelBuilder.Entity<RestaurantRow>()
                        .Property(r => r.Address.Street).HasColumnName("Street");

            modelBuilder.Entity<RestaurantRow>()
                        .Property(r => r.Address.City).HasColumnName("City");

            modelBuilder.Entity<RestaurantRow>()
                        .Property(r => r.Address.Country).HasColumnName("Country");

            modelBuilder.Entity<Review>()
                .ToTable("reviews");

            base.OnModelCreating(modelBuilder);
        }
    }
}