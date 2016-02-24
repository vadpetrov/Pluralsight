using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace NewWebAPI.Services
{
    public class RCIdentityService : IRCIdentityService
    {
        public string CurrentUserName
        {
            get { return "vpetrov"; }
        }
        public int CurrentUserID
        {
            get { return 10; }
        }
    }
}