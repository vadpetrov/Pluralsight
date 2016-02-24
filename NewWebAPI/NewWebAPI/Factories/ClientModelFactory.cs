using NewWebAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Factories
{
    public class ClientModelFactory
    {
        public ClientModel Create(Client client)
        {
            return new ClientModel()
            {
                ID = client.ID,
                UserName = client.UserName,
                FirstName = client.FirstName,
                LastName = client.LastName
            };
        }
    }
}