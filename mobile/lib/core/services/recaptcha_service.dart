import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Service reCAPTCHA v3 — génère un token via WebView invisible.
/// Le token est ensuite envoyé au backend pour vérification.
class RecaptchaService {
  static const String _siteKey = '6LdSdYotAAAAACYwQ9c378anvmHLVrP9sbaSXxXR';

  /// Génère un token reCAPTCHA v3 pour l'action donnée.
  /// Retourne null en cas d'échec.
  static Future<String?> getToken(
    BuildContext context,
    String action,
  ) async {
    final completer = Completer<String?>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => _RecaptchaDialog(
        siteKey: _siteKey,
        action: action,
        onToken: (token) {
          if (!completer.isCompleted) completer.complete(token);
        },
        onError: () {
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future;
  }
}

class _RecaptchaDialog extends StatefulWidget {
  final String siteKey;
  final String action;
  final void Function(String) onToken;
  final VoidCallback onError;

  const _RecaptchaDialog({
    required this.siteKey,
    required this.action,
    required this.onToken,
    required this.onError,
  });

  @override
  State<_RecaptchaDialog> createState() => _RecaptchaDialogState();
}

class _RecaptchaDialogState extends State<_RecaptchaDialog> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'RecaptchaChannel',
        onMessageReceived: (message) {
          Navigator.of(context, rootNavigator: true).pop();
          final data = jsonDecode(message.message) as Map<String, dynamic>;
          if (data['success'] == true) {
            widget.onToken(data['token'] as String);
          } else {
            widget.onError();
          }
        },
      )
      ..loadHtmlString(_buildHtml());
  }

  String _buildHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <script src="https://www.google.com/recaptcha/api.js?render=${widget.siteKey}"></script>
</head>
<body>
<script>
  grecaptcha.ready(function() {
    grecaptcha.execute('${widget.siteKey}', {action: '${widget.action}'})
      .then(function(token) {
        RecaptchaChannel.postMessage(JSON.stringify({success: true, token: token}));
      })
      .catch(function(err) {
        RecaptchaChannel.postMessage(JSON.stringify({success: false, error: err.toString()}));
      });
  });
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    // WebView invisible — juste pour générer le token
    return SizedBox(
      width: 1,
      height: 1,
      child: WebViewWidget(controller: _controller),
    );
  }
}
