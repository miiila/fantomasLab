# Requirements
express = require('express')
io = require('socket.io')()
basicAuth = require('basic-auth')

verificator = require('./lib/verificator.coffee')

## Set initial time balance
balance = 0

#Authentication
auth = (request, response, next) ->
  unauthorized = (response) ->
    response.set('WWW-Authenticate', 'Basic realm=Authorization Required')
    return response.send(401)
  user = basicAuth(request)
  return next() if user?.name == 'ntrophy' and user?.pass == 'sesameOtevriSe'
    
  return unauthorized(response)

#Start App and routing
app = express()

app.get('/', (request,response) ->
  response.statusCode = 200
  response.send('Welcome to CML'))

app.get('/processCommand/:command', (request,response) ->
  response.statusCode = 200
  response.send(verificator.parseCommand(request.params.command)))

app.get('/cml-client.html',auth,(request,response) ->
  response.sendFile(__dirname+'/public/cml-client.html'))

app.get('/ntrophy-admin.html',auth, (request,response) ->
  response.sendFile(__dirname+'/public/ntrophy-admin.html'))

app.get('/functions.js', (request,response) ->
  response.sendFile(__dirname+'/js/functions.js'))

app.get('/typed.js', (request,response) ->
  response.sendFile(__dirname+'/js/vendor/typed.js'))

app.get('/*.css', (request,response) ->
  response.sendFile(__dirname+'/css/'+request.params[0]+'.css'))

app.get('/*.png', (request,response) ->
  response.sendFile(__dirname+'/'+request.params[0]+'.png'))

app.set('port', (process.env.PORT || 5000));
server = app.listen(app.get('port'), ->
  console.log('Server started at port ' +  + app.get('port')))

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



