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
    this.clearButton = document.getElementById('clear-button');
    this.exportButton = document.getElementById('export-button');
    this.usersContainer = document.getElementById('users');
    this.presences = {};

    this.pad = new Sketchpad(this.sketchpadContainer, userId);

    socket.connect();

    this.padChannel = socket.channel("pad:lobby");

    this.padChannel.join()
      .receive("ok", resp => console.log("Joined!", resp))
      .receive("error", resp => console.log("join failed", resp) );

    this.bind(this.padChannel);
  },

  bind(padChannel) {
    this.pad.on('stroke', data => {
      padChannel.push('stroke', data);
        // .receive('ok', ...)
        // .receive('error', ...)
    });

    this.clearButton.addEventListener('click', e => {
      e.preventDefault();
      padChannel.push('clear');
    });

    this.exportButton.addEventListener('click', e => {
      console.log(this.pad);
      window.open(this.pad.getImageURL());
    });

    padChannel.on('stroke', ({user_id, stroke}) => {
      console.log('got stroke from user', user_id);
      this.pad.putStroke(user_id, stroke, {color: '#000'});
    });

    padChannel.on('clear', ({user_id, stroke}) => {
      console.log('got clear from user', user_id);
      this.pad.clear();
    });

    padChannel.on('presence_state', state => {
      this.presences = Presence.syncState(this.presences, state);
      this.renderUsers();
    });

    padChannel.on('presence_diff', diff => {
      this.presences = Presence.syncDiff(this.presences, diff,
        this.onPresenceJoin.bind(this),
        this.onPresenceJoin.bind(this)
      );
      this.renderUsers();
    });
  },

  renderUsers() {
    const listBy = (id, {metas: [first, ...rest]}) =>  {
      first.id = id;
      first.count = rest.length + 1;
      return first;
    };

    const users = Presence.list(this.presences, listBy);
    this.usersContainer.innerHTML = users.map(user => {
      return `<br/>${sanitize(user.id)} (${user.count})`;
    }).join("");
  },

  onPresenceJoin(id, currentPres, newPres) {
    if (!currentPres) {
      console.log(`${id} has joined for the first time`);
    } else {
      console.log(`${id} has joined from another device`);
    }
  },

  onPresenceLeave(id, currentPres, leftPres) {
    if(currentPres.metas.length === 0) {
      console.log(`${id} has left entirely`);
    } else {
      console.log(`${id} has left from a device`);
    }
  }
};


App.init(window.userId, window.userToken);

