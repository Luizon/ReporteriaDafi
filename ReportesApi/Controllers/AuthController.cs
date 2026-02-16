using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using ReportesApi.Data;
using ReportesApi.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authorization;
using ReportesApi.DTOs;

namespace ReportesApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _config;

    public AuthController(AppDbContext context, IConfiguration config)
    {
        _context = context;
        _config = config;
    }

    [HttpPost("RegisterWithoutAuth")]
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

        return Ok(dto);
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login(UserLoginDTO login)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Username == login.Username
                              && u.PasswordHash == login.PasswordHash);

        if (user == null)
            return Unauthorized();

        var claims = new[]
        {
            new Claim("Id", user.Id.ToString()),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim(ClaimTypes.Role, user.Role)
        };

        var keyString = _config["Jwt:Key"];
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(keyString!));

        var timeAlive = DateTime.UtcNow.AddHours(8);
        var token = new JwtSecurityToken(
            // issuer: _config["Jwt:Issuer"],
            // audience: _config["Jwt:Audience"],
            claims: claims,
            expires: timeAlive,
            signingCredentials: new SigningCredentials(key, SecurityAlgorithms.HmacSha256)
        );
        var handler = new JwtSecurityTokenHandler();
        var tokenString = handler.WriteToken(token);

        Response.Cookies.Append("AuthToken", tokenString, new CookieOptions
        {
            HttpOnly = true,
            Secure = true,
            SameSite = SameSiteMode.None,
            Expires = timeAlive
        });


        return Ok(new
        {
            role = user.Role
        });
    }

    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] LogoutDTO dto)
    {
        var idClaim = User.FindFirst("Id") ?? User.FindFirst(ClaimTypes.NameIdentifier);
        if (idClaim == null)
            return Unauthorized();

        if (!int.TryParse(idClaim.Value, out var userId))
            return Unauthorized();

        var user = await _context.Users.FindAsync(userId);
        if (user == null)
            return NotFound(new { message = "user not found" });

        var token = dto?.FcmToken;
        if (!string.IsNullOrWhiteSpace(token) && user.FcmTokens != null)
        {
            // si encuentra el token de firebase, lo elimina
            var removedCount = user.FcmTokens.RemoveAll(t => t == token);
            if (removedCount > 0)
            {
                _context.Users.Update(user);
                await _context.SaveChangesAsync();
            }
        }

        // esta linea de aquí ya no es firebase, con esto eliminas la cookie de sesión del cliente
        Response.Cookies.Append("AuthToken", "", new CookieOptions
        {
            Expires = DateTime.UtcNow.AddDays(-1),
            HttpOnly = true,
            Secure = true,
            SameSite = SameSiteMode.None
        });


        return NoContent();
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<IActionResult> Me()
    {
        if (User.FindFirst("Id") == null)
        {
            return Unauthorized("Token inválido");
        }

        var userId = int.Parse(User.FindFirst("Id")!.Value);
        var user = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);

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

    [Authorize]
    [HttpPost("save-fcm")]
    public async Task<IActionResult> SaveFcm([FromBody] SaveFcmDto dto)
    {
        var userId = int.Parse(User.FindFirst("Id")!.Value);
        var user = await _context.Users.FindAsync(userId);
        if (user == null) return NotFound();

        // Evitar duplicados
        if (!user.FcmTokens.Contains(dto.FcmToken))
        {
            user.FcmTokens.Add(dto.FcmToken);
            await _context.SaveChangesAsync();
        }

        return Ok(user.FcmTokens);
    }

    public class SaveFcmDto
    {
        public string FcmToken { get; set; } = string.Empty;
    }

}
