var HOST = '127.0.0.1';  
var PORT = 21025; 

const server = require('http').createServer();
const io = require('socket.io')(server);
io.on('connection', client => {
  client.on('event', data => {
      console.log('DATA: ' + data);
      client.emit('Server', 'welcome to SocketIO'); 
  });
  client.on('disconnect', () => {
    console.log('CLOSED');
  });
  console.log('connection');
});
server.listen(PORT);
// io.listen(PORT);
console.log('Server listening on ' + HOST +':'+ PORT);  