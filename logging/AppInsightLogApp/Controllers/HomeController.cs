using AppInsightLogApp.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace AppInsightLogApp.Controllers
{
	public class HomeController : Controller
	{
		private readonly ILogger<HomeController> _logger;

		public HomeController(ILogger<HomeController> logger)
		{
			_logger = logger;
		}

		public IActionResult Index()
		{
			_logger.LogTrace($"Trace: {this.Url}");
			return View();
		}

		public IActionResult Privacy()
		{
			_logger.LogInformation($"Information: {this.Url}");

			return View();
		}

		[ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
		public IActionResult Error()
		{
			try
			{
				var d = 0;
				var i = 1;
				var r = i / d;

				return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, ex.Message);

				throw;
			}		
		}
	}
}
