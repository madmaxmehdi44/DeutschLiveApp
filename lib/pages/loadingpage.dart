import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

import 'package:deutschliveapp/models/channel.dart';
import 'package:deutschliveapp/services/storage.dart';
import 'package:deutschliveapp/services/update.dart';
import 'package:deutschliveapp/services/routing.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> with WidgetsBindingObserver {
  final StorageProvider _storageProvider = StorageProvider();
  final UpdateManager _updateManager = UpdateManager();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static const String _localJsonPath = 'assets/data/channels.json';
  static const String _remoteJsonUrl =
      'https://raw.githubusercontent.com/madmaxmehdi44/deutschliveapp/master/assets/data/channels.json';

  String _statusMessage = 'در حال راه‌اندازی برنامه...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      setState(() => _statusMessage = 'در حال آماده‌سازی حافظه...');
      await _storageProvider.initialize();

      setState(() => _statusMessage = 'در حال دریافت اطلاعات دستگاه...');
      final androidInfo = await _deviceInfo.androidInfo;
      final bool isTV =
          androidInfo.systemFeatures.contains('android.software.leanback');

      setState(() => _statusMessage = 'در حال بارگذاری لیست کانال‌ها...');
      await _loadChannelList();

      setState(() => _statusMessage = 'در حال بررسی آپدیت...');
      if (await _updateManager.checkIfAppWasUpdated()) {
        await _showUpdateDialog(_updateManager.getUpdateMessage());
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      goToChannelListPage(context: context, isTV: isTV);
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'خطا در راه‌اندازی: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadChannelList() async {
    List<Channel> channels;

    try {
      final response = await http.get(Uri.parse(_remoteJsonUrl));
      if (response.statusCode == 200) {
        channels = (jsonDecode(response.body) as List)
            .map((e) => Channel.fromJson(e))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (_) {
      setState(() => _statusMessage =
          'بارگذاری آنلاین شکست خورد، در حال استفاده از نسخه آفلاین...');
      final jsonString = await rootBundle.loadString(_localJsonPath);
      channels = (jsonDecode(jsonString) as List)
          .map((e) => Channel.fromJson(e))
          .toList();
    }

    await _storageProvider.storage.put('channelList', channels);
  }

  Future<void> _showUpdateDialog(String message) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('آپدیت با موفقیت انجام شد'),
        content: Text(message),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () {
              _updateManager.removeUpdate();
              Navigator.of(context).pop();
            },
            child: const Text('باشه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pinkAccent.shade700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/icon.png', width: 120),
            const SizedBox(height: 16),
            const Text(
              'Deutsch Live App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
