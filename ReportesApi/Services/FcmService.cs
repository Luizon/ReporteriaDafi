using Google.Apis.Auth.OAuth2;
using Google.Apis.Util;
using System.Net.Http.Headers;
using System.Text.Json;

namespace ReportesApi.Services;

public class FcmService
{
    private readonly HttpClient _httpClient;
    private readonly string _projectId;

    public FcmService(HttpClient httpClient, string projectId)
    {
        _httpClient = httpClient;
        _projectId = projectId;
    }

    public async Task SendNotificationAsync(IEnumerable<string> tokens, string title, string body)
    {
        // Obtén el access token con las credenciales de Firebase
        var path = Path.Combine(Directory.GetCurrentDirectory(),
            "Secrets/firebase-service-account.json");
        var credential = GoogleCredential.FromFile(path)
            .CreateScoped("https://www.googleapis.com/auth/firebase.messaging");
        var accessToken = await credential.UnderlyingCredential.GetAccessTokenForRequestAsync();

        foreach (var token in tokens)
        {
            var message = new
            {
                message = new
                {
                    token = token,
                    notification = new
                    {
                        title,
                        body
                    }
                }
            };

            var json = JsonSerializer.Serialize(message);
            var request = new HttpRequestMessage(HttpMethod.Post,
                $"https://fcm.googleapis.com/v1/projects/{_projectId}/messages:send");
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
            request.Content = new StringContent(json, System.Text.Encoding.UTF8, "application/json");

            await _httpClient.SendAsync(request);
        }
    }
}