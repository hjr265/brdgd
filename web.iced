_ = require 'underscore'
crypto = require 'crypto'
express = require 'express'
moment = require 'moment'
url = require 'url'


app = express()

app.configure ->
	app.set 'port', process.env.PORT or 5000
	app.set 'views', "#{__dirname}/views"
	app.set 'view engine', 'jade'

	app.disable 'x-powered-by'

	app.use express.logger 'short'

	app.use require('connect-assets')
		src: 'assets'
		buildDir: 'public'
		helperContext: app.locals
	app.use express.static "#{__dirname}/public"


app.get '/api/v1/turn/credential', (req, res, next) ->
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


app.get '/*',  (req, res) ->
	res.render 'index',
		config: _.pick process.env, [
			'PEERJS_HOST'
			'PEERJS_PORT'
			'PEERJS_KEY'
			'PEERJS_LOG'
			'STUN_HOST'
			'STUN_PORT'
			'TURN_HOST'
			'TURN_PORT'
		]
			


app.listen app.get('port'), ->
	console.log "Listening on #{app.get('port')}"