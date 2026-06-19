import 'package:flutter/widgets.dart';
import 'package:google_sign_in_web/web_only.dart' as gis;

Widget buildGoogleWebSignInButton({double minimumWidth = 320}) {
  final width = minimumWidth.clamp(1.0, 400.0);
  return SizedBox(
    key: const ValueKey('google-web-sign-in-button'),
    width: width,
    height: 48,
    child: gis.renderButton(
      configuration: gis.GSIButtonConfiguration(
        minimumWidth: width,
        type: gis.GSIButtonType.standard,
        size: gis.GSIButtonSize.large,
        text: gis.GSIButtonText.continueWith,
        theme: gis.GSIButtonTheme.outline,
        shape: gis.GSIButtonShape.rectangular,
      ),
    ),
  );
}
