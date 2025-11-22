import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class XoxoWebview extends StatefulWidget {
  const XoxoWebview({super.key, required this.url});
  final String url;

  static Route<dynamic> route(String url) =>
      CupertinoPageRoute(builder: (context) => XoxoWebview(url: url), fullscreenDialog: true);

  @override
  State<XoxoWebview> createState() => _XoxoWebviewState();
}

class _XoxoWebviewState extends State<XoxoWebview> {
  late WebViewController _webViewController;
  @override
  void initState() {
    super.initState();
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) {
                print(request.url);
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: WebViewWidget(controller: _webViewController)),
    );
  }
}
