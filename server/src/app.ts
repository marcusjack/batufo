import debug from 'debug'
import http from 'http'
import socketio from 'socket.io'

const PORT = process.env.PORT || 2222
const logInfo = debug('app:info')
const logDebug = debug('app:debug')

const app = http
  .createServer(onRequest)
  .on('listening', () => logInfo('listening on http://locahost:%d', PORT))

const io = socketio(app)

function onRequest(_req: http.IncomingMessage, res: http.ServerResponse) {
  res.writeHead(404)
  res.end('Not a real server, please connect via a socket.io client instead')
}

io.on('connection', (socket: socketio.Socket) => {
  logDebug('on:connection')
  socket.emit('game:started', { gameId: 1, clientId: 2222 })

  socket.on('play:request', (req) => {
    logInfo('got play request')
    logInfo('got play request for level', req)
  })
})

app.listen(PORT)
