require('dotenv').config();
const createApp = require('./app');
const { seedAdmin } = require('./admin_seed');

const port=Number(process.env.PORT||3000);

createApp().then(({ app, db }) => {
 seedAdmin(db).then((seedResult)=>{
  if (seedResult?.created) console.log(`Bootstrapped admin account: ${seedResult.email}`);
  const server=app.listen(port,'0.0.0.0',()=>console.log(`ShelfSpace API listening on port ${port}`));
  const shutdown=()=>server.close(()=>{process.exit(0);});
  process.on('SIGINT',shutdown);process.on('SIGTERM',shutdown);
 }).catch(error=>{console.error(error.message);process.exit(1);});
}).catch(error=>{console.error('Failed to initialize app:',error);process.exit(1);});
