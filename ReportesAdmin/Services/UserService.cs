using Microsoft.AspNetCore.Components.WebAssembly.Http;
using System.Net.Http.Json;
using ReportesAdmin.DTOs;

namespace ReportesAdmin.Services;

public class UserService
{
    private readonly HttpClient _http;

    public UserService(HttpClient http)
    {
        _http = http;
    }

    public async Task<List<UserDto>?> GetUsers()
    {
        var request = new HttpRequestMessage(HttpMethod.Get, "/api/users");
        request.SetBrowserRequestCredentials(BrowserRequestCredentials.Include);

        var response = await _http.SendAsync(request);

        if (!response.IsSuccessStatusCode)
            return null;

        return await response.Content.ReadFromJsonAsync<List<UserDto>>();
    }
}