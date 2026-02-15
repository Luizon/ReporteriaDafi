namespace ReportesApi.DTOs;

public class UpdateUserDTO
{
    public string? Username { get; set; }
    public string? PasswordHash { get; set; }
    public string? Name { get; set; }
    public string? LastName { get; set; }
    public string? Position { get; set; }
    public string? Role { get; set; }
    public DateTime? BirthDate { get; set; }
}
