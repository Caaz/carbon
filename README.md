# Carbon
A quick to use web framework which utilizes jade and scss for front end shenanigans.
This framework is designed to be as minimal and barebones as possible, yet powerful enough to be able to create dynamic web servers with ease.

## Why did I make this?
I used to use express, but the lack of secure servers disappointed me. I could have forked it and made that a possibility, but because it was a port of the express js framework, I didn't want to rear my ugly head into that.
Because of my previous experience with express, this framework uses a similar approach to handling routes and what not. Features are created as I need them.

## Installation
Add this to your pubspec.yaml dependencies and run `pub get`.
```yaml
dependencies:
  carbon:
    git: git://github.com/Caaz/carbon.git
```

## Usage
Here's a quick example of using this package. With some helpful comments.
```dart
import "dart:io";
import "package:carbon/carbon.dart";
// import "../Dart/lib/Carbon/lib/carbon.dart";
import 'jade.views.dart' deferred as jadeViews;
import 'package:mongo_dart/mongo_dart.dart';

main() async {
  Carbon server = new Carbon(dirCompile:'public/css');
  await jadeViews.loadLibrary();
  server
  ..views(jadeViews.JADE_TEMPLATES)
  // Root route, by default, it renders the 'index page'
  ..addSimpleRoute()
  // This will render the funPage.jade when we go to whatever/fun
  ..addSimpleRoute(path:'/fun',render:'funPage')
  // If we want to do something more serious however...
  ..addRoute(
    new Route(
      // we use RegExp to do something fancy.
      regex:new RegExp(r'^/echo/(.+?)/?$', caseSensitive: false),
      handler:(req, {Iterable<Match> matches}) {
        server.render(req.response, 'debug', {"msg":matches.first.group(1)} );
        return true;
      }
    )
  )
  ..listen(InternetAddress.ANY_IP_V4, 80);
}
```
By default, Carbon uses the following folders and files, creating them if they're not there to begin with
- `app`
  - `jade` Used for jade views.
    - `pages` The folder you should place actual views in.
  - `scss` Used for precompiled scss files.
- `public` the root directory of every static file served
  - `compile` Where compiled scss gets thrown
- `jade.views.dart` compiled jade files.

## Examples
- [Portfolio](http://github.com/Caaz/portfolio-dart)

## TODO

- Explain how to use secure server stuff.
- Explain path usage.
- Explain jade?
- Optional sass.
