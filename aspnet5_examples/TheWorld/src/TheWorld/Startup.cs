using AutoMapper;
using Microsoft.AspNet.Authentication.Cookies;
using Microsoft.AspNet.Builder;
using Microsoft.AspNet.Hosting;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.PlatformAbstractions;
using Newtonsoft.Json.Serialization;
using System;
using System.Net;
using System.Security.Cryptography;
using System.Threading.Tasks;
using TheWorld.Data;
using TheWorld.Factories;
using TheWorld.Models;
using TheWorld.Services;
using TheWorld.ViewModels;
using System.IdentityModel.Tokens;
using Microsoft.AspNet.Authorization;
using Microsoft.AspNet.Authentication.JwtBearer;
using Microsoft.AspNet.Diagnostics;
using Microsoft.AspNet.Http;
using Newtonsoft.Json;

namespace TheWorld
{
    public class Startup
    {
        /*
        const string TokenAudience = "ExampleAudience";
        const string TokenIssuer = "ExampleIssuer";
        private RsaSecurityKey key;
        private TokenAuthOptions tokenOptions;
        */

        public static IConfigurationRoot Configuration;

        public Startup(IApplicationEnvironment appEnv)
        {
            var buider = new ConfigurationBuilder()
                .SetBasePath(appEnv.ApplicationBasePath)
                .AddJsonFile("config.json")
                .AddEnvironmentVariables();

            Configuration = buider.Build();
        }

        // This method gets called by the runtime. Use this method to add services to the container.
        // For more information on how to configure your application, visit http://go.microsoft.com/fwlink/?LinkID=398940
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc(config =>
            {
//#if !DEBUG
//              config.Filters.Add(new RequireHttpsAttribute());
//#endif
            })
            .AddJsonOptions(opt =>
            {
                opt.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
            });

            /*
            services.AddMvc()
                .AddJsonOptions(opt =>
                {
                    opt.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
                });
            */
            //security https://vimeo.com/43603474
            //http://www.asp.net/web-api/overview/security/enabling-cross-origin-requests-in-web-api
            //https://neelbhatt40.wordpress.com/2015/09/10/what-is-cors-and-how-to-enable-it-in-asp-net-5vnext/
            //http://www.asp.net/web-api/overview/security/enabling-cross-origin-requests-in-web-api#create-client
            services.AddCors(options =>
                {
                    options.AddPolicy("AllowAll", 
                     p => //p.AllowAnyOrigin()
                    p.WithOrigins("http://localhost:8010")
                    .AllowAnyHeader()
                    //.AllowAnyMethod()
                    .WithMethods("GET", "POST")
                    .AllowCredentials());
                });


            /*  
          var policy = new CorsPolicy();
          policy.Headers.Add("*");
          policy.Methods.Add("*");
          policy.Origins.Add("*");
          policy.SupportsCredentials = true;

          services.conf .ConfigureCors(x => x.AddPolicy("mypolicy", policy));
          */

            //http://www.asp.net/web-api/overview/security/individual-accounts-in-web-api
            //http://leastprivilege.com/2015/10/12/the-state-of-security-in-asp-net-5-and-mvc-6-authorization/
            //http://stackoverflow.com/questions/30768015/configure-the-authorization-server-endpoint
            //https://github.com/auth0/auth0-aspnet5
            //token test 1
            //services.AddAuthentication();
            //services.AddCaching();


            //token 2
            //http://stackoverflow.com/questions/29048122/token-based-authentication-in-asp-net-5-vnext/29698502#29698502
            //https://github.com/mrsheepuk/ASPNETSelfCreatedTokenAuthExample/tree/master/src/TokenAuthExampleWebApplication
            // *** CHANGE THIS FOR PRODUCTION USE ***
            // Here, we're generating a random key to sign tokens - obviously this means
            // that each time the app is started the key will change, and multiple servers 
            // all have different keys. This should be changed to load a key from a file 
            // securely delivered to your application, controlled by configuration.
            //
            // See the RSAKeyService.GetKeyParameters method for an example of loading from
            // a JSON file.

            /*
            //RSAKeyService.GenerateKeyAndSave("key.json");
            //RSAParameters keyParams = RSAKeyService.GetRandomKey();

            RSAParameters keyParams = RSAKeyService.GetKeyParameters("key.json");
            
            // Create the key, and a set of token options to record signing credentials 
            // using that key, along with the other parameters we will need in the 
            // token controlller.

            key = new RsaSecurityKey(keyParams);
            tokenOptions = new TokenAuthOptions()
            {
                Audience = TokenAudience,
                Issuer = TokenIssuer,
                SigningCredentials = new SigningCredentials(key, SecurityAlgorithms.RsaSha256Signature)
            };

            // Save the token options into an instance so they're accessible to the 
            // controller.
            services.AddInstance(tokenOptions);

            // Enable the use of an [Authorize("Bearer")] attribute on methods and classes to protect.
            services.AddAuthorization(auth =>
            {
                auth.AddPolicy("Bearer", new AuthorizationPolicyBuilder()
                    .AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme‌​)
                    .RequireAuthenticatedUser().Build());
            });
            */

            services.AddIdentity<WorldUser, IdentityRole>(config =>
            {
                config.User.RequireUniqueEmail = true;
                config.Password.RequiredLength = 6;
                config.Password.RequireNonLetterOrDigit = false;
                config.Password.RequireLowercase = false;
                config.Password.RequireUppercase = false;
                config.Cookies.ApplicationCookie.LoginPath = "/Auth/Login";
                config.Cookies.ApplicationCookie.Events = new CookieAuthenticationEvents()
                {
                    OnRedirectToLogin = ctx =>
                    {
                        //await
                        if (ctx.Request.Path.StartsWithSegments("/api")                             
                            && (ctx.Response.StatusCode == (int)HttpStatusCode.OK || ctx.Response.StatusCode == (int)HttpStatusCode.Unauthorized))
                        {
                            ctx.Response.StatusCode = (int)HttpStatusCode.Unauthorized;
                        }
                        else
                        {
                            ctx.Response.Redirect(ctx.RedirectUri);//default behaviour
                        }                        
                        return Task.FromResult(0);
                    }
                };
            })
            .AddEntityFrameworkStores<WorldContext>();

            services.AddLogging();

            services.AddEntityFramework()
                .AddSqlServer()                
                .AddDbContext<WorldContext>();


            //Scoped - Once per request sicle
            services.AddScoped<CoordService>();

            services.AddTransient<WorldContextSeedData>();
            //services.AddInstance(....)
            //services.AddSingleton<WorldContextSeedData>();
            //services.AddScoped<WorldContextSeedData>();


            services.AddScoped<IWorldRepository, WorldRepository>();
            services.AddScoped<IModelFactory, WorldModelFactory>();

#if DEBUG
            services.AddScoped<IMailService, DebugMailService>();
#else
            //just for test
            services.AddScoped<IMailService, DebugMailService>();
            //services.AddScoped<IMailService, MailService>();
#endif
        }


        //Publish using DNU commands - without RUNTIMES
        //TheWorld\src\TheWorld>dnu publish -o D:\Test\TheWorldDnu

        //Publish using DNU commands - with specific RUNTIMES
        //TheWorld\src\TheWorld>dnu publish -o D:\Test\TheWorldDnu --runtime dnx-clr-win-x64.1.0.0-rc1-update1

        //use Postman app for webapi testing getpostman.com
        //http://www.johnpapa.net/get-up-and-running-with-node-and-visual-studio/
        //http://maxtoroq.github.io/2014/02/using-razor-and-xslt-in-same-project.html
        //https://docs.asp.net/en/latest/fundamentals/static-files.html
        //https://azure.microsoft.com/en-us/documentation/articles/web-sites-create-web-app-using-vscode/
        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        /// public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)       

        //public void Configure(IApplicationBuilder app)
        //public void Configure(IApplicationBuilder app, WorldContextSeedData seeder, ILoggerFactory loggerFactory, IHostingEnvironment env)
        public async void Configure(IApplicationBuilder app, WorldContextSeedData seeder, ILoggerFactory loggerFactory, IHostingEnvironment env)
        {

            //token test 1
            //"Microsoft.AspNet.Server.WebListener": "1.0.0-rc1-final",
            //"Microsoft.AspNet.Authentication.JwtBearer": "1.0.0-rc1-final",
            //"AspNet.Security.OpenIdConnect.Server": "1.0.0-beta4"

            // Add a new middleware validating access tokens issued by the server.
            //app.UseJwtBearerAuthentication(options =>
            //{                
            //    options.AutomaticAuthenticate = true;
            //    options.Audience = "resource_server_1";
            //    options.Authority = "http://localhost:50000/";
            //    options.RequireHttpsMetadata = false;
            //});

            //token test 1
            // Add a new middleware issuing tokens.
            //app.UseOpenIdConnectServer(options =>
            //{
            //    options.AllowInsecureHttp = true;
            //    options.AuthorizationEndpointPath = PathString.Empty;
            //    options.TokenEndpointPath = "/connect/token";
            //    options.Provider = new AuthorizationProvider();
            //});

            //token 2 begin
            // Register a simple error handler to catch token expiries and change them to a 401, 
            // and return all other errors as a 500. This should almost certainly be improved for
            // a real application.
            /*
            app.UseIISPlatformHandler();
            app.UseExceptionHandler(appBuilder =>
            {
                appBuilder.Use(async (context, next) =>
                {
                    var error = context.Features[typeof(IExceptionHandlerFeature)] as IExceptionHandlerFeature;
                    // This should be much more intelligent - at the moment only expired 
                    // security tokens are caught - might be worth checking other possible 
                    // exceptions such as an invalid signature.
                    if (error != null && error.Error is SecurityTokenExpiredException)
                    {
                        context.Response.StatusCode = 401;
                        // What you choose to return here is up to you, in this case a simple 
                        // bit of JSON to say you're no longer authenticated.
                        context.Response.ContentType = "application/json";
                        await context.Response.WriteAsync(
                            JsonConvert.SerializeObject(
                                new { authenticated = false, tokenExpired = true }));
                    }
                    else if (error != null && error.Error != null)
                    {
                        context.Response.StatusCode = 500;
                        context.Response.ContentType = "application/json";
                        // TODO: Shouldn't pass the exception message straight out, change this.
                        await context.Response.WriteAsync(
                            JsonConvert.SerializeObject
                            (new { success = false, error = error.Error.Message }));
                    }
                    // We're not trying to handle anything else so just let the default 
                    // handler handle.
                    else await next();
                });
            });

            app.UseJwtBearerAuthentication(options =>
            {
                // Basic settings - signing key to validate with, audience and issuer.
                options.TokenValidationParameters.IssuerSigningKey = key;
                options.TokenValidationParameters.ValidAudience = tokenOptions.Audience;
                options.TokenValidationParameters.ValidIssuer = tokenOptions.Issuer;

                // When receiving a token, check that we've signed it.
                options.TokenValidationParameters.ValidateSignature = true;

                // When receiving a token, check that it is still valid.
                options.TokenValidationParameters.ValidateLifetime = true;

                // This defines the maximum allowable clock skew - i.e. provides a tolerance on the token expiry time 
                // when validating the lifetime. As we're creating the tokens locally and validating them on the same 
                // machines which should have synchronised time, this can be set to zero. Where external tokens are
                // used, some leeway here could be useful.
                options.TokenValidationParameters.ClockSkew = TimeSpan.FromMinutes(0);                
            });
            //token 2 end
            */
            
            if (env.IsDevelopment())
            {
                //loggerFactory.AddProvider(new CustomLogger());
                loggerFactory.AddDebug(LogLevel.Information);
                app.UseDeveloperExceptionPage();
                app.UseRuntimeInfoPage();
            }
            else
            {                
                loggerFactory.AddDebug(LogLevel.Error);
                //app.UseExceptionHandler("App/Error");
                app.UseDeveloperExceptionPage();
            }            

            //app.UseDefaultFiles();
            app.UseStaticFiles();

            app.UseIdentity();

            Mapper.Initialize(config=>
            {
                config.CreateMap<Trip, TripViewModel>().ReverseMap();
                config.CreateMap<Stop, StopViewModel>().ReverseMap();
            });

            /*
#if DEBUG
            if (env.IsDevelopment())
            {
                //app.UseExceptionHandler(...)
                app.UseDeveloperExceptionPage();

                // Add the runtime information page that can be used by developers
                // to see what packages are used by the application
                // default path is: /runtimeinfo
                app.UseRuntimeInfoPage();
            }
#else
         
#endif
            */

            app.UseMvc(config =>
            {
                config.MapRoute(
                  name: "Default",
                  template: "{controller}/{action}/{id?}",
                  defaults: new { controller = "App", action = "Index" }
                  );

                //config.MapRoute(
                //  name: "App",
                //  template: "App/{action}/{id?}",
                //  defaults: new {controller="app", action = "Index" }
                //  );

            });

            /*
            app.Run(async (context) =>
            {
                //await context.Response.WriteAsync("Hello World!");
                await context.Response.WriteAsync($"Hello World: {context.Request.Path}");
            });
            */

            //seeder.EnsureSeedData();
            await seeder.EnsureSeedDataAsync();
        }

        // Entry point for the application.
        public static void Main(string[] args) => WebApplication.Run<Startup>(args);
    }

    class CustomLogger : ILoggerProvider
    {
        //private static ILogger _logger;
        public ILogger CreateLogger(string categoryName)
        {
            //if(_logger == null) _logger = new MyLogger();
            // return _logger;
            return new MyLogger();
        }

        public void Dispose()
        {            
            GC.Collect();
            //GC.WaitForPendingFinalizers();
            GC.SuppressFinalize(this);
        }

        private class MyLogger : ILogger
        {
            public bool IsEnabled(LogLevel logLevel)
            {
                return true;
            }

            public void Log(LogLevel logLevel, int eventId, object state, Exception exception, Func<object, Exception, string> formatter)
            {
                //File.AppendAllText(@"C:\temp\log.txt", formatter(state, exception));
                if (logLevel == LogLevel.Error)
                {
                    Console.WriteLine(formatter(state, exception));
                }
                else
                {
                    var s = state == null ? "" : state.ToString();
                    Console.WriteLine($"Custom LG -- EvnetID: {eventId.ToString()} : {s}");
                }
            }

            public IDisposable BeginScopeImpl(object state)
            {
                return null;
            }
        }
    }
}
