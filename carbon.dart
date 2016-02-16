library carbon;
import 'dart:io';
import "package:jaded/jaded.dart" as jade;
import 'jade.views.dart' deferred as views;

// RegExp fname = new RegExp(r'.+/(.+?)\.(?:.+?)$');
// RegExp underscore = new RegExp(r'/_.+$');

class Carbon {
  String publicDir;
  String sassDir;
  String jadeDir;
  String compileDir;
  Carbon({this.publicDir: 'public', this.sassDir: 'app/sass', this.jadeDir: 'app/jade', this.compileDir: 'public/compile'}) { _compile(); }
  listen(InternetAddress address, int port, { String chain:null, String key:null, String password:null }) {
    var _handleServer = (HttpServer server) => server.listen(_handleRequest);
    if(chain.isNotEmpty || key.isNotEmpty || password.isNotEmpty) {
      SecurityContext security = new SecurityContext();
      if(chain.isNotEmpty) security.useCertificateChain(Platform.script.resolve(chain).toFilePath());
      if(key.isNotEmpty) {
        if(password.isNotEmpty) security.usePrivateKey(key, password: password);
        else security.usePrivateKey(key);
      }
      HttpServer.bindSecure(address, port, security).then(_handleServer);
    }
    else HttpServer.bind(address,port) .then(_handleServer);
  }
  _compile() {
    RegExp fileName = new RegExp(r'.+/(.+?)\.(?:.+?)$');
    RegExp underscore = new RegExp(r'/_.+$');
    // Compile stylesheets.
    for (var file in new Directory(sassDir).listSync())
      if ((file is File) && (!underscore.hasMatch(file.path)))
        Process.run('sass', [ '--scss', '--style=compressed', '--sourcemap=none',
          file.path, compileDir+'/'+fileName.firstMatch(file.path).group(1)+'.css'])
          ..then((proc){ if(proc.stderr.length>1) throw proc.stderr; });
    // Compile jade.
    new File('jade.views.dart').writeAsStringSync(jade.renderDirectory(jadeDir));
    views.loadLibrary();
  }
  _handleRequest(HttpRequest req) {

  }
}
