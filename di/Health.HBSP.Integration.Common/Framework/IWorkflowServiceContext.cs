using System;
using System.Activities;

namespace Health.HBSP.Integration.Common.Framework
{
    public interface IWorkflowServiceContext : IBaseServiceContext
    {
        string StageName { get; }
        string GetParameter(InArgument<string> argument);

        T GetParameter<T>(InArgument<T> argument);

        void SetParameter<T>(OutArgument<T> argument, T value);

        T GetParameterAsJson<T>(InArgument<string> argument);

        Guid UserId { get; }
    }
}
