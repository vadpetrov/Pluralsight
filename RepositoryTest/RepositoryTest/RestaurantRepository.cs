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
    public class RestaurantRepository : IRepository<Restaurant>
    {
        private static SqlConnection _connection;     
        public RestaurantRepository(SqlConnection connection)
        {
            _connection = connection;
            if (_connection.State != ConnectionState.Open) _connection.Open();
        }

        public IEnumerable<Restaurant> GetAll()
        {
            var results = new List<Restaurant>();

            using (var command = _connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = "select * from restaurants";
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

        public Restaurant CreateModel(SqlDataReader reader)
        {
            return new Restaurant()
            {
                ID = (int)reader["id"],
                Name = reader["name"].ToString(),
                Address = new Address()
                {
                    City = reader["City"].ToString(),
                    State = reader["state"].ToString(),
                    Country = reader["country"].ToString(),
                    Street = reader["street"].ToString(),
                },
                AddDate = (DateTime)reader["adddate"]
            };
        }

        public Restaurant FindById(int Id)
        {
            Restaurant result = null;


            using (var command = _connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"select * from restaurant where id = @id";
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

        public Restaurant Add(Restaurant restaurant)
        {
            Restaurant result = null;

            using (var command = _connection.CreateCommand())
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("insert into restaurants (Name,Street,City,Country,State) ");
                sb.Append("output inserted.* ");
                sb.Append("values (@name,@street,@city,@country,@state)");

                command.CommandTimeout = 0;
                command.CommandType = CommandType.Text;
                command.CommandText = sb.ToString();
                command.Parameters.Add("@name", SqlDbType.VarChar).Value = restaurant.Name;
                command.Parameters.Add("@state", SqlDbType.VarChar).Value = (object)restaurant.Address.State ?? DBNull.Value;
                command.Parameters.Add("@city", SqlDbType.VarChar).Value = (object)restaurant.Address.City ?? DBNull.Value;
                command.Parameters.Add("@country", SqlDbType.VarChar).Value = (object)restaurant.Address.Country ?? DBNull.Value;
                command.Parameters.Add("@street", SqlDbType.VarChar).Value = (object)restaurant.Address.Street ?? DBNull.Value;
                
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

