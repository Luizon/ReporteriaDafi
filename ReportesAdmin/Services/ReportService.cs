using System.Net.Http.Json;
using ReportesAdmin.DTOs;

using Microsoft.AspNetCore.Components.WebAssembly.Http;

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
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/reports");
        request.SetBrowserRequestCredentials(BrowserRequestCredentials.Include);

        var response = await _http.SendAsync(request);

        if (!response.IsSuccessStatusCode)
            return null;

        return await response.Content.ReadFromJsonAsync<List<ReportDto>>();
    }
}
