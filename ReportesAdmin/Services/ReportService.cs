using System.Net.Http.Json;
using ReportesAdmin.Models;

namespace ReportesAdmin.Services;

public class ReportService
{
    private readonly HttpClient _http;

    public ReportService(HttpClient http)
    {
        _http = http;
    }

    public async Task<List<ReportDto>?> GetReports()
    {
        return await _http.GetFromJsonAsync<List<ReportDto>>("/api/reports");
    }
}
