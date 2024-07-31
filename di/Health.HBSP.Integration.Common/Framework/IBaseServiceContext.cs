using Microsoft.Xrm.Sdk;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.Common.Framework
{
    public interface IBaseServiceContext
    {
        IOrganizationService OrganizationService { get; }
        ITracingService TracingService { get; }
        Guid CorrelationId { get; }
        Guid OperationId { get; }
        string PrimaryEntityName { get; }
        Guid PrimaryEntityId { get; }
        Entity Target { get; }
    }
}
