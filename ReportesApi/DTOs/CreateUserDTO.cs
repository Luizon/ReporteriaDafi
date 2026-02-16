using System.ComponentModel.DataAnnotations;
namespace ReportesApi.DTOs;

public class CreateUserDTO
{
    [Required]
    public string Username { get; set; } = string.Empty;
    [Required]
    public string PasswordHash { get; set; } = string.Empty;
    [Required]
    public string Name { get; set; } = string.Empty;
    [Required]
    public string LastName { get; set; } = string.Empty;
    [Required]
    public string Position { get; set; } = string.Empty;
    [Required]
    public string Role { get; set; } = string.Empty;
    [Required]
    public DateTime BirthDate { get; set; } = DateTime.MinValue;
}
