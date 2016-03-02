using System;

namespace RepositoryTest
{

    public class Restaurant : IEntity
    {
        public int ID { get; set; }

        public string Name { get; set; }

        public Address Address { get; set; }

        public DateTime AddDate { get; set; }
    }
}
