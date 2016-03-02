using Microsoft.Practices.Unity;

namespace RepositoryTest
{
    public static class IocContainer
    {
        private static IUnityContainer _container;

        static IocContainer()
        {
            Initialize();
        }
        static void Initialize()
        {
            _container = new UnityContainer();
            _container.RegisterType<IDbConnectionFactory, DBConnectionFactory>(new HierarchicalLifetimeManager());
            
            //_container.LoadConfiguration();
        }

        public static IUnityContainer Container
        {
            get
            {
                return _container;
            }
            private set
            {
                _container = value;
            }
        }

    }
}
