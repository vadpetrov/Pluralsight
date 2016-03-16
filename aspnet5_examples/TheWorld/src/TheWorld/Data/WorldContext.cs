using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.Data.Entity;
using TheWorld.Models;

namespace TheWorld.Data
{
    public class WorldContext : IdentityDbContext<WorldUser>  //DbContext
    {
        public DbSet<Trip> Trips { get; set; }
        public DbSet<Stop> Stops { get; set; }
        
        public WorldContext()
        {
            Database.EnsureCreated();
        }

        //Command prompt EF frist migration commands
        //1. run:  dnx ef
        //2. run: ...\src\TheWorld>dnx ef migrations add InitialDatabase
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var connString = Startup.Configuration["Data:WorldContextConnection:ConnectionString"];
            optionsBuilder.UseSqlServer(connString);
                        
            base.OnConfiguring(optionsBuilder);
        }
    }
}
