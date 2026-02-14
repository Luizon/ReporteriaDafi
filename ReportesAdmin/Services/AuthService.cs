using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.JSInterop;
using ReportesAdmin.Models;

namespace ReportesAdmin.Services;

public class AuthService
{
    private readonly HttpClient _http;
    private readonly IJSRuntime _js;
    private readonly CustomAuthStateProvider _authProvider;

    public AuthService(
        HttpClient http,
        IJSRuntime js,
        CustomAuthStateProvider authProvider)
    {
        _http = http;
        _js = js;
        _authProvider = authProvider;
    }

    public async Task<bool> Login(string username, string password)
    {
        var response = await _http.PostAsJsonAsync(
            "/api/Auth/login",
            new { username, password });

        if (!response.IsSuccessStatusCode)
            return false;

        var result = await response.Content.ReadFromJsonAsync<LoginResponse>();

        await _js.InvokeVoidAsync("localStorage.setItem", "token", result!.Token);

        _http.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", result.Token);

        await _authProvider.NotifyUserAuthentication(result.Token);

        return true;
    }

    public async Task Logout()
    {
        await _js.InvokeVoidAsync("localStorage.removeItem", "token");
        _http.DefaultRequestHeaders.Authorization = null;
        _authProvider.NotifyUserLogout();
    }
}
