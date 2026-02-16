namespace ReportesApi.DTOs;

public class UserResponseDTO
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Position { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public DateTime BirthDate { get; set; } = DateTime.MinValue;
}
