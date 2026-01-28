namespace HRMSAPI.Services
{
    public interface IEmailService
    {
        Task SendPasswordResetEmailAsync(string email, string resetToken);
        Task SendEmailAsync(string email, string subject, string message); // This line was missing
    }
}