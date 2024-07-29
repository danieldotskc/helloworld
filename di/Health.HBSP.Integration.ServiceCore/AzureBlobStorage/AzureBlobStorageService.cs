using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.ServiceCore
{
    public class AzureBlobStorageService : IAzureBlobStorageService
    {
        public string GetBlob(string key)
        {
            return $"Blob value of key '{key}'";
        }
        public bool SaveBlob(string key, string value)
        {
            return key == "key" ? true : false;
        }
    }
}
