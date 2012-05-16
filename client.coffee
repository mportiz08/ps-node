socket = io.connect('http://localhost')
socket.on 'ps-info', (data) ->
  source   = $("#proc-template").html()
  template = Handlebars.compile source
  $('#procs').html template(procs: data)
