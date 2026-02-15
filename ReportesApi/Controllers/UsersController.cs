using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using ReportesApi.Data;
using ReportesApi.Models;
using ReportesApi.DTOs;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace ReportesApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/Users
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetUsers()
    {
        Console.WriteLine(User.Claims.Count());
        foreach (var claim in User.Claims)
        {
            Console.WriteLine($"{claim.Type}: {claim.Value}");
        }
        Console.WriteLine("Claims");

        var users = await _context.Users.ToListAsync();

        var dtos = users.Select(u => new UserResponseDTO
        {
            Id = u.Id,
            Username = u.Username,
            Name = u.Name,
            LastName = u.LastName,
            Position = u.Position,
            Role = u.Role,
            BirthDate = u.BirthDate
        }).ToList();

        return Ok(dtos);
    }

    // GET: api/Users/{id}
    [HttpGet("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetUser(int id)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
            return NotFound(new { message = "usuario no encontrado" });

        var dto = new UserResponseDTO
        {
            Id = user.Id,
            Username = user.Username,
            Name = user.Name,
            LastName = user.LastName,
            Position = user.Position,
            Role = user.Role,
            BirthDate = user.BirthDate
        };

        return Ok(dto);
    }

    // POST: api/Users
    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserDTO dto)
    {
        var user = new User
        {
            Username = dto.Username,
            PasswordHash = dto.PasswordHash,
            Name = dto.Name,
            LastName = dto.LastName,
            Position = dto.Position,
            Role = dto.Role,
            BirthDate = dto.BirthDate
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(GetUser), new { id = user.Id }, user);
    }

    // PUT: api/Users/{id}
    // Si el requester intenta cambiar position solo funcionará si es admin
    // Si no es admin, aún puede cambiar el resto de valores de su usuario
    [HttpPut("{id}")]
    [Authorize]
    public async Task<IActionResult> UpdateUser(int id, [FromBody] UpdateUserDTO dto)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
            return NotFound(new { message = "usuario no encontrado" });

        var requesterId = GetRequesterId();
        var isAdmin = User.IsInRole("Admin");

        // si no es admin y no es su propio usuario, no se permite continuar
        if (requesterId != id && !isAdmin)
            return Forbid();

        // si es su usuario, pero quiere cambiar la position sin ser admin, no se permite continuar
        if (!string.IsNullOrEmpty(dto.Position) && !isAdmin)
            return Forbid();

        // ningun campo es obligatorio, se actualizará lo que se reciba del json
        if (dto.Username is not null && dto.Username.Trim() != "")
            user.Username = dto.Username;
        if (dto.PasswordHash is not null && dto.PasswordHash.Trim() != "")
            user.PasswordHash = dto.PasswordHash;
        if (dto.Name is not null && dto.Name.Trim() != "")
            user.Name = dto.Name;
        if (dto.LastName is not null && dto.LastName.Trim() != "")
            user.LastName = dto.LastName;
        if (dto.Position is not null && dto.Position.Trim() != "")
            user.Position = dto.Position;
        if (dto.Role is not null && dto.Role.Trim() != "")
            user.Role = dto.Role;
        if (dto.BirthDate.HasValue)
            user.BirthDate = dto.BirthDate.Value;

        _context.Users.Update(user);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    // DELETE: api/Users/{id}
    [HttpDelete("{id}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteUser(int id)
    {
        var user = await _context.Users.FindAsync(id);
        if (user == null)
            return NotFound(new { message = "usuario no encontrado" });

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();

        return NoContent();
    }

    private int? GetRequesterId()
    {
        var idClaim = User.FindFirst("Id") ?? User.FindFirst(ClaimTypes.NameIdentifier);
        if (idClaim == null)
            return null;

        if (int.TryParse(idClaim.Value, out var parsed))
            return parsed;

        return null;
    }
}
