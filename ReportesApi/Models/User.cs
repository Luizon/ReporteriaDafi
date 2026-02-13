namespace ReportesApi.Models;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Name { get; set; } = "";
    public string LastName { get; set; } = "";
    public DateTime BirthDate { get; set; }
    public string Position { get; set; } = "";
    public string? FcmToken { get; set; }

    public List<Report> Reports { get; set; } = new();
}
