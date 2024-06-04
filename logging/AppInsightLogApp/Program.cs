using Microsoft.Extensions.Logging.ApplicationInsights;

namespace AppInsightLogApp
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			builder.Services.AddApplicationInsightsTelemetry();

			// Add services to the container.
			builder.Services.AddControllersWithViews();

			builder.Logging.AddApplicationInsights(
				configureTelemetryConfiguration: (config) =>
					config.ConnectionString = builder.Configuration.GetConnectionString("APPLICATIONINSIGHTS_CONNECTION_STRING"),
					configureApplicationInsightsLoggerOptions: (options) => { }
			);

			builder.Logging.AddFilter<ApplicationInsightsLoggerProvider>("category-trace", LogLevel.Trace);
			builder.Logging.AddFilter<ApplicationInsightsLoggerProvider>("category-error", LogLevel.Error);

			var app = builder.Build();

			// Configure the HTTP request pipeline.
			if (!app.Environment.IsDevelopment())
			{
				app.UseExceptionHandler("/Home/Error");
				// The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
				app.UseHsts();
			}

			app.UseHttpsRedirection();
			app.UseStaticFiles();

			app.UseRouting();

			app.UseAuthorization();

			app.MapControllerRoute(
				name: "default",
				pattern: "{controller=Home}/{action=Index}/{id?}");

			app.Run();
		}
	}
}
