using Health.HBSP.Integration.Common.Framework;
using System;
using System.Activities;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Health.HBSP.Integration.Workflows.Common
{
    public abstract class ExtendedCodeActivity : CodeActivity
    {
        public Action<Container> ConfigContainer { get; set; } = null;

        protected override void Execute(CodeActivityContext executionContext)
        {
            var workflowContext = executionContext.GetExtension<IWorkflowContext>();
            var tracingService = executionContext.GetExtension<ITracingService>();
            var serviceFactory = executionContext.GetExtension<IOrganizationServiceFactory>();
            var organizationService = serviceFactory.CreateOrganizationService(workflowContext.UserId);

            using (var container = new Container())
            {
                container.Register(() => executionContext);
                container.Register(() => workflowContext);
                container.Register(() => tracingService);
                container.Register(() => serviceFactory);
                container.Register(() => organizationService);
                container.Register<IContextUser>(() => new ContextUser(container.Resolve<IWorkflowContext>(),
                    container.Resolve<IOrganizationService>()));
                container.Register<IWorkflowServiceContext>(() => new WorkflowServiceContext(container.Resolve<IWorkflowContext>(),
                    container.Resolve<CodeActivityContext>(), container.Resolve<IOrganizationService>(), container.Resolve<ITracingService>()));
                RegisterServices(container);
                ConfigContainer?.Invoke(container);
                Execute(container);
            }
        }

        protected virtual void RegisterServices(Container container)
        {
            container.RegisterCoreServices();
        }

        protected abstract void Execute(Container container);
    }
}
