using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.ServiceFramework
{
    public class DataverseService : IDataverseService
    {
        public string Retrieve(string Id)
        {
            return $"Dataverse record of {Id}";
        }
        public bool Create(string value)
        {
            return true;
        }
    }
}
