#if DEBUG
#define DISABLE_SECURITY
#endif

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.Controllers;
using System.Web.Http.Filters;
using System.Net;
using System.Net.Http;
using WebMatrix.WebData;
using System.Security.Principal;
using System.Threading;
using System.Text;

namespace NewWebAPI.Filters
{
    public class RCAuthorizeAttribute: AuthorizationFilterAttribute
    {
        public override void OnAuthorization(HttpActionContext actionContext)
        {
#if !DISABLE_SECURITY
            if (Thread.CurrentPrincipal.Identity.IsAuthenticated)
            {
                return;
            }



            var authHeader = actionContext.Request.Headers.Authorization;

            if (authHeader != null)
            {
                if (authHeader.Scheme.Equals("basic", StringComparison.OrdinalIgnoreCase) &&
                    !string.IsNullOrWhiteSpace(authHeader.Parameter))
                {
                    var rawCredentials = authHeader.Parameter;
                    var encoding = Encoding.GetEncoding("iso-8859-1");
                    var credentials = encoding.GetString(Convert.FromBase64String(rawCredentials));
                    var split = credentials.Split(':');
                    var username = split[0];
                    var password = split[1];

                    //https://www.base64encode.org/
                    //encoded credentials
                    /*
                     Fiddler Request
                     User-Agent: Fiddler
                     Host: localhost:18279
                     Authorization: Basic dnA6MTIzNDU2
                     

                    */
                    if (!WebSecurity.Initialized)
                    {
                        try
                        {
                            //WebSecurity.InitializeDatabaseConnection("RCDB", "Users", "UserId", "UserName", autoCreateTables: true);
                            WebSecurity.InitializeDatabaseConnection("DefaultConnection", "UserProfile", "UserId", "UserName", autoCreateTables: true);
                            
                            if (WebSecurity.Login(username, password))
                            {
                                var principal = new GenericPrincipal(new GenericIdentity(username), null);
                                Thread.CurrentPrincipal = principal;
                                return;
                            }
                        }
                        catch (Exception ex)
                        {
                            throw ex;
                        }
                        
                    }
                }
            }

            HandleUnauthorized(actionContext);
            //base.OnAuthorization(actionContext);
#endif
        }

        private void HandleUnauthorized(HttpActionContext actionContext )
        {
            actionContext.Response = actionContext.Request.CreateResponse(HttpStatusCode.Unauthorized);
            actionContext.Response.Headers.Add("WWW-Authenticate",
                "Basic Scheme='NewWebApi' location='http://localhost:24460/account/logon'");            
        }
    }
}