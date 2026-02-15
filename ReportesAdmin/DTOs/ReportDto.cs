namespace ReportesAdmin.DTOs;

public class ReportDto
{
    public int Id { get; set; }
    public string Folio { get; set; }
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public DateTime CreatedAt { get; set; }
    public string? ImageUrl { get; set; }
    public int Status { get; set; }
    public int UserId { get; set; }
    public int? UserReviewerId { get; set; }
    public DateTime? ReviewDate { get; set; }
}
