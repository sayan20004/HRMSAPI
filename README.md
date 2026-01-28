# HRMS API - User Registration & JWT Authentication

A simple user registration and authentication API built with ASP.NET Core 8.0, featuring JWT token-based authentication, ASP.NET Identity, and SQLite database.

## Features

- **User Registration**: Create new user accounts with Full Name, Email, and Password
- **JWT Authentication**: Secure token-based login system
- **ASP.NET Identity**: Built-in user management and password hashing
- **Auto Migration**: Database automatically created on startup
- **SQLite Database**: No server setup required, file-based database
- **Swagger UI**: Interactive API documentation and testing

## Prerequisites

- .NET 8.0 SDK
- Visual Studio Code or Visual Studio 2022

## Configuration

### Database

The app uses SQLite with a file-based database (`hrms.db`) that is automatically created in the project folder.

Connection string in `appsettings.json`:
```json
"ConnectionStrings": {
  "DefaultConnection": "Data Source=hrms.db"
}
```

### JWT Settings

JWT configuration is in `appsettings.json`:

```json
"Jwt": {
  "Key": "YourSuperSecretKeyForJwtTokenGeneration12345!",
  "Issuer": "HRMSAPI",
  "Audience": "HRMSAPIUsers",
  "ExpiryInMinutes": 60
}
```

**Important**: Change the `Key` value to your own secure key in production!

## Setup & Installation

### 1. Restore Packages

```bash
dotnet restore
```

### 2. Run the Application

```bash
dotnet run
```

The application will:
- Automatically create the SQLite database (`hrms.db`)
- Run all migrations to create Identity tables
- Start the API server on http://localhost:5227

### 3. Access Swagger UI

Open your browser and navigate to:
```
http://localhost:5227/swagger
```

## API Endpoints

### Authentication Endpoints

#### Register New User
```
POST http://localhost:5227/api/auth/register
Content-Type: application/json

{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "Password123",
  "confirmPassword": "Password123"
}
```

**Response:**
```json
{
  "message": "User registered successfully!"
}
```

#### Login
```
POST http://localhost:5227/api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "Password123"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "email": "john@example.com",
  "fullName": "John Doe",
  "expiration": "2026-01-27T10:30:00Z"
}
```

## Database Schema

### AspNetUsers Table (Main User Table)

| Column | Type | Description |
|--------|------|-------------|
| Id | TEXT | Primary key (GUID) |
| FullName | TEXT | User's full name |
| Email | TEXT | User email address |
| NormalizedEmail | TEXT | Uppercase email for searching |
| PasswordHash | TEXT | Hashed password (secure) |
| EmailConfirmed | INTEGER | Whether email is verified |
| SecurityStamp | TEXT | Security token |
| ConcurrencyStamp | TEXT | For concurrency control |

Additional Identity tables are also created: AspNetRoles, AspNetUserRoles, AspNetUserClaims, AspNetUserLogins, AspNetUserTokens, AspNetRoleClaims.

## Testing the API

### Using Swagger UI

1. Start the application: `dotnet run`
2. Navigate to http://localhost:5227/swagger
3. Test `/api/auth/register` to create a new user
4. Test `/api/auth/login` to get a JWT token
5. Copy the token from the response

### Using Postman

**1. Register User**
- Method: POST
- URL: `http://localhost:5227/api/auth/register`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "Password123",
  "confirmPassword": "Password123"
}
```

**2. Login**
- Method: POST  
- URL: `http://localhost:5227/api/auth/login`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "email": "john@example.com",
  "password": "Password123"
}
```

**3. Use the Token**
- Copy the `token` value from login response
- Use it in Authorization header: `Bearer YOUR_TOKEN_HERE`

## Project Structure

```
HRMSAPI/
├── Controllers/
│   └── AuthController.cs          # Registration & Login endpoints
├── Data/
│   └── ApplicationDbContext.cs    # EF Core DbContext with Identity
├── Models/
│   ├── ApplicationUser.cs         # User model with FullName
│   └── DTOs/
│       └── AuthDto.cs             # RegisterDto, LoginDto, AuthResponseDto
├── Migrations/                     # EF Core migrations
├── SQL/
│   ├── DatabaseSetup.sql          # Reference SQL for Identity tables
│   └── RegistrationForm.sql       # Simple SQL example
├── Program.cs                      # Application configuration
├── appsettings.json               # Configuration settings
├── HRMSAPI.csproj                 # Project file
└── hrms.db                        # SQLite database (auto-generated)
```

## Password Requirements

Default password requirements:
- Minimum 6 characters
- At least 1 digit
- At least 1 lowercase letter
- At least 1 uppercase letter
- Special characters optional

You can modify these in `Program.cs` under the Identity configuration.

## Security Notes

1. **Change JWT Key**: Update the JWT Key in production to a strong, random secret (at least 32 characters)
2. **HTTPS**: Enable HTTPS in production
3. **Password Policy**: Current settings are for development; strengthen for production
4. **CORS**: Update CORS policy to allow only specific origins in production
5. **Environment Variables**: Store sensitive configuration (JWT key, connection strings) in environment variables or Azure Key Vault

## Troubleshooting

### Port Already in Use

If you see "address already in use" error:
```bash
lsof -ti:5227 | xargs kill -9
dotnet run
```

### Database Issues

If you need to recreate the database:
```bash
rm hrms.db
dotnet ef database update
```

### Migration Issues

To add a new migration:
```bash
dotnet ef migrations add MigrationName
dotnet ef database update
```

### JWT Token Issues

- Ensure token format: `Authorization: Bearer <token>`
- Check token expiration (default: 60 minutes)
- Verify JWT Key matches in configuration

## Development Commands

```bash
# Run the application
dotnet run

# Run with auto-reload on file changes
dotnet watch run

# Build the project
dotnet build

# Restore packages
dotnet restore

# Create migration
dotnet ef migrations add MigrationName

# Apply migrations
dotnet ef database update
```

## API Testing Examples

### cURL Examples

```bash
# Register
curl -X POST http://localhost:5227/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"fullName":"John Doe","email":"john@example.com","password":"Password123","confirmPassword":"Password123"}'

# Login
curl -X POST http://localhost:5227/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@example.com","password":"Password123"}'
```

## Technologies Used

- **ASP.NET Core 8.0** - Web framework
- **Entity Framework Core 8.0** - ORM
- **ASP.NET Core Identity** - User management
- **JWT Bearer Authentication** - Token-based auth
- **SQLite** - Database
- **Swagger/OpenAPI** - API documentation

## License

MIT License
