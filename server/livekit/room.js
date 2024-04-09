import dotenv from 'dotenv'
import { AccessToken } from 'livekit-server-sdk';

dotenv.config();

const createToken = async (username, room) => {
  // if this room doesn't exist, it'll be automatically created when the first
  // client joins
  console.log(username, room);
  const roomName = room;
  // identifier to be used for participant.
  // it's available as LocalParticipant.identity with livekit-client SDK
  const participantName = username;

  const at = new AccessToken(process.env.LIVEKIT_API_KEY, process.env.LIVEKIT_API_SECRET, {
    identity: participantName,
    // token to expire after 10 minutes
    ttl: '10m',
  });
  at.addGrant({ roomJoin: true, room: roomName });

  return await at.toJwt();
}

export async function socketLiveKit (socket, IO, username) {
  socket.on('createRoom', async (data) => {
    console.log(data);
    console.log(username, data.roomName);
    const result = await createToken(username, data.roomName);
    console.log(result);
    IO.to(socket.id).emit('createRoom', result);
  });
}
