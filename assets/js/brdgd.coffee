utils =
	ellipsis: (text, length) ->
		if text.length <= length
			return text
		pre = text.slice 0, Math.floor(length / 2)
		suf = text.slice -Math.floor(length / 2)
		return pre + '...' + suf

	escape: (text) ->
		$('<div></div>').text(text).text()


class Brdgd
	constructor: (config) ->
		@config = config

		@peer = null

	announce: (id, done) ->
		if typeof done is 'undefined'
			done = id
			id = null

		if @peer
			@peer.destroy()
			@peer = null

		_announce = (ices) =>
			@peer = new Peer id,
				host: @config.PEERJS_HOST
				port: @config.PEERJS_PORT
				key: @config.PEERJS_KEY
				config:
					iceServers: ices
				debug: @config.PEERJS_LOG
			done()

		ices = []
		ices.push 
			url: "stun:#{@config.STUN_HOST}:#{@config.STUN_PORT}"
		if @config.TURN_HOST
			$.get '/api/v1/turn/credential', (credential) =>
				ices.push 
					url: "turn:#{credential.username}@#{@config.TURN_HOST}:#{@config.TURN_PORT}"
					credential: credential.password
				
				_announce ices

		else
			_announce ices

	expose: (file) ->
		@reset()

		@file = file

		@token = ''
		for i in [0...32]
			@token += 'X1NFBWiez6YmcjIEtr89wRfgs7vq0u3AhZKOPdMTnLaVGJlby4HQU25CkSDopx'[_.random(61)]

		@announce @token, =>
			@peer.on 'connection', (conn) =>
				conn.on 'open', =>
					conn.send 'meta'
					conn.send 
						name: @file.name
						size: @file.size
						type: @file.type
				
				conn.on 'close', (data) =>


				conn.on 'data', (data) =>
					switch data
						when 'body'
							conn.send 'body'

							$progress = $('<div class="progress active"><div class="progress-bar" style="width: 0"></div></div>').css('width', $('#buttons').width())
							$('#container').append $progress


							sent = 0
							more = =>
								if sent is @file.size
									_.delay ->
										$progress.fadeOut ->
											$(@).detach()
									, 500
									return

								part = @file.slice sent, sent + 1048576
								conn.send part
								
								sent += part.size
								$('.progress-bar', $progress).css 'width', Math.floor(sent * 100 / @file.size) + '%'

								_.delay more, 100

							more()

			$('#buttons').empty().append $('<button class="btn disabled"></button>').html utils.escape(utils.ellipsis(@file.name, 16)) + ' (' + numeral(@file.size).format('0 b') + ')'
			$('#buttons').append $('<button class="btn btn-danger animated flipInY"></button>').html('<i class="fa fa-times"></i> ').on 'click', =>
				@reset()
				history.pushState null, null, '/'

			$('#address').tooltip
				placement: 'bottom'
				title: 'Share this URL'
				trigger: 'manual'
			$('#address').tooltip 'show'

	grope: (token) ->
		if token is @token
			return

		@reset()

		@token = token

		@announce =>
			mode = ''
			meta = null
			have = 0
			parts = []
			blob = null

			conn = @peer.connect @token, 
				reliable: true
			conn.on 'data', (data) =>
				switch mode
					when ''
						mode = data

					when 'meta'
						meta = data
						mode = ''

						$('#buttons .btn:first').html utils.escape(utils.ellipsis(meta.name, 16)) + ' (' + numeral(meta.size).format('0 b') + ')'
						$('#buttons').append $('<button class="btn btn-primary animated flipInY"></button>').html('<i class="fa fa-download"></i> ').on 'click', =>
							if mode
								return
							if !meta
								return
							if have is meta.size
								$('#download').trigger 'click'
							else
								conn.send 'body'

							$('#buttons .btn:nth-child(2)').html '<i class="fa fa-spinner fa-spin"></i>'

							$('#container').append $('<div class="progress active animated fadeIn"><div class="progress-bar" style="width: 0"></div></div>').css('width', $('#buttons').width())
						break

					when 'body'
						parts.push data

						have += data.byteLength
						$('.progress .progress-bar').css 'width', Math.floor(have * 100 / meta.size) + '%'

						if have is meta.size
							mode = 'done'

							blob = new Blob parts,
								type: meta.type

							_.delay ->
								$('.progress').fadeOut ->
									$(@).detach()

								$('#buttons .btn:nth-child(2)').detach()								
								$('#buttons').addClass('animated pulse').append $('<a class="btn btn-primary"><i class="fa fa-save"></i></a>').attr
									href: URL.createObjectURL blob
									download: meta.name
							, 500
						break

			$('#buttons').empty().append $('<button class="btn disabled"></button>').text('Retrieving metadata..')

	reset: ->
		if @peer
			@peer.destroy()
			@peer = null

		@token = ''

		@file = null

		$('#buttons').empty().append $('<button class="btn btn-primary" title="" data-="" data-=""></button>').text('Choose file..').on 'click', =>
			$input = $('<input type="file">').on 'change', (event) =>
				@expose(event.target.files[0])
				history.pushState null, null, "/#{@token}"
			$input.trigger 'click'
		$('#address').tooltip 'destroy'

		$('.progress').detach()


brdgd = new Brdgd $('script[data-config]').data('config')


$(window).on 'popstate', ->
	token = location.pathname.replace /^\/(.+)$/, '$1'
	if token.match /^[a-zA-Z0-9]{32}$/
		brdgd.grope token

	else switch token
		when 'about'

		else
			brdgd.reset()

$(window).trigger 'popstate'


$('a[href="/"]').on 'click', (event) ->
	event.preventDefault()
	brdgd.reset()
	history.pushState null, null, '/'

$('body').on 'webkitAnimationEnd mozAnimationEnd oAnimationEnd animationEnd', '*', ->
	$(@).removeClass 'animated flipInY flipInY fadeIn pulse bounceInDown flipInX'

$('h1').addClass 'animated bounceInDown'
$('#buttons').addClass 'animated flipInX'
