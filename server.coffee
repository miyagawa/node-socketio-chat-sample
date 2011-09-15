express = require 'express'

app = express.createServer()
app.set 'view engine', 'coffee'
app.set 'view options', layout: false
app.register '.coffee', require('coffeekup').adapters.express

app.configure () ->
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.static(__dirname + '/public')
  app.use app.router

app.get '/chat/:room', (req, res, next) ->
  res.render 'chat.coffee', room: req.params.room

io = require('socket.io').listen(app)

io.sockets.on 'connection', (socket) ->
  socket.on '/push/post', (data) ->
    data.time = (new Date).getTime()
    channel = '/pub/' + data.room
    io.sockets.emit channel, data

app.listen 3000
