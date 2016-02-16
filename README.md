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
import 'jade.views.dart' deferred as jadeViews;

main() async {
  // Creating a new Carbon instance compiles our jade and scss for us. In this case we're using the default folders.
  Carbon server = new Carbon();

  // load up our jade views, now that they're compiled. Probably.
  await jadeViews.loadLibrary();

  server
  // Pass those views into the server, so that we can use them.
  ..views(jadeViews.JADE_TEMPLATES)

  // Define a route for our root.
  ..route('GET','/',(req) {

    // render the index page defined in our jade files
    server.render(req.response, 'index');
    // return true, stopping the flow in the carbon request handlers.
    return true;

  })

  // Start listening. In this case, with port 3000.
  ..listen(InternetAddress.ANY_IP_V4, 3000);
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
- Use RegExp for routs.
