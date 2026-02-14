using System.Net.Http.Json;
using ReportesAdmin.Models;

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
        return await _http.GetFromJsonAsync<List<UserDto>>("/api/users");
    }
}
