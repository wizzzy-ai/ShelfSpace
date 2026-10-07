const crypto = require('node:crypto');
const { sendMail } = require('./mailer');

const OTP_MINUTES = 10;
const RESEND_COOLDOWN_SECONDS = 60;
const MAX_ATTEMPTS = 5;

const MESSAGES = {
  EMAIL_VERIFY: {
    subject: 'Your ShelfSpace verification code',
    intro: 'Your ShelfSpace verification code is',
    outro: 'If you did not create an account, you can ignore this email.'
  },
  PASSWORD_RESET: {
    subject: 'Your ShelfSpace password reset code',
    intro: 'Your ShelfSpace password reset code is',
    outro: 'If you did not ask to reset your password, you can ignore this email.'
  }
};

function hashOtp(userId, purpose, otp) {
  return crypto.createHmac('sha256', process.env.JWT_SECRET).update(`${userId}:${purpose}:${otp}`).digest('hex');
}

async function sendOtp(db, user, purpose, { force = false } = {}) {
  if (!force) {
    const [last] = await db.query(
      'SELECT TIMESTAMPDIFF(SECOND, createdAt, NOW()) AS age FROM UserOTPs WHERE userId = ? AND purpose = ? ORDER BY id DESC LIMIT 1',
      [user.id, purpose]
    );
    if (last.length && last[0].age < RESEND_COOLDOWN_SECONDS) return false;
  }

  const otp = crypto.randomInt(0, 1000000).toString().padStart(6, '0');
  await db.query('UPDATE UserOTPs SET used = TRUE WHERE userId = ? AND purpose = ? AND used = FALSE', [user.id, purpose]);
  await db.query(
    `INSERT INTO UserOTPs (userId, otpHash, purpose, expiresAt)
     VALUES (?, ?, ?, DATE_ADD(NOW(), INTERVAL ${OTP_MINUTES} MINUTE))`,
    [user.id, hashOtp(user.id, purpose, otp), purpose]
  );

  const message = MESSAGES[purpose];
  const name = String(user.name).replace(/[<>&"]/g, '');
  await sendMail({
    to: user.email,
    subject: message.subject,
    text: `Hi ${name},\n\n${message.intro} ${otp}.\nIt expires in ${OTP_MINUTES} minutes. ${message.outro}`,
    html: `<p>Hi ${name},</p><p>${message.intro}:</p><p style="font-size:28px;font-weight:bold;letter-spacing:6px">${otp}</p><p>It expires in ${OTP_MINUTES} minutes. ${message.outro}</p>`
  });
  return true;
}

async function checkOtp(db, userId, purpose, otp) {
  const [rows] = await db.query(
    `SELECT * FROM UserOTPs
     WHERE userId = ? AND purpose = ? AND used = FALSE AND expiresAt > NOW()
     ORDER BY id DESC LIMIT 1`,
    [userId, purpose]
  );
  const row = rows[0];
  if (!row) return { ok: false, status: 400, error: 'Code is invalid or expired. Please request a new one.' };
  if (row.attempts >= MAX_ATTEMPTS) return { ok: false, status: 429, error: 'Too many wrong attempts. Please request a new code.' };

  const expected = Buffer.from(row.otpHash, 'hex');
  const given = Buffer.from(hashOtp(userId, purpose, otp), 'hex');
  if (expected.length !== given.length || !crypto.timingSafeEqual(expected, given)) {
    await db.query('UPDATE UserOTPs SET attempts = attempts + 1 WHERE id = ?', [row.id]);
    const left = MAX_ATTEMPTS - row.attempts - 1;
    return { ok: false, status: 400, error: left > 0 ? `Incorrect code. ${left} attempt${left === 1 ? '' : 's'} left.` : 'Too many wrong attempts. Please request a new code.' };
  }

  await db.query('UPDATE UserOTPs SET used = TRUE WHERE id = ?', [row.id]);
  return { ok: true };
}

module.exports = { sendOtp, checkOtp };