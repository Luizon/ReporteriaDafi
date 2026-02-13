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
    public async Task<IActionResult> MyReports()
    {
        var userId = int.Parse(User.FindFirst("Id")!.Value);

        var reports = await _context.Reports
            .Where(r => r.UserId == userId)
            .ToListAsync();

        return Ok(reports);
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromForm] CreateReportDto dto)
    {
        // validaciones
        if (dto == null)
            return BadRequest("Body is required");

        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var userIdClaim = User.FindFirst("Id")?.Value;
        if (userIdClaim == null)
            return Unauthorized();

        var userId = int.Parse(userIdClaim);

        var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
        if (!userExists)
            return BadRequest("User does not exist");

        // manejo de imagen
        var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot/uploads");

        if (!Directory.Exists(uploadsFolder))
            Directory.CreateDirectory(uploadsFolder);

        var fileName = Guid.NewGuid() + Path.GetExtension(dto.File!.FileName);
        var filePath = Path.Combine(uploadsFolder, fileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await dto.File.CopyToAsync(stream);
        }

        // registrar reporte
        var report = new Report
        {
            Title = dto.Title,
            Description = dto.Description,
            CreatedAt = DateTime.UtcNow,
            UserId = userId,
            ImageUrl = "uploads/" + fileName
        };

        _context.Reports.Add(report);
        await _context.SaveChangesAsync();

        return Ok(report);
    }
}
