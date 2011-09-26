express = require("express")
nano = require('nano')('http://127.0.0.1:5984')
app = module.exports = express.createServer()
io = require('socket.io').listen(app)
db = nano.use('blocks')

app.configure ->
    app.set "views", __dirname + "/views"
    app.set "view engine", "jade"
    app.use express.bodyParser()
    app.use express.methodOverride()
    app.use express.cookieParser()
    app.use express.session(secret: "your secret here")
    app.use express.compiler(
        src: __dirname + "/public"
        enable: [ "sass" ]
    )
    app.use express.static(__dirname + "/public")
    app.use app.router

app.configure "development", ->
    app.use express.errorHandler(
        dumpExceptions: true
        showStack: true
    )

app.configure "production", ->
    app.use express.errorHandler()


#views
app.get "/", (req, res) ->
    res.render "index", title: "Blocks"

#socket
io.sockets.on "connection", (socket) ->
    socket.on 'get_value', (key) ->
        #socket.emit('info','We are getting the value of '+key)
        db.get key, (err,doc) ->
            if err
                #socket.emit('warn', err.error)
                socket.emit('get_value', "")
            else
                socket.emit('get_value', doc.value)
    socket.on 'set_value', (data) ->
        #socket.emit('info','We are setting the value of '+data.key+" as "+data.value)
        db.get data.key, (err, doc) ->
            doc.value = data.value
            db.insert doc, data.key, (err,d) ->
                if err
                    socket.emit('warn',err)
                #socket.emit('warn',d)

#runserver
app.listen 3000
console.log "Express server listening on port %d in %s mode", app.address().port, app.settings.env
