using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RepositoryTest
{
    public class IEntity
    {
        private Guid _gid;

        public IEntity()
        {
            _gid = Guid.NewGuid();
        }

        public Guid Gid
        {
            get
            {
                return _gid;
            }
        }
    }
}
