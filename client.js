(function() {
  var socket;

  socket = io.connect('http://localhost');

  socket.on('ps-info', function(data) {
    var source, template;
    source = $("#proc-template").html();
    template = Handlebars.compile(source);
    return $('#procs').html(template({
      procs: data
    }));
  });

}).call(this);
