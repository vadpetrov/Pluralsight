using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RepositoryTest
{
    public interface IRepository<T>: IDisposable where T : IEntity
    {
        IEnumerable<T> GetAll();
        T FindById(int Id);

        T Add(T entity);
        //void Delete(T entity);
        //void Update(T entity);

    }
}
