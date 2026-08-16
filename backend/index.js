// This file is here specifically to fix Render deployment.
// Render by default tries to run "node index.js". 
// This will correctly forward execution to the actual server file.

require('./src/server.js');
