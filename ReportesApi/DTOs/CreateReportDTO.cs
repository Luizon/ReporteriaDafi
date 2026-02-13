using Microsoft.AspNetCore.Http;

namespace ReportesApi.DTOs;

public class CreateReportDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public IFormFile? File { get; set; }
}
