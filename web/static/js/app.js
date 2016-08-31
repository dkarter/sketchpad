import "phoenix_html"
import {Socket, Presence} from "phoenix"
import {Sketchpad, sanitize} from "./sketchpad"


let App = {
  init(userId, token) {
    if(!token) return null;

    let socket = new Socket("/socket", {
      params: { token }
    });

    this.sketchpadContainer = document.getElementById('sketchpad');
    this.pad = new Sketchpad(this.sketchpadContainer, userId);

    socket.connect();

    let padChannel = socket.channel("pad:lobby");

    padChannel.join()
      .receive("ok", resp => console.log("Joined!", resp))
      .receive("error", resp => console.log("join failed", resp) );
  }
};


App.init(window.userId, window.userToken);

