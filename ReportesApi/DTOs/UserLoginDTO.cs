using System.ComponentModel.DataAnnotations;

namespace ReportesApi.DTOs;

public class UserLoginDTO
{
    [Required]
    public string Username { get; set; } = string.Empty;
    [Required]
    public string PasswordHash { get; set; } = string.Empty;
}
