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

        public async Task SendPasswordResetEmailAsync(string email, string resetToken)
        {
            try
            {
                var smtpServer = _configuration["EmailSettings:SmtpServer"];
                var port = _configuration["EmailSettings:Port"];
                var username = _configuration["EmailSettings:Username"];
                var password = _configuration["EmailSettings:Password"];
                var fromEmail = _configuration["EmailSettings:FromEmail"];
                var frontendUrl = _configuration["AppSettings:FrontendUrl"];

                if (string.IsNullOrEmpty(smtpServer) || string.IsNullOrEmpty(port) || 
                    string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password) || 
                    string.IsNullOrEmpty(fromEmail) || string.IsNullOrEmpty(frontendUrl))
                {
                    throw new InvalidOperationException("Email configuration is missing. Please check appsettings.json");
                }

                var smtpClient = new SmtpClient(smtpServer)
                {
                    Port = int.Parse(port),
                    Credentials = new NetworkCredential(username, password),
                    EnableSsl = true,
                };

                // Ensure proper URL construction
                var encodedToken = Uri.EscapeDataString(resetToken);
                var encodedEmail = Uri.EscapeDataString(email);
                var resetLink = $"{frontendUrl.TrimEnd('/')}/Register/ResetPassword?token={encodedToken}&email={encodedEmail}";

                _logger.LogInformation($"Generated reset link: {resetLink}");

                var mailMessage = new MailMessage
                {
                    From = new MailAddress(fromEmail),
                    Subject = "Password Reset Request - HRMS",
                    Body = $@"
                        <html>
                        <body style='font-family: Arial, sans-serif;'>
                            <div style='max-width: 600px; margin: 0 auto; padding: 20px;'>
                                <h2 style='color: #6f42c1;'>Password Reset Request</h2>
                                <p>Hello,</p>
                                <p>You requested to reset your password for your HRMS account.</p>
                                <p>Click the button below to reset your password:</p>
                                <div style='text-align: center; margin: 30px 0;'>
                                    <a href='{resetLink}' style='background-color: #6f42c1; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; display: inline-block;'>Reset Password</a>
                                </div>
                                <p>Or copy and paste this link into your browser:</p>
                                <p style='word-break: break-all; color: #666;'>{resetLink}</p>
                                <p style='color: #999; font-size: 12px; margin-top: 30px;'>
                                    This link will expire in 1 hour.<br>
                                    If you didn't request this, please ignore this email.
                                </p>
                            </div>
                        </body>
                        </html>
                    ",
                    IsBodyHtml = true,
                };

                mailMessage.To.Add(email);

                _logger.LogInformation($"Sending password reset email to {email}");
                await smtpClient.SendMailAsync(mailMessage);
                _logger.LogInformation($"Password reset email sent successfully to {email}");
            }
            catch (SmtpException ex)
            {
                _logger.LogError($"SMTP Error sending email to {email}: {ex.Message}");
                throw new InvalidOperationException($"Failed to send email: {ex.Message}", ex);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error sending email to {email}: {ex.Message}");
                throw;
            }
        }
    }
}