using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ReportesApi.Data;
using ReportesApi.DTOs;
using ReportesApi.Models;

namespace ReportesApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReportsController : ControllerBase
{
    private readonly AppDbContext _context;

    public ReportsController(AppDbContext context)
    {
        _context = context;
    }

    [Authorize]
    [HttpGet("my")]
    public IActionResult MyReports()
    {
        var userId = int.Parse(User.FindFirst("userId")!.Value);

        var reports = _context.Reports
            .Where(r => r.UserId == userId)
            .ToList();

        return Ok(reports);
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromForm] CreateReportDto dto)
    {
        var report = new Report
        {
            Title = dto.Title,
            Description = dto.Description,
            CreatedAt = DateTime.UtcNow
        };

        _context.Reports.Add(report);
        await _context.SaveChangesAsync();

        return Ok(report);
    }
}
