library carbon;
import 'dart:io';
// import 'jade.views.dart' deferred as views;

class Carbon {
  // static const String viewPath = "./app/views/pages/";
  Map _pages = new Map();
  Carbon(Map pages) {
    RegExp fname = new RegExp(r'.+/(.+?)\.(?:.+?)$');
    for(String key in pages.keys)
      _pages[fname.firstMatch(key).group(1)] = pages[key];
    print("Keys: "+_pages.keys.join());
  }
  serve(host, port) async {
    print('Listening at ${host.address}:${port}');
    HttpServer server = await HttpServer.bind(host,port);
    await for (HttpRequest request in server) {
      try {
        if (request.method == 'GET') _get(request);
        else _error(request,HttpStatus.METHOD_NOT_ALLOWED);
      } catch (e) { print('Exception in handleRequest: $e'); }
    }
  }
  _get(HttpRequest request) async {
    String route = (request.uri.path.length>1)?request.uri.path.substring(1):'index';
    if(_pages.containsKey(route)) {
      request.response
      ..statusCode = HttpStatus.OK
      ..headers.contentType = ContentType.HTML
      ..write(await _pages[route]())
      ..close();
    }
    else _error(request,HttpStatus.NOT_FOUND);
  }
  _error(HttpRequest request, int status) async {
    request.response.statusCode = status;
    if(_pages.containsKey(status.toString())) {
      request.response
      ..headers.contentType = ContentType.HTML
      ..write(await _pages[status.toString()]());
    }
    request.response.close();
  }
}
