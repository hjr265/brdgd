[![Stories in Ready](https://badge.waffle.io/hjr265/brdgd.png?label=ready&title=Ready)](https://waffle.io/hjr265/brdgd)
# Brdgd

Brdgd (read bridged) is an extremely simple P2P file transfer webapp. It depends on [PeerJS](http://peerjs.com) to manage the P2P connections. The webapp, in rare cases, uses a turn server to relay the connection in case where the peers cannot reach each other due to certain obvious reasons.

## Deploy

The webapp can be deployed to Heroku as long as the following information are provided via environment variables:

- `PEERJS_HOST`: PeerJS host

- `PEERJS_PORT`: PeerJS port

- `PEERJS_KEY`: PeerJS API key

- `PEERJS_LOG`: PeerJS log level

- `STUN_HOST`: STUN server host

- `STUN_PORT`: STUN server port

- `TURN_HOST`: TURN server host

- `TURN_PORT`: TURN server port

- `TURN_USER`: TURN server username

- `TURN_SECRET`: TURN server secret
