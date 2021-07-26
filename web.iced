_ = require 'underscore'
crypto = require 'crypto'
express = require 'express'
http = require 'http'
moment = require 'moment'
url = require 'url'
peer = require 'peer'


app = express()
server = http.createServer(app)

app.set 'port', process.env.PORT or 5000
app.set 'views', "#{__dirname}/views"
app.set 'view engine', 'jade'

app.disable 'x-powered-by'

app.use require('morgan')()

app.use require('connect-assets')
	src: [
		"#{__dirname}/assets/css"
		"#{__dirname}/assets/js"
	]
	buildDir: "public"
	helperContext: app.locals
app.use express.static "#{__dirname}/public"

app.use '/-', peer.ExpressPeerServer server,
	key: process.env.PEERJS_KEY


app.route('/api/v1/turn/credential')
.get (req, res, next) ->
	referer = url.parse req.get('Referer') or ''
	if referer.hostname isnt req.host
		res.send 403
		return

	username = "#{process.env.TURN_USER}:#{moment().unix()}"

	hmac = crypto.createHmac 'sha1', process.env.TURN_SECRET
	hmac.update username
	password = hmac.digest 'base64'

	res.send
		username: username
		password: password


app.route('/*')
.get (req, res) ->
	res.render 'index',
		config: _.pick process.env, [
			'PEERJS_HOST'
			'PEERJS_PORT'
			'PEERJS_PATH'
			'PEERJS_KEY'
			'PEERJS_LOG'
			'STUN_HOST'
			'STUN_PORT'
			'TURN_HOST'
			'TURN_PORT'
		]
			


port = app.get('port')
server.listen port, '0.0.0.0', ->
	console.log "Listening on #{port}"