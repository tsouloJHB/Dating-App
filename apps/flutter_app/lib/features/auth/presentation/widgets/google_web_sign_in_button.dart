import 'package:flutter/widgets.dart';

import 'google_web_sign_in_button_stub.dart'
    if (dart.library.html) 'google_web_sign_in_button_web.dart' as impl;

Widget googleWebSignInButton({double minimumWidth = 320}) =>
    impl.buildGoogleWebSignInButton(minimumWidth: minimumWidth);
