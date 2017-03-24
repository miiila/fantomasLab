# Requirements
express = require('express')
io = require('socket.io')()
basicAuth = require('basic-auth')
multer  = require('multer')
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
storage = multer.diskStorage(
  destination: (req, file, cb) ->
    cb(null, './files')
  filename: (req, file, cb) ->
    cb(null, file.fieldname + '.json')
)

upload = multer({storage})

app.get('/', (request,response) ->
  response.statusCode = 200
  response.send('Welcome to CML'))

app.get('/processCommand/:command', (request,response) ->
  response.statusCode = 200
  response.send(verificator.parseCommand(request.params.command)))

app.post('/uploadFile', upload.any(), (request,response) ->
    response.send(response.fileContent))

app.get('/cml-client.html',auth,(request,response) ->
  response.sendFile(__dirname+'/public/cml-client.html'))

app.get('/ntrophy-admin.html',auth, (request,response) ->
  response.sendFile(__dirname+'/public/ntrophy-admin-vue.html'))

app.get('/functions.js', (request,response) ->
  response.sendFile(__dirname+'/js/functions.js'))

app.get('/typed.js', (request,response) ->
  response.sendFile(__dirname+'/js/vendor/typed.js'))

app.get('/vue.js', (request,response) ->
  response.sendFile(__dirname+'/js/vendor/vue.js'))

app.get('/*.css', (request,response) ->
  response.sendFile(__dirname+'/css/'+request.params[0]+'.css'))

app.get('/*.png', (request,response) ->
  response.sendFile(__dirname+'/'+request.params[0]+'.png'))

app.get('/*.ogg', (request,response) ->
  response.sendFile(__dirname+'/audio/'+request.params[0]+'.ogg'))

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
  socket.on('adminConnected', (connectionCallback) ->
    tasks = verificator.getTasks()
    console.log(tasks)
    connectionCallback({'tasks':tasks})
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
  socket.on('cmlTaskStarted', (cmlTask)->
    console.log('CML Task started ' + JSON.stringify(cmlTask))
    timeArray = cmlTask.time.split(":")
    cmlTask.miliseconds = (timeArray[0] * 60000) + (timeArray[1]*1000)
    console.log('Recalculated ' + JSON.stringify(cmlTask))
    socket.broadcast.emit('startCmlTask',cmlTask)
  )
  socket.on('cmlTaskFinished', (cmlTask)->
    console.log('CML Task finished ' + JSON.stringify(cmlTask))
    socket.broadcast.emit('finishCmlTask',cmlTask)
  )
  socket.on('cmlRestarted',->
    verificator.resetPuzzleLocations()
  )

)



