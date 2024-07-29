using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.ServiceCore
{
    public interface IAzureBlobStorageService
    {
        string GetBlob(string key);
        bool SaveBlob(string key, string value);
    }
}
