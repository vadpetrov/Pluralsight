using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using System.Data.Entity;
using System.Data.Entity.Infrastructure;
using System.Data.Entity.ModelConfiguration.Configuration;
using System.Linq;
using System.Web;

namespace NewWebAPI.Models
{
    public class RCDB : DbContext, IDbContext
    {
        public DbSet<Restaurant> Restaurants { get; set; }
        public DbSet<Review> Reviews { get; set; }
        public DbSet<Order> Orders { get; set; }
        public DbSet<Client> Clients { get; set; }
        public DbSet<OrderItem> OrderItems { get; set; }
        public DbSet<Product> Products { get; set; }
        
        public RCDB()//:base("RCDB")
        {
            this.Configuration.LazyLoadingEnabled = false; //default true
            this.Configuration.ProxyCreationEnabled = false;
        }


        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Restaurant>().ToTable("Restaurants");
            modelBuilder.Entity<Review>().ToTable("Reviews");
            modelBuilder.Entity<OrderItem>().ToTable("OrderItems");

            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Street).HasColumnName("Street");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.City).HasColumnName("City");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Country).HasColumnName("Country");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.State).HasColumnName("State");
          
            /*
            //same as [DatabaseGenerated(DatabaseGeneratedOption.Computed)]
            modelBuilder.Entity<Product>()
                        .Property(p => p.AddDate)
                        .HasDatabaseGeneratedOption(DatabaseGeneratedOption.Computed);
            */

            /*
            //same as [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
            modelBuilder.Entity<Product>()
                        .Property(p => p.ID)
                        .HasDatabaseGeneratedOption(DatabaseGeneratedOption.Identity);
            */


            
            /* complex key
            modelBuilder.Entity<OrderItem>()
                        .HasKey(k => new
                            {
                                k.OrderID,
                                k.ItemID
                            });
             */
            //http://stackoverflow.com/questions/15822781/entity-framework-code-first-map-entities-to-different-tables
            
            //link vitrual property to table columnt with different name
            modelBuilder.Entity<OrderItem>()
                .HasRequired(i=>i.Product)
                .WithMany()
                .HasForeignKey(i=>i.ItemID)
                .WillCascadeOnDelete(false);


            


            /*
            modelBuilder.Entity<OrderItem>()
                        .Map(m =>
                            {
                                m.Properties(p => new
                                    {
                                        p.OrderID,
                                        p.ItemID
                                    });
                                m.ToTable("OrderItems");
                            })
                        .Map(m =>
                            {
                                m.Properties(p => new
                                    {
                                        p.Product.ID,
                                        p.Product.Name,
                                        p.Product.Price
                                    });
                                m.ToTable("Product");
                            });
            */

            //modelBuilder.Entity<OrderItem>()
            //            .Property(o => o.OrderID).HasColumnName("OrderID");
            //modelBuilder.Entity<OrderItem>()
            //            .Property(o => o.ItemID).HasColumnName("ItemID");
            
            
            
            
            base.OnModelCreating(modelBuilder);
        }

        //public virtual new DbEntityEntry<T> Entry<T>(T entity) where T : class
        //{
        //    return base.Entry(entity);
        //}

        IQueryable<Restaurant> IDbContext.Restaurants
        {
            get { return Restaurants; }
        }

        IQueryable<Review> IDbContext.Reviews
        {
            get { return Reviews; }
        }

        IQueryable<Order> IDbContext.Orders
        {
            get { return Orders; }
        }
        IQueryable<Client> IDbContext.Clients
        {
            get { return Clients; }
        }
        IQueryable<OrderItem> IDbContext.OrderItems
        {
            get { return OrderItems; }
        }
        IQueryable<Product> IDbContext.Products
        {
            get { return Products; }
        }



        public T Attach<T>(T entity) where T : class
        {
            var entry = Entry(entity);
            entry.State = EntityState.Modified;
            //Entry(entity).CurrentValues.SetValues(entity);
            return entity;
        }

        public T Add<T>(T entity) where T : class
        {
            return Set<T>().Add(entity);
        }

        public T Delete<T>(T entity) where T : class
        {
            return Set<T>().Remove(entity);
        }
    }

    public class RCDB1 : DbContext
    {
        public DbSet<Restaurant> Restaurants { get; set; }
        public DbSet<Review> Reviews { get; set; }

        public RCDB1(string connectionStringName):base(connectionStringName)
        {
            //base.Database.Connection.ConnectionString
        }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            //modelBuilder.Entity<Restaurant>().ToTable("Restaurants");
            //modelBuilder.Entity<Review>().ToTable("Reviews");

            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Street).HasColumnName("Street");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.City).HasColumnName("City");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.Country).HasColumnName("Country");
            modelBuilder.Entity<Restaurant>()
                        .Property(r => r.Address.State).HasColumnName("State");

            base.OnModelCreating(modelBuilder);
        }
    }
}