doctype 5
html ->
  head ->
    title "Room: #{@room}"
    script src: '/jquery.js'
    script src: '/jquery.ev.js'
    script src: '/jquery.md5.js'
    script src: '/jquery.oembed.js'
    script src: '/jquery.cookie.js'
    script src: '/pretty.js'
    script src: '/socket.io/socket.io.js'
    script -> "window.room = '#{@room}'"
    coffeescript ->
      cookieName = 'node_chat_ident';
      doPost = (socket, el1, el) ->
        ident = el1.val()
        if ident
          $.cookie cookieName, ident, path: '/chat'
        text = el.val()
        if !text
          return
        socket.emit '/push/post', {
          room: window.room,
          ident: ident,
          text: text
        }
        el.val('')
        return false
      $ ->
        socket = io.connect window.location.origin
        socket.on '/pub/' + window.room, (data) ->
          onNewEvent(data)
        $('#form').submit () -> doPost(socket, $('#ident'), $('#chat'))
        onNewEvent = (e) ->
          src = e.avatar || ("http://www.gravatar.com/avatar/" + $.md5(e.ident || 'foo'))
          name = e.name || e.ident || 'Anonymous'
          avatar = $('<img/>').attr('src', src).attr('alt', name)
          if e.ident
            link = if e.ident.match(/https?:/) then e.ident else 'mailto:' + e.ident
            avatar = $('<a/>').attr('href', link).attr('target', '_blank').append(avatar)
          avatar = $('<td/>').addClass('avatar').append(avatar)
          message = $('<td/>').addClass('chat-message')
          message.text(e.text) if e.text
          message.html(e.html) if e.html
          message.find('a').oembed(null, { embedMethod: "append", maxWidth: 500 })
          name = e.name || (if e.ident then e.ident.split('@')[0] else null)
          if name
            message.prepend($('<span/>').addClass('name').text(name+ ': '))
          date = new Date(e.time)
          meta = $('<td/>').addClass('meta').append(
            '(' +
            '<span class="pretty-time" title="' + date.toUTCString() + '">' + date.toDateString() + '</span>' +
            ' from ' + e.address + ')')
          $('.pretty-time', meta).prettyDate()
          $('#messages').prepend($('<tr/>').addClass('message').append(avatar).append(message).append(meta))

        if $.cookie(cookieName)
          $('#ident').attr('value', $.cookie(cookieName))

        p = -> $(".pretty-time").prettyDate()
        window.setInterval p, 1000 * 30

    link rel: 'stylesheet', href: '/screen.css'
    style '''
#messages {
  margin-top: 1em;
  margin-right: 3em;
  width: 100%;
}
.avatar {
  width: 25px;
  vertical-align: top;
}
.avatar img {
  width: 25px; height: 25px;
  vertical-align: top;
  margin-right: 0.5em;
}
.chat-message {
  width: 70%;
}
.chat-message .name {
  font-weight: bold;
}
.meta {
  vertical-align: top;
  color: #888;
  font-size: 0.8em;
}
body {
  margin: 1em 2em
}
    '''
  body ->
    h1 class: "chat-room-name", ->
      "Chat room: #{@room}"
    text "Your email (for Gravatar): "
    input id: "ident", type: "text", name: "ident", size: 24
    form '#form', ->
      text "Something to say: "
      input id: "chat", type: "text", size: 48

    table id: 'messages'

    div '#footer', ->
      "Originally written for Tatsumaki framework. Ported to node.js, coffeekup, socket.io and express.js"
