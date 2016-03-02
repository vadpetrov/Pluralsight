using System.Security.Principal;
namespace NewWebAPI.Services
{
    public interface IRCIdentityService
    {  
        string CurrentUserName { get; }
        int CurrentUserID { get; }
    }
}