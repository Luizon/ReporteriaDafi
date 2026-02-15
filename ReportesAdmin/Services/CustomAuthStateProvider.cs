using System.Net.Http.Json;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.JSInterop;
using ReportesAdmin.DTOs;
using Microsoft.AspNetCore.Components.WebAssembly.Http;

namespace ReportesAdmin.Services;

public class CustomAuthStateProvider : AuthenticationStateProvider
{
    private readonly AuthService _auth;
    private readonly HttpClient _http;

    public CustomAuthStateProvider(AuthService authService, HttpClient http)
    {
        _auth = authService;
        _http = http;
    }

    public override async Task<AuthenticationState> GetAuthenticationStateAsync()
    {
        try
        {
            var request = new HttpRequestMessage(HttpMethod.Get, "/api/Auth/me");
            request.SetBrowserRequestCredentials(BrowserRequestCredentials.Include);

            Console.WriteLine(request.Headers);

            var response = await _http.SendAsync(request);

            if (!response.IsSuccessStatusCode)
                throw new Exception();

            var userInfo = await response.Content.ReadFromJsonAsync<UserResponseDTO>();

            var claims = new List<Claim>
            {
                new Claim("Id", userInfo.Id.ToString()),
                new Claim(ClaimTypes.NameIdentifier, userInfo.Id.ToString()),
                new Claim(ClaimTypes.Name, userInfo.Username),
                new Claim(ClaimTypes.Role, userInfo.Position)
            };

            var identity = new ClaimsIdentity(claims, "jwt");
            var user = new ClaimsPrincipal(identity);

            return new AuthenticationState(user);
        }
        catch(Exception e)
        {
            // Si falla, no hay sesión
            return new AuthenticationState(new ClaimsPrincipal(new ClaimsIdentity()));
        }
    }

    public async Task NotifyUserAuthentication()
    {
        try
        {
            var request = new HttpRequestMessage(HttpMethod.Get, "/api/Auth/me");
            request.SetBrowserRequestCredentials(BrowserRequestCredentials.Include);

            var response = await _http.SendAsync(request);

            if (!response.IsSuccessStatusCode)
                throw new Exception();

            var userInfo = await response.Content.ReadFromJsonAsync<UserResponseDTO>();

            var claims = new List<Claim>
            {
                new Claim("Id", userInfo.Id.ToString()),
                new Claim(ClaimTypes.NameIdentifier, userInfo.Id.ToString()),
                new Claim(ClaimTypes.Name, userInfo.Username),
                new Claim(ClaimTypes.Role, userInfo.Position)
            };

            var identity = new ClaimsIdentity(claims, "jwt");
            var user = new ClaimsPrincipal(identity);

            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(user)));
        }
        catch
        {
            // Si falla, notifica la sesión expirada
            var anonymous = new ClaimsPrincipal(new ClaimsIdentity());
            NotifyAuthenticationStateChanged(Task.FromResult(new AuthenticationState(anonymous)));
        }
    }

    public void NotifyUserLogout()
    {
        var anonymous = new ClaimsPrincipal(new ClaimsIdentity());
        NotifyAuthenticationStateChanged(
            Task.FromResult(new AuthenticationState(anonymous)));
    }
}
