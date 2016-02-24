﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Data.Entity;
using NewWebAPI.Models;

namespace NewWebAPI.Queries
{
    public static class RCDBQueries
    {
        public static IQueryable<Restaurant> GetAllRestaurants(this IDbContext repo)
        {
            return repo.Restaurants;
        }
        public static IQueryable<Restaurant> GetAllRestaurantsWithReviewes(this IDbContext repo)
        {
            return repo.Restaurants.Include("Reviews");
        }
        public static Restaurant GetRestaurant(this IDbContext repo, int id)
        {
            return repo.Restaurants
                       .Include("Reviews")
                       .Where(r => r.ID == id)
                       .FirstOrDefault();
        }

        public static IQueryable<Review> GetReviewsForRestaurant(this IDbContext repo, int restaurantid)
        {
            return repo.Reviews
                       .Include("Restaurant")
                       .Where(r => r.RestaurantID == restaurantid);
        }

        public static Review GetReview(this IDbContext repo, int id)
        {
            return repo.Reviews
                       .Include("Restaurant")
                       .Where(r => r.ID == id)
                       .FirstOrDefault();
        }

        public static IQueryable<Order> GetOrders(this IDbContext repo, string userName)
        {
            return repo.Orders
                       .Include("Items")
                       .Include("Items.Product")
                       .Include("Restaurant")
                       .Include("Client")
                       //.OrderByDescending(o => o.OrderDate)
                       .Where(c => c.Client.UserName == userName);
            //.Include("Restaurant.Reviews");
        }
        public static IQueryable<Order> GetOrders(this IDbContext repo, string userName, DateTime orderDate)
        {
            return repo.Orders
                       .Include("Items")
                       .Include("Items.Product")
                       .Include("Restaurant")
                       .Include("Client")
                       .Where(c => c.Client.UserName == userName  && c.OrderDate == orderDate);
         
        }

        public static IQueryable<Order> GetOrders(this IDbContext repo, int userId)
        {
            return repo.Orders
                       .Include("Items")
                       .Include("Items.Product")
                       .Include("Restaurant")
                       .Include("Client")
                       .Where(c => c.Client.ID == userId);
            //.Include("Restaurant.Reviews");
        }
        public static IQueryable<Order> GetOrders(this IDbContext repo, int userId, DateTime orderDate)
        {
            return repo.Orders
                       .Include("Items")
                       .Include("Items.Product")
                       .Include("Restaurant")
                       .Include("Client")
                       .Where(c => c.Client.ID == userId && c.OrderDate == orderDate);
        }
        public static Order GetOrder(this IDbContext repo, int orderId)
        {
            return repo.Orders
                       .Include("Items")
                       .Include("Items.Product")
                       .Include("Restaurant")
                       .Include("Client")
                       .Where(c => c.ID == orderId)
                       .SingleOrDefault();
        }

        //public static IQueryable<Restaurant> GetAllRestaurants(this IQueryable<Restaurant> restaurants)
        //{
        //    return restaurants
        //}
    }
}