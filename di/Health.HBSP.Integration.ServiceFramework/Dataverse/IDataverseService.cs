using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.ServiceFramework
{
    public interface IDataverseService
    {
        string Retrieve(string Id);
        bool Create(string value);
    }
}
