'use strict';

let socket;
let clientId = null;
let isInitiator = true;

let peerConnection;

const remoteVideo = document.getElementById('remoteVideo');
const joinButton = document.getElementById('joinButton')
const startButton = document.getElementById('startButton')

let joined = false;

function join() {
  socket = new WebSocket("ws://localhost:8181/signal")
  socket.onopen = function(e) {
      socket.send(JSON.stringify({type: "join"}));
  };
  socket.onmessage = function(e) {
      const reader = new FileReader();
      reader.readAsText(e.data);
      reader.onload = () => onMessage(JSON.parse(reader.result))
  }
}

function start() {
    createPeerConnection()
    if (isInitiator) {
      console.log("creating offer")
        peerConnection.createOffer().then(sdp => setLocalSdpAndSendMessage(sdp))
    }
}

function onMessage(message) {
  console.log("onMessage: ", message)
    if (message.type === 'joined') {
      joined = true;
      joinButton.disabled = true;
        startButton.disabled = false;
        clientId = message.clientId;
    } else if (message.type === 'signal') {
        handleSignal(JSON.parse(message.body))
    }
}

function handleSignal(signal) {
  console.log("handleSignal: ", signal)
    if (signal.type === 'candidate') {
        peerConnection.add(new RTCIceCandidate(signal.candidate, signal.label, signal.id))
    } else if (signal.type === 'offer') {
        isInitiator = false;
        peerConnection.setRemoteDescription(new RTCSessionDescription(signal.sdp))
        console.log("creating answer");
        peerConnection.createAnswer().then(sdp => setLocalSdpAndSendMessage(sdp))
    } else if (signal.type === 'answer') {
      peerConnection.setRemoteDescription(new RTCSessionDescription(signal.sdp))
    }
}

const setLocalSdpAndSendMessage = (sdp) => {
  peerConnection.setLocalDescription(sdp);
  socket.send(JSON.stringify({
      type: "signal",
      clientId: clientId,
      body: JSON.stringify({
          type: sdp.type,
          sdp: sdp.sdp
      })
  }))
}

function createPeerConnection() {
  try {
    peerConnection = new RTCPeerConnection(null);
    peerConnection.onicecandidate = handleIceCandidate;
    peerConnection.onaddstream = handleRemoteStreamAdded;
//    peerConnection.onremovestream = handleRemoteStreamRemoved;
    console.log('Created RTCPeerConnnection');
  } catch (e) {
    console.log('Failed to create PeerConnection, exception: ' + e.message);
    alert('Cannot create RTCPeerConnection object.');
    return;
  }
}

function handleRemoteStreamAdded(event) {
  console.log('Remote stream added.');
  // remoteStream = event.stream;
  remoteVideo.srcObject = event.stream;
  startButton.disabled = true;
}

function handleIceCandidate(event) {
  console.log('icecandidate event: ', event);
  if (event.candidate) {
      socket.send({type: "candidate", clientId: clientId, body: JSON.stringify({
      type: 'candidate',
      label: event.candidate.sdpMLineIndex,
      id: event.candidate.sdpMid,
      candidate: event.candidate.candidate
      })});
  } else {
    console.log('End of candidates.');
  }
}
