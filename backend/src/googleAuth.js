const { OAuth2Client } = require('google-auth-library');

let client = null;

async function verifyGoogleIdToken(idToken) {
  const clientId = process.env.GOOGLE_CLIENT_ID;
  client = client || new OAuth2Client(clientId);
  const ticket = await client.verifyIdToken({ idToken, audience: clientId });
  const payload = ticket.getPayload();
  return {
    sub: payload.sub,
    email: String(payload.email || '').toLowerCase(),
    emailVerified: payload.email_verified === true,
    name: payload.name || ''
  };
}

module.exports = { verifyGoogleIdToken };