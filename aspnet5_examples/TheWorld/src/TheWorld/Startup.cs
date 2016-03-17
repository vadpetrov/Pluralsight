using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNet.Builder;
using Microsoft.AspNet.Hosting;
using Microsoft.AspNet.Http;
using Microsoft.Extensions.DependencyInjection;
using TheWorld.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.PlatformAbstractions;
using TheWorld.Data;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Serialization;
using AutoMapper;
using TheWorld.Models;
using TheWorld.ViewModels;
using TheWorld.Factories;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.EntityFramework;
using Microsoft.AspNet.Mvc;
using Microsoft.AspNet.Authentication.Cookies;
using System.Net;

namespace TheWorld
{
    public class Startup
    {
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
                        if (ctx.Request.Path.StartsWithSegments("/api") &&
                            ctx.Response.StatusCode == (int)HttpStatusCode.OK)
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
