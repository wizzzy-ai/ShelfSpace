const { Resend } = require('resend');

let resendClient = null;

function getResendClient() {
  if (resendClient) return resendClient;
  const { RESEND_API_KEY } = process.env;
  if (!RESEND_API_KEY) return null;
  resendClient = new Resend(RESEND_API_KEY);
  return resendClient;
}

// Sends an email using Resend. If API key is not set up, it prints the email in the terminal
// (development only) so you can still test the OTP flow without a mail account.
async function sendMail({ to, subject, text, html }) {
  const client = getResendClient();
  if (!client) {
    if (process.env.NODE_ENV === 'production') throw new Error('RESEND_API_KEY is not configured');
    console.log(`\n[DEV EMAIL - Resend not configured]\nTo: ${to}\nSubject: ${subject}\n${text}\n`);
    return;
  }
  await client.emails.send({
    from: process.env.MAIL_FROM || 'ShelfSpace <onboarding@resend.dev>',
    to,
    subject,
    text,
    html
  });
}

module.exports = { sendMail };