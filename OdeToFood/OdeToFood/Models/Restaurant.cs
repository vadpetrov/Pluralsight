using System.Collections.Generic;
namespace OdeToFood.Models
{
    public class Restaurant
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string StreetAddress { get; set; }
        public string City { get; set; }
        public string State { get; set; }
        public string Country { get; set; }
        public string ImageUrl { get; set; }
    }
    /*
    public class RestaurantRow
    {
        public int ID { get; set; }
        public string Name { get; set; }
        public string ChefsName { get; set; }
        public Address Address { get; set; }
    }
    */
    public class RestaurantRow
    {
        public virtual int ID { get; set; }
        public virtual string Name { get; set; }
        public virtual Address Address { get; set; }
        public virtual ICollection<Review> Reviews { get; set; }
    }


    public class Deal
    {
        public int ID { get; set; }
        public string  Name { get; set; }
        public Address Address { get; set; }
    }
}