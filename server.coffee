fs    = require 'fs'
http  = require 'http'
io    = require 'socket.io'
path  = require 'path'
spawn = require('child_process').spawn

class Process
  @nameForCommand: (command) ->
    pathComponents = command.split('/')
    pathComponents[pathComponents.length - 1]
  
  @parse: (data) ->
    proc = new Process()
    proc.user    = data[0]
    proc.pid     = data[1]
    proc.cpu     = data[2]
    proc.mem     = data[3]
    proc.vsz     = data[4]
    proc.rss     = data[5]
    proc.tt      = data[6]
    proc.stat    = data[7]
    proc.started = data[8]
    proc.time    = data[9]
    proc.command = data[10]
    proc.name    = Process.nameForCommand(proc.command)
    proc

getProcessesInfo = (callback) ->
  ps = spawn './ps-info'
  ps.stdout.on 'data', (data) ->
    psOut = data.toString().split("\n\n")[1..-2]
    procs = (Process.parse(procStats.split("\n")) for procStats in psOut)
    callback procs

app = http.createServer (req, res) ->
  filePath = ".#{req.url}"
  filePath += 'index.html' if filePath == './'
  
  ext = path.extname(filePath)
  contentType = 'text/html'
  contentType = 'text/css'        if ext == '.css'
  contentType = 'text/javascript' if ext == '.js'
  
  path.exists filePath, (exists) ->
    if exists
      fs.readFile filePath, (err, data) ->  
        res.writeHead 200, 'Content-Type': contentType
        res.end data, 'utf-8'
    else
      res.writeHead 404
      res.end()

app.listen 1337
io = io.listen(app)

io.sockets.on 'connection', (socket) ->
  getProcessesInfo (processes) ->
    socket.emit 'ps-info', processes