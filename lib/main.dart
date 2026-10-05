import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String kSite = 'https://kalantorprokashoni.com';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const KalantorApp());
}

class KalantorApp extends StatelessWidget {
  const KalantorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'কালান্তর প্রকাশনী',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1B5E20),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _error = false;
  DateTime? _lastBack;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _error = false);
        },
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
        onWebResourceError: (e) {
          if ((e.isForMainFrame ?? false) && mounted) {
            setState(() => _error = true);
          }
        },
        onNavigationRequest: (req) {
          final uri = Uri.tryParse(req.url);
          if (uri == null) return NavigationDecision.prevent;
          if (uri.scheme == 'http' || uri.scheme == 'https') {
            return NavigationDecision.navigate;
          }
          // tel:, mailto:, whatsapp:, fb:, intent: ইত্যাদি বাইরের অ্যাপে খুলবে
          launchUrl(uri, mode: LaunchMode.externalApplication)
              .catchError((_) => false);
          return NavigationDecision.prevent;
        },
      ))
      ..loadRequest(Uri.parse(kSite));
  }

  Future<void> _onBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    final now = DateTime.now();
    if (_lastBack == null ||
        now.difference(_lastBack!) > const Duration(seconds: 2)) {
      _lastBack = now;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('বের হতে আবার ব্যাক চাপুন'),
        duration: Duration(seconds: 2),
      ));
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_progress < 100 && !_error)
                LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 3,
                ),
              if (_error)
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'ইন্টারনেট সংযোগ পাওয়া যায়নি',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'সংযোগ ঠিক আছে কিনা দেখে আবার চেষ্টা করুন',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() => _error = false);
                          _controller.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('আবার চেষ্টা করুন'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
