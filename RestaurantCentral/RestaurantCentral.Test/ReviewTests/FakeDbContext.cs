using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections.ObjectModel;
using RestaurantCentral.Models;

namespace RestaurantCentral.Test.ReviewTests
{
    class FakeDbContext : IDbContext
    {

        public IQueryable<Restaurant> Restaurants
        {
            get { return _map.Get<Restaurant>().AsQueryable(); }
            set { _map.Use<Restaurant>(value); }
        }

        public IQueryable<Review> Reviews
        {
            get { return _map.Get<Review>().AsQueryable(); }
            set { _map.Use<Review>(value); }
        }

        public int SaveChanges()
        {
            ChangesSaved = true;
            return 0;
        }

        public bool ChangesSaved { get; set; }

        public T Attach<T>(T entity) where T: class
        {
            _map.Get<T>().Add(entity);            
            return entity;
        }

        public T Add<T>(T entity) where T : class
        {
            _map.Get<T>().Add(entity);            
            return entity;
        }

        public T Delete<T>(T entity) where T : class
        {
            _map.Get<T>().Remove(entity);            
            return entity;
        }

        SetMap _map = new SetMap();   

        class SetMap : KeyedCollection<Type, object>
        {
            public HashSet<T> Use<T>(IEnumerable<T> sourceData)
            {
                var set = new HashSet<T>(sourceData);
                if(Contains(typeof(T)))
                {
                    Remove(typeof(T));
                }                
                Add(set);                
                return set;
            }

            public HashSet<T> Get<T>()
            {
                return this[typeof(T)] as HashSet<T>;
            }

            protected override Type GetKeyForItem(object item)
            {
                return item.GetType().GetGenericArguments().First();
            }
        }
    }
}
