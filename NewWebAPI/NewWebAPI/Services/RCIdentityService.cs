using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Principal;
using System.Threading;
using System.Web;

namespace NewWebAPI.Services
{
    public class RCIdentityService : IRCIdentityService
    {
        public string CurrentUserName
        {
            get
            {
#if DEBUG
                return "vp";
#else
            return CurrentUser.Name;
#endif
            }
        }

        public int CurrentUserID
        {
            //fake
            get
            {
#if DEBUG
                return 10;
#else

                int id = 0;
                switch (CurrentUser.Name)
                {
                    case "vp":
                        id = 10;
                        break;
                    case "ml":
                        id = 20;
                        break;
                    default:
                        id = -1;
                        break;
                }
                return id;
#endif
            }
        }

        private IIdentity CurrentUser
        {
            get { return Thread.CurrentPrincipal.Identity; }
        }
    }
}