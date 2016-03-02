using System;

namespace RepositoryTest
{
    public partial class Product:IEntity
    {
        public int ID { get; set; }

        public string Name { get; set; }

        public string Description { get; set; }

        public decimal Price { get; set; }

        public DateTime AddDate { get; set; }
    }
}
