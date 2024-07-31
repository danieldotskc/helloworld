using Health.HBSP.Integration.Common.Framework;
using Health.HBSP.Integration.Common.Services;

namespace Health.HBSP.Integration.Workflows
{
    public static class ServiceRegister
    {
        public static Container RegisterCoreServices(this Container container)
        {
           // container.Register<IConfigurationService>(() => new ConfigurationService(container.Resolve<IOrganizationService>()));
            container.Register<IAccountService, AccountService>();
            //container.Register<IReviewService, ReviewService>();
            //container.Register<ISharedService, SharedService>();
            //container.Register<ICandidateService, CandidateService>();
            //container.Register<IRFIService, RFIService>();
            //container.Register<IRFIResponseService, RFIResponseService>();
            //container.Register<IRFIResponseCTSDeviceService, RFIResponseCTSDeviceService>();
            //container.Register<IRFIResponseEssentialPrincipleService, RFIResponseEssentialPrincipleService>();
            //container.Register<IReviewAssessmentRequestService, ReviewAssessmentRequestService>();
            //container.Register<IReviewARTGService, ReviewARTGService>();
            //container.Register<ITrancheService, TrancheService>();
            //container.Register<IReviewRiskAssessmentService, ReviewRiskAssessmentService>();
            //container.Register<INotificationService, NotificationService>();
            //container.Register<ISharePointService, SharePointService>();
            //container.Register<ICTSService, CTSService>();
            //container.Register<IRFICTSDeviceGroupService, RFICTSDeviceGroupService>();
            //container.Register<IRFICTSDeviceGroupItemService, RFICTSDeviceGroupItemService>();

            //container.Register<IContractResolver>(() => new DefaultContractResolver
            //{
            //    NamingStrategy = new CamelCaseNamingStrategy()
            //});

            //container.Register(() => new JsonSerializerSettings
            //{
            //    ContractResolver = container.Resolve<IContractResolver>(),
            //    Formatting = Formatting.None
            //});

            return container;
        }
    }
}
