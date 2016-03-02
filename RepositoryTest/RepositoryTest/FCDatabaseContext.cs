using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RepositoryTest
{
    class FCDatabaseContext: IDisposable
    {
        private ProductRepository _products;
        private RestaurantRepository _restaurants;
        private ReviewRepository _reviews;

        private SqlConnection _connection;

        public FCDatabaseContext(SqlConnection connection)
        {
            _connection = connection;
            _products = new ProductRepository(connection);
            _restaurants = new RestaurantRepository(connection);
            _reviews = new ReviewRepository(connection);
        }
        public IRepository<Product> Products
        {
            get
            {
                return _products;
            }
        }
        public IRepository<Restaurant> Restaurants
        {
            get
            {
                return _restaurants;
            }
        }
        public ReviewRepository Reviews
        {
            get
            {
                return _reviews;
            }
        }

        #region IDisposable Support
        private bool disposedValue = false;        

        protected virtual void Dispose(bool disposing)
        {
            if (!disposedValue)
            {
                if (disposing)
                {
                    if (_connection != null) _connection.Dispose();
                }
                disposedValue = true;
            }
        }
        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }
        #endregion
    }
}
