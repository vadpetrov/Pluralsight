using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RepositoryTest
{
    public class ReviewRepository : IRepository<Review>
    {
        private static SqlConnection _connection;     
        public ReviewRepository(SqlConnection connection)
        {
            _connection = connection;
            if (_connection.State != ConnectionState.Open) _connection.Open();
        }

        public IEnumerable<Review> GetAll()
        {
            var results = new List<Review>();

            using (var command = _connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = "select * from reviews";
                command.CommandTimeout = 0;
                
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var model = CreateModel(reader);
                        results.Add(model);
                    }
                }               
            }
            return results;
        }

        public Review CreateModel(SqlDataReader reader)
        {
            return new Review()
            {
                ID = (int)reader["id"],
                RestaurantID = (int)reader["RestaurantID"],
                Rating = (int)reader["rating"],
                Body = reader["body"].ToString(),
                DiningDate = (DateTime)reader["DiningDate"],
                Created = (DateTime)reader["created"]
            };
        }

        public Review FindById(int Id)
        {
            Review result = null;


            using (var command = _connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"select * from reviews where id = @id";
                command.Parameters.Add(new SqlParameter("@id", Id));                
                command.CommandTimeout = 0;

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result = CreateModel(reader);
                        break;
                    }
                }
            }

            return result;
        }

        public Review Add(Review review)
        {
            Review result = null;

            using (var command = _connection.CreateCommand())
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("insert into reviews (RestaurantID,Rating,Body,DiningData) ");
                sb.Append("output inserted.* ");
                sb.Append("values (@restaurantid,@rating, @body, @diningdate)");

                command.CommandTimeout = 0;
                command.CommandType = CommandType.Text;
                command.CommandText = sb.ToString();

                command.Parameters.Add("@restaurantid", SqlDbType.Int).Value = review.RestaurantID;
                command.Parameters.Add("@rating", SqlDbType.Int).Value = review.Rating;
                command.Parameters.Add("@diningdate", SqlDbType.DateTime).Value = review.DiningDate;
                command.Parameters.Add("@body", SqlDbType.VarChar).Value = (object)review.Body ?? DBNull.Value;

                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result = CreateModel(reader);
                        break;
                    }
                }

            }            
            return result;
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

