library carbon;
import 'dart:io';
import "package:jaded/jaded.dart" as jade;

class Carbon {
  static final Map<String,RegExp> _types = {
    'application': new RegExp(r'\.(json|xml|octet|dart)$'),
    'text': new RegExp(r'\.(html?|css)$'),
    'image': new RegExp(r'\.(jpe?g|gif|png)$')
  };
  List<Route> _routes = new List();
  Map<String,Function> _views;
  // God, clean this up.
  String dirPublic;
  String dirScss;
  String dirJade;
  String dirCompile;
  Carbon({this.dirPublic: 'public', this.dirScss: 'app/scss', this.dirJade: 'app/jade/pages/', this.dirCompile: 'public/compile'}) { _compile(); }
  listen(InternetAddress address, int port, { String chain:'', String key:'', String password:'' }) {
    var _handleServer = (HttpServer server) {
      server.listen(_handleRequest);
      print("Listening at "+server.address.host+":"+server.port.toString());
    };
    if(chain.isNotEmpty || key.isNotEmpty || password.isNotEmpty) {
      SecurityContext security = new SecurityContext();
      if(chain.isNotEmpty) security.useCertificateChain(Platform.script.resolve(chain).toFilePath());
      if(key.isNotEmpty) {
        if(password.isNotEmpty) security.usePrivateKey(key, password: password);
        else security.usePrivateKey(key);
      }
      HttpServer.bindSecure(address, port, security).then(_handleServer);
    }
    else HttpServer.bind(address,port).then(_handleServer);
  }
  render(HttpResponse response, String page, [Map locals = null]) {
    String jadeKey = dirJade+page+'.jade';
    if(_views.containsKey(jadeKey))
      response
      ..statusCode = HttpStatus.OK
      ..headers.contentType = ContentType.HTML
      ..write(_views[jadeKey](locals))
      ..close();
    else _notFound(response);
  }
  void forceHttps() {
    HttpServer.bind(InternetAddress.ANY_IP_V4,80)
    ..then((HttpServer server) =>
      server.listen((HttpRequest req) =>
        req.response.redirect(new Uri(scheme: 'https', host: req.headers.host, path: req.uri.path, fragment: req.uri.fragment)))
    );
  }
  void route(String method, String at, RouteHandler handler) => _routes.add(new Route(method,at,handler));
  views(Map<String,Function> jadeViews) => _views = jadeViews;
  _compile() {
    RegExp fileName = new RegExp(r'.+/(.+?)\.(?:.+?)$');
    RegExp underscore = new RegExp(r'/_.+$');
    // Create directories if they don't exist!
    for(String dir in [dirPublic,dirScss,dirJade,dirCompile]) new Directory(dir).createSync(recursive: true);
    // Compile stylesheets.
    for (var file in new Directory(dirScss).listSync())
      if ((file is File) && (!underscore.hasMatch(file.path)))
        Process.run('sass', [ '--scss', '--style=compressed', '--sourcemap=none',
          file.path, dirCompile+'/'+fileName.firstMatch(file.path).group(1)+'.css'])
          ..then((proc){ if(proc.stderr.length>1) throw proc.stderr; });
    // Compile jade.
    new File('jade.views.dart').writeAsStringSync(jade.renderDirectory(dirJade));
  }
  _notFound(HttpResponse res) => res..statusCode = HttpStatus.NOT_FOUND..headers.contentType = ContentType.TEXT..write('File not found.')..close();
  void _handleRequest(HttpRequest req) {
    // print(req.method+": "+req.uri.path);
    for(Route route in _routes)
      if(req.method == route.method && req.uri.path == route.path && route.handler(req)) return;
    if(req.method == 'GET') {
      File file = new File(dirPublic+req.uri.path);
      if(file.existsSync()) {
        req.response
        ..statusCode = HttpStatus.OK
        ..headers.contentType = _parseType(file.path)
        ..addStream(file.openRead().asBroadcastStream()).then((HttpResponse res) => res.close());
      }
      else render(req.response, '404');
    }
  }
  ContentType _parseType(String file) {
    if(file.endsWith('.js')) return ContentType.parse('application/javascript; charset=utf-8');
    for(String key in _types.keys)
      if(_types.containsKey(key))
        if(_types[key].hasMatch(file))
          return ContentType.parse(key+'/'+_types[key].firstMatch(file).group(1)+';'+((key != 'image')?' charset=utf-8':''));
    return ContentType.parse('text/plain; charset=utf-8');
  }
}

typedef bool RouteHandler(HttpRequest req);
class Route { String method; String path; RouteHandler handler; Route(this.method,this.path,this.handler); }
