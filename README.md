# Brdgd

Brdgd (read bridged) is an extremely simple p2p file transfer webapp. It depends on [PeerJS](http://peerjs.com) to manage the p2p connections. The webapp, in rare cases, uses a turn server to relay the connection in case where the peers cannot reach each other due to certain obvious reasons.

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
