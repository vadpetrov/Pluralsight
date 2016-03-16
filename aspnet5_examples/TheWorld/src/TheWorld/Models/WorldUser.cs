using System;
using Microsoft.AspNet.Identity.EntityFramework;

namespace TheWorld.Models
{
    /// <summary>
    /// Command: dnx ef migrations  add IndentityEntities
    /// </summary>
    public class WorldUser : IdentityUser
    {
        public DateTime FirstTrip { get; set; }
    }
}