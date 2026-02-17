using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ReportesApi.Data;
using ReportesApi.DTOs;
using ReportesApi.Models;
using ReportesApi.Services;

namespace ReportesApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ReportsController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly FcmService _fcmService;

    public ReportsController(AppDbContext context, FcmService fcmService)
    {
        _context = context;
        _fcmService = fcmService;
    }

    [Authorize]
    [HttpGet("my")]
    public async Task<IActionResult> MyReports()
    {
        var userId = int.Parse(User.FindFirst("Id")!.Value);

        var baseUrl = $"https://{Request.Host.Value}";

        var reports = await (
            from r in _context.Reports
            where r.UserId == userId
            join u in _context.Users on r.UserReviewerId equals u.Id into reviewers
            from reviewer in reviewers.DefaultIfEmpty() // left join
            select new
            {
                r.Id,
                r.Title,
                r.Folio,
                r.Description,
                r.CreatedAt,
                r.UserId,
                r.Status,
                ImageUrl = $"{baseUrl}/{r.ImageUrl}",
                ReviewerName = reviewer != null ? reviewer.Name + " " + reviewer.LastName : null,
                r.UserReviewerId,
                r.ReviewDate
            }
        ).ToListAsync();

        return Ok(reports);
    }


    [Authorize]
    [HttpGet("{id}")]
    public async Task<IActionResult> GetReport(int id)
    {
        var userId = int.Parse(User.FindFirst("Id")!.Value);

        var baseUrl = $"https://{Request.Host.Value}";

        var report = await (
            from r in _context.Reports
            where r.Id == id
            join u in _context.Users on r.UserReviewerId equals u.Id into reviewers
            from reviewer in reviewers.DefaultIfEmpty() // left join
            select new
            {
                r.Id,
                r.Title,
                r.Folio,
                r.Description,
                r.CreatedAt,
                r.UserId,
                r.Status,
                ImageUrl = $"{baseUrl}/{r.ImageUrl}",
                ReviewerName = reviewer != null ? reviewer.Name + " " + reviewer.LastName : null,
                r.UserReviewerId,
                r.ReviewDate
            }
        ).FirstOrDefaultAsync();

        if (report == null)
            return NotFound("Reporte no encontrado");

        // Validación de permisos
        var user = User.FindFirst("Id")?.Value;
        if (report.UserId.ToString() != user && !User.IsInRole("Admin"))
            return Unauthorized();

        return Ok(report);
    }

    [Authorize(Roles = "Admin")]
    [HttpGet]
    public async Task<IActionResult> GetAllReports()
    {
        var reports = await _context.Reports
            .ToListAsync();

        var baseUrl = $"https://{Request.Host.Value}";

        var result = reports.Select(r => new
        {
            r.Id,
            r.Title,
            r.Folio,
            r.Description,
            r.CreatedAt,
            r.UserId,
            r.Status,
            ImageUrl = r.ImageUrl == null ? "" : $"{baseUrl}/{r.ImageUrl}",
            r.UserReviewerId,
            r.ReviewDate
        });

        return Ok(result);
    }

    [Authorize(Roles = "Admin")]
    [HttpPut]
    public async Task<IActionResult> UpdateStatus([FromBody] UpdateReportStatusDto dto)
    {
        var report = await _context.Reports.FindAsync(dto.Id);
        if (report == null)
            return NotFound("Reporte no encontrado");

        // Obtener el Id del usuario revisor desde la cookie/claims
        var reviewerIdClaim = User.FindFirst("Id")?.Value;
        if (reviewerIdClaim == null)
            return Unauthorized();

        var reviewerId = int.Parse(reviewerIdClaim);

        // Actualizar campos
        report.Status = (ReportStatus)dto.Status;
        report.UserReviewerId = reviewerId;
        report.ReviewDate = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        // Mandar notificación push al usuario que creó el reporte
        string? imageUrl = null;
        if (!string.IsNullOrEmpty(report.ImageUrl))
        {
            imageUrl = $"https://{Request.Host.Value}/{report.ImageUrl}";
        }

        var user = await _context.Users.FindAsync(report.UserId);
        if (user != null && user.FcmTokens.Any())
        {
            var statusText =
                report.Status == ReportStatus.Accepted ? "aceptado" :
                report.Status == ReportStatus.Rejected ? "rechazado" :
                "actualizado";

            await _fcmService.SendNotificationAsync(
                tokens: user.FcmTokens,
                title: "Reporte actualizado",
                body: $"Tu reporte '{report.Title}' fue {statusText}",
                imageUrl: imageUrl,
                data: new Dictionary<string, string>
                {
                    { "reportId", report.Id.ToString() },
                    { "type", "report_update" }
                }
            );
        }

        return Ok();
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Create([FromForm] CreateReportDto dto)
    {
        // validaciones
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
            Folio = "eliminar_campo",
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
