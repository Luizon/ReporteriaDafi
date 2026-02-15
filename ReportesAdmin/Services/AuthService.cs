using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.JSInterop;
using ReportesAdmin.DTOs;
using Microsoft.AspNetCore.Components.WebAssembly.Http;

namespace ReportesAdmin.Services;

public class AuthService
{
    private readonly HttpClient _http;

    public AuthService(
        HttpClient http)
    {
        _http = http;
    }

    public async Task<bool> Login(string username, string passwordHash)
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/api/Auth/login")
        {
            Content = JsonContent.Create(new { username, passwordHash })
        };

        request.SetBrowserRequestCredentials(BrowserRequestCredentials.Include);

        var response = await _http.SendAsync(request);

        if (!response.IsSuccessStatusCode)
            return false;

        var result = await response.Content.ReadFromJsonAsync<LoginResponse>();

        return true;
    }

    public async Task Logout()
    {
        var request = new HttpRequestMessage(HttpMethod.Post, "/api/Auth/logout")
        {
            Content = JsonContent.Create(new { FcmToken = (string?)null })
        };
        request.SetBrowserRequestCredentials(BrowserRequestCredentials.Include);

        await _http.SendAsync(request);
    }
}
