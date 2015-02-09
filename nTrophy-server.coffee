# Requirements
express = require('express')
io = require('socket.io')()
verificator = require('./lib/verificator.coffee')

## Set initial time balance
balance = 0

#Start App and routing
app = express()
app.get('/', (request,response) ->
  response.statusCode = 200
  response.send('Welcome to CML'))

app.get('/processCommand/:command', (request,response) ->
  response.statusCode = 200
  response.send(verificator.parseCommand(request.params.command)))

app.get('/cml-client.html', (request,response) ->
  response.sendFile(__dirname+'/public/cml-client.html'))

app.get('/ntrophy-admin.html', (request,response) ->
  response.sendFile(__dirname+'/public/ntrophy-admin.html'))

app.get('/functions.js', (request,response) ->
  response.sendFile(__dirname+'/js/functions.js'))

app.get('/typed.js', (request,response) ->
  response.sendFile(__dirname+'/js/vendor/typed.js'))

app.get('/cml-client.css', (request,response) ->
  response.sendFile(__dirname+'/css/cml-client.css'))

server = app.listen(8001, ->
  console.log('Server started'))

#Socket creation
io.listen(server)

io.sockets.on('connection',(socket) ->
  console.log('Socket established')
  socket.on('clientConnected', (connectionCallback) ->
    connectionCallback({'timeBalance':balance})
    )
  socket.on('timeBalanceChange',(data) ->
    console.log('Time balance change requested: ' + data)
    balance = data.percentage - 100
    socket.broadcast.emit('timeBalanceChange',{'timeBalance':balance})
  )
  socket.on('cmlRestart',->
    console.log('CML Restart requested')
    socket.broadcast.emit('cmlRestart')
  )
)



