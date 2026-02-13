namespace ReportesApi.Models;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = "";
    public string PasswordHash { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Apellido { get; set; } = "";
    public int Edad { get; set; }
    public string Puesto { get; set; } = "";
    public string? FcmToken { get; set; }

    public List<Report> Reports { get; set; } = new();
}
