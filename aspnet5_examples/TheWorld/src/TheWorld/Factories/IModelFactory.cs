using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace TheWorld.Factories
{
    public interface IModelFactory
    {
        R Create<T, R>(T model) 
            where T : class
            where R : new();
    }
}
