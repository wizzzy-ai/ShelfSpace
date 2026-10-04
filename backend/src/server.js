require('dotenv').config();
const createApp = require('./app');

async function bootstrapAdmin(db, bcrypt) {
 const email=process.env.ADMIN_EMAIL, password=process.env.ADMIN_PASSWORD;
 if (!email || !password) return;
 if (password.length < 12) throw new Error('ADMIN_PASSWORD must be at least 12 characters');
 const exists=db.prepare('SELECT id FROM users WHERE email=?').get(email.toLowerCase());
 if (exists) return;
 const id=require('node:crypto').randomUUID();
 const hash=await bcrypt.hash(password,12);
 db.prepare("INSERT INTO users(id,name,email,password_hash,role) VALUES(?,?,?,?,'admin')").run(id,process.env.ADMIN_NAME||'ShelfSpace Admin',email.toLowerCase(),hash);
 console.log(`Bootstrapped admin account: ${email}`);
}

const port=Number(process.env.PORT||3000);

createApp().then(({ app, db, bcrypt }) => {
 bootstrapAdmin(db, bcrypt).then(()=>{
  const server=app.listen(port,'0.0.0.0',()=>console.log(`ShelfSpace API listening on port ${port}`));
  const shutdown=()=>server.close(()=>{process.exit(0);});
  process.on('SIGINT',shutdown);process.on('SIGTERM',shutdown);
 }).catch(error=>{console.error(error.message);process.exit(1);});
}).catch(error=>{console.error('Failed to initialize app:',error);process.exit(1);});
