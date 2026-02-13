namespace ReportesApi.Models;

public class Report
{
    public int Id { get; set; }
    public string Folio { get; set; } = Guid.NewGuid().ToString();
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string ImageUrl { get; set; } = "";
    public ReportStatus Status { get; set; } = ReportStatus.Pending;

    public int UserId { get; set; }
    public User User { get; set; } = null!;

    public int? UserReviewerId { get; set; }
    public DateTime? ReviewDate { get; set; }
}
