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
                var portString = _configuration["EmailSettings:Port"];
                var username = _configuration["EmailSettings:Username"];
                var password = _configuration["EmailSettings:Password"];
                var fromEmail = _configuration["EmailSettings:FromEmail"];

                if (string.IsNullOrEmpty(smtpServer) || string.IsNullOrEmpty(portString) || 
                    string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password) || 
                    string.IsNullOrEmpty(fromEmail))
                {
                    throw new InvalidOperationException("Email configuration is missing in appsettings.json");
                }

                int port = int.Parse(portString);

                var smtpClient = new SmtpClient(smtpServer)
                {
                    Port = port,
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = true,
                };

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(fromEmail),
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
                _logger.LogError($"[EMAIL ERROR] {ex.Message}");
                // We rethrow so the Controller knows it failed
                throw;
            }
        }

        public async Task SendPasswordResetEmailAsync(string email, string resetToken)
        {
            var frontendUrl = _configuration["AppSettings:FrontendUrl"];
            
            // Ensure proper URL construction
            var encodedToken = Uri.EscapeDataString(resetToken);
            var encodedEmail = Uri.EscapeDataString(email);
            var resetLink = $"{frontendUrl?.TrimEnd('/')}/Register/ResetPassword?token={encodedToken}&email={encodedEmail}";

            var message = $@"
                <html>
                <body style='font-family: Arial, sans-serif;'>
                    <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
                        <h2 style='color: #6f42c1;'>Password Reset Request</h2>
                        <p>Hello,</p>
                        <p>You requested to reset your password. Click the button below:</p>
                        <div style='text-align: center; margin: 30px 0;'>
                            <a href='{resetLink}' style='background-color: #6f42c1; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;'>Reset Password</a>
                        </div>
                        <p>Or copy this link: {resetLink}</p>
                    </div>
                </body>
                </html>";

            await SendEmailAsync(email, "Password Reset Request - HRMS", message);
        }
    }
}