using Health.HBSP.Integration.Business;
using Health.HBSP.Integration.ServiceCore;
using Health.HBSP.Integration.ServiceFramework;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Health.HBSP.Integration.ConsoleApp
{
    public class Program
    {
        public static async Task Main(string[] args)
        {
            using (var host = CreateHostBuilder(args).Build())
            {
                await host.StartAsync();
                var lifetime = host.Services.GetRequiredService<IHostApplicationLifetime>();

                // do work here / get your work service ...
                var _worker = host.Services.GetService<ITestInterface>();
                _worker.Foo();


                lifetime.StopApplication();
                await host.WaitForShutdownAsync();
            }
            // await CreateHostBuilder(args).RunConsoleAsync();
            // var host = CreateHostBuilder(args).Build();
        }

        private static IHostBuilder CreateHostBuilder(string[] args) => Host
            .CreateDefaultBuilder(args)
            .UseConsoleLifetime()
            .ConfigureLogging(builder => {
                builder.SetMinimumLevel(LogLevel.Debug);
                builder.AddConsole();
            })
            .ConfigureServices((hostContext, services) =>
            {
                // remove the hosted service
                // services.AddHostedService<Worker>();

                // register your services here.
                services.AddScoped<IPortalSubmission, PortalSubmission>();
                services.AddScoped<IAzureBlobStorageService, AzureBlobStorageService>();
                services.AddScoped<IDataverseService, DataverseService>();
                services.AddScoped<ITestInterface, TestClass>();
                services.AddHostedService<ConsoleHostedService>();
            });
    }

    internal sealed class ConsoleHostedService : IHostedService
    {
        private readonly ILogger _logger;
        private readonly IHostApplicationLifetime _appLifetime;

        public ConsoleHostedService(
            ILogger<ConsoleHostedService> logger,
            IHostApplicationLifetime appLifetime)
        {
            _logger = logger;
            _appLifetime = appLifetime;
        }

        public Task StartAsync(CancellationToken cancellationToken)
        {
            _logger.LogDebug($"Starting with arguments: {string.Join(" ", Environment.GetCommandLineArgs())}");

            _appLifetime.ApplicationStarted.Register(() =>
            {
                Task.Run(async () =>
                {
                    try
                    {
                        _logger.LogInformation("Hello HEALTH HBSP INTEGRATION CONSOLE SERVICE!");

                        // Simulate real work is being done
                        await Task.Delay(1000);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Unhandled exception!");
                    }
                    finally
                    {
                        // Stop the application once the work is done
                        _appLifetime.StopApplication();
                    }
                });
            });

            return Task.CompletedTask;
        }

        public Task StopAsync(CancellationToken cancellationToken)
        {
            return Task.CompletedTask;
        }
    }

    //internal class Worker : IHostedService
    //{
    //    public Worker(ITestInterface testClass)
    //    {
    //        testClass.Foo();
    //    }


    //    public Task StartAsync(CancellationToken cancellationToken)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public Task StopAsync(CancellationToken cancellationToken)
    //    {
    //        throw new NotImplementedException();
    //    }
    //}

    public interface ITestInterface
    {
        void Foo();
    }

    public class TestClass : ITestInterface
    {
        private IPortalSubmission portalService;
        private IAzureBlobStorageService blobService;
        private IDataverseService dataverseService;
        private ILogger logger;
        public TestClass(
            ILogger<TestClass> Logger,
            IPortalSubmission PortalService,
            IAzureBlobStorageService AzureBlobService,
            IDataverseService DataverseService) 
        {
            logger = Logger;
            portalService = PortalService;
            blobService = AzureBlobService;
            dataverseService = DataverseService;
        }
        public void Foo()
        {
            Console.WriteLine("Foo");
            logger.LogDebug(blobService.GetBlob("BlobStorage"));
            logger.LogError(dataverseService.Retrieve("accountid"));
        }
    }
}
