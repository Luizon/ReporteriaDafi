using Microsoft.EntityFrameworkCore;
using ReportesApi.Models;

namespace ReportesApi.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) {}

    public DbSet<User> Users => Set<User>();
    public DbSet<Report> Reports => Set<Report>();
}
