using System.Net;
using System.Net.Mail;

namespace HRMSAPI.Services
{
    public class EmailService : IEmailService
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
        {
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendEmailAsync(string email, string subject, string message)
        {
            try
            {
                var smtpServer = _configuration["EmailSettings:SmtpServer"];
                var port = int.Parse(_configuration["EmailSettings:Port"]!);
                var username = _configuration["EmailSettings:Username"];
                var password = _configuration["EmailSettings:Password"];
                var fromEmail = _configuration["EmailSettings:FromEmail"];

                var smtpClient = new SmtpClient(smtpServer)
                {
                    Port = port,
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = true,
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(fromEmail!),
                    Subject = subject,
                    Body = message,
                    IsBodyHtml = true,
                };

                mailMessage.To.Add(email);

                _logger.LogInformation($"[EMAIL] Sending to {email}...");
                await smtpClient.SendMailAsync(mailMessage);
                _logger.LogInformation($"[EMAIL] Sent successfully!");
            }
            catch (Exception ex)
            {
                // CRITICAL: Look for this line in your API Console if email fails
                _logger.LogError($"[EMAIL ERROR] {ex.Message}");
                throw;
            }
        }

        public async Task SendPasswordResetEmailAsync(string email, string resetToken)
        {
            var frontendUrl = _configuration["AppSettings:FrontendUrl"];
            var encodedToken = Uri.EscapeDataString(resetToken);
            var encodedEmail = Uri.EscapeDataString(email);
            var resetLink = $"{frontendUrl?.TrimEnd('/')}/Register/ResetPassword?token={encodedToken}&email={encodedEmail}";

            var message = $"Click here to reset your password: <a href='{resetLink}'>Reset Password</a>";
            await SendEmailAsync(email, "Password Reset", message);
        }
    }
}