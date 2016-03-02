using System;

namespace RepositoryTest
{
    public partial class Review : IEntity
    {
        public int ID { get; set; }

        public int RestaurantID { get; set; }

        public int Rating { get; set; }
                
        public string Body { get; set; }

        public DateTime DiningDate { get; set; }

        public DateTime Created { get; set; }

        public virtual Restaurant Restaurant { get; set; }
    }
}
