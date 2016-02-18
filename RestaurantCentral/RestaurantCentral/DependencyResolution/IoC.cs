using RestaurantCentral.Models;
using StructureMap;
namespace RestaurantCentral {
    public static class IoC {
        public static IContainer Initialize() {
            ObjectFactory.Initialize(x =>
                        {
                            x.Scan(scan =>
                                    {
                                        scan.TheCallingAssembly();
                                        scan.WithDefaultConventions();
                                    });
                            x.For<IDbContext>().Use<RCDB>();
                        });
            return ObjectFactory.Container;
        }
    }
}