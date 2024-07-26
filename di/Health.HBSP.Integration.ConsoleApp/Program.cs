using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

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

                lifetime.StopApplication();
                await host.WaitForShutdownAsync();
            }
            // await CreateHostBuilder(args).RunConsoleAsync();
            //ar host = CreateHostBuilder(args).Build();
        }

        //private static IHostBuilder CreateHostBuilder(string[] args) =>
        //    Host.CreateDefaultBuilder(args)
        //        .UseConsoleLifetime()
        //        .ConfigureLogging(builder => builder.SetMinimumLevel(LogLevel.Warning))
        //        .ConfigureServices((hostContext, services) =>
        //        {
        //            services.Configure<MyServiceOptions>(hostContext.Configuration);
        //            services.AddHostedService<MyService>();
        //            services.AddSingleton(Console.Out);
        //        });

        public static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
            .ConfigureServices((hostContext, services) =>
            {
                // remove the hosted service
                // services.AddHostedService<Worker>();

                // register your services here.
            });
    }
}
