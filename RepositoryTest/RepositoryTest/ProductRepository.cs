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
    public class ProductRepository : IRepository<Product>
    {
        private static SqlConnection _connection;     
        public ProductRepository(SqlConnection connection)
        {
            _connection = connection;
            if (_connection.State != ConnectionState.Open) _connection.Open();
        }

        public IEnumerable<Product> GetAll()
        {
            var results = new List<Product>();

            using (var command = _connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = "select * from products";
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

        public Product CreateModel(SqlDataReader reader)
        {
            return new Product()
            {
                ID = (int)reader["id"],
                Name = reader["name"].ToString(),
                Description = reader["description"].ToString(),
                Price = (decimal)reader["price"],
                AddDate = (DateTime)reader["adddate"]
            };
        }

        public Product FindById(int Id)
        {
            Product result = null;

            
            using (var command = _connection.CreateCommand())
            {
                command.CommandType = CommandType.Text;
                command.CommandText = @"select * from products where id = @id";
                command.Parameters.Add(new SqlParameter("@id", Id));
                //command.Parameters.AddWithValue("@id", Id);                
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

        public Product Add(Product product)
        {
            //int productId;
            Product result = null;            

            using (var command = _connection.CreateCommand())
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("insert into products (Name,Description,Price) ");
                sb.Append("output inserted.* ");
                sb.Append("values (@name,@description,@price)");

                command.CommandTimeout = 0;
                command.CommandType = CommandType.Text;
                command.CommandText = sb.ToString();
                command.Parameters.Add("@name", SqlDbType.VarChar).Value = product.Name;
                command.Parameters.Add("@description", SqlDbType.VarChar).Value = (object)product.Description ?? DBNull.Value;
                command.Parameters.Add("@price", SqlDbType.Decimal).Value = product.Price;
                
                //productId = (int)command.ExecuteScalar();
                using (var reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        result = CreateModel(reader);
                        break;
                    }
                }
                
            }
            //var result = FindById(1);
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

    /*
    public abstract class BaseRepository
    {
        private IDbConnectionFactory _connectionFactory;

        public BaseRepository(IDbConnectionFactory connectionFactory)
        {
            _connectionFactory = connectionFactory;
        }

        protected IDbConnectionFactory ConnectionFactory
        {
            get { return _connectionFactory; }
        }
    }
    */
    public class DBConnectionFactory : IDbConnectionFactory
    {
        private string _connectionString;

        public DBConnectionFactory()
        {
            _connectionString = ConfigurationManager.ConnectionStrings["RCDB"].ConnectionString;
        }

        public string ConnectionString
        {
            get
            {
                return _connectionString;
            }
        }

        public SqlConnection Create()
        {
            return new SqlConnection(_connectionString);
        }
    }

    public interface IDbConnectionFactory
    {
        string ConnectionString { get; }
        SqlConnection Create();
    }
}

