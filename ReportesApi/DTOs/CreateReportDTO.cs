using System.ComponentModel.DataAnnotations;

namespace ReportesApi.DTOs;

public class CreateReportDto
{
    [Required]
    public string Title { get; set; } = string.Empty;
    [Required]
    public string Description { get; set; } = string.Empty;
    [Required]
    public IFormFile? File { get; set; }
}
