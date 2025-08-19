// import 'dart:convert';

// import 'package:deutschliveapp/models/channel.dart';
// import 'package:flutter/material.dart';

// import 'package:deutschliveapp/services/storage.dart';
// import 'package:deutschliveapp/services/routing.dart';
// import 'package:deutschliveapp/services/update.dart';

// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// class LoadingPage extends StatefulWidget {
//   const LoadingPage({super.key});

//   @override
//   State<LoadingPage> createState() => _LoadingPageState();
// }

// class _LoadingPageState extends State<LoadingPage> {
//   StorageProvider storageProvider = StorageProvider();
//   UpdateManager updateManager = UpdateManager();
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   final FocusNode _focusNode = FocusNode();

//   late AndroidDeviceInfo androidInfo;

//   String _bottomMessage = 'Deutschland LIVE APP';

//   bool buttonFocused = false;

//   Future<void> _showUpdateDialogBox(String updatemessage) async {
//     await showDialog(
//       context: context,
//       useRootNavigator: true,
//       useSafeArea: true,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           _focusNode.requestFocus();
//         });
//         return AlertDialog(
//           title: const Text('Updated Successfully.'),
//           content: Text(updatemessage),
//           actions: [
//             TextButton(
//               focusNode: _focusNode,
//               onFocusChange: (_) => _returnDialogBoxFocus,
//               style: ButtonStyle(
//                 foregroundColor: WidgetStateProperty.all<Color>(Colors.blue),
//               ),
//               onPressed: () => _closeUpdateDialogBox(),
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _returnDialogBoxFocus(_) {
//     _focusNode.requestFocus();
//   }

//   void _closeUpdateDialogBox() {
//     updateManager.removeUpdate();
//     Navigator.of(context).pop();
//   }

//   Future<void> fetchAndStoreChannelList() async {
//     // const String remoteJsonUrl =
//     //     'https://raw.githubusercontent.com/aldrinzigmundv/deutschliveapp/master/assets/data/channels.json';
//     const String localJsonPath = 'assets/data/channels.json';

//     try {
//       List<Channel> channels = await fetchLocalChannelList(localJsonPath);

//       await storageProvider.storage.put('channelList', channels);
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _bottomMessage = 'Failed to fetch channel list online.';
//         });
//       }

//       List<Channel> localChannels = storageProvider.storage
//           .get('channelList', defaultValue: []).cast<Channel>();

//       if (localChannels.isNotEmpty) {
//         return;
//       }

//       List<Channel> channels = await fetchLocalChannelList(localJsonPath);

//       await storageProvider.storage.put('channelList', channels);
//     }
//   }

//   Future<List<Channel>> fetchRemoteChannelList(String url) async {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       List<dynamic> jsonList = jsonDecode(response.body);
//       return jsonList.map((json) => Channel.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load remote JSON');
//     }
//   }

//   Future<List<Channel>> fetchLocalChannelList(String path) async {
//     final String jsonString = await rootBundle.loadString(path);
//     List<dynamic> jsonList = jsonDecode(jsonString);
//     return jsonList.map((json) => Channel.fromJson(json)).toList();
//   }

//   Future<void> _startup() async {
//     final results = await Future.wait([
//       storageProvider.initialize(),
//       deviceInfo.androidInfo,
//     ]);
//     await fetchAndStoreChannelList();
//     final androidInfo = results[1] as AndroidDeviceInfo;
//     bool isTV =
//         androidInfo.systemFeatures.contains('android.software.leanback');
//     bool justUpdated = await updateManager.checkIfAppWasUpdated();
//     if (justUpdated) {
//       await _showUpdateDialogBox(updateManager.getUpdateMessage());
//     }
//     if (mounted) {
//       goToChannelListPage(context: context, isTV: isTV);
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     DeviceOrientation.portraitUp;

//     _startup();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.pinkAccent[900],
//       body: Center(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset('assets/icons/icon.png'),
//           const Padding(
//             padding: EdgeInsets.all(9.0),
//             child: Text(
//               'Deutsch Live App',
//               style: TextStyle(color: Colors.white, fontSize: 27.0),
//             ),
//           ),
//         ],
//       )),
//       bottomNavigationBar: SelectableText(_bottomMessage,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.redAccent, fontSize: 15.0)),
//     );
//   }
// }

import 'dart:convert';

import 'package:deutschliveapp/models/channel.dart';
import 'package:deutschliveapp/services/routing.dart';
import 'package:deutschliveapp/services/storage.dart';
import 'package:deutschliveapp/services/update.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final StorageProvider _storageProvider = StorageProvider();
  final UpdateManager _updateManager = UpdateManager();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static const String _localJsonPath = 'assets/data/channels.json';
  static const String _remoteJsonUrl =
      'https://raw.githubusercontent.com/aldrinzigmundv/deutschliveapp/master/assets/data/channels.json';

  String _bottomMessage = 'Deutschland LIVE APP';

  @override
  void initState() {
    super.initState();
    // قفل جهت نمایش پرتره
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _storageProvider.initialize();

      // اطلاعات دستگاه
      final androidInfo = await _deviceInfo.androidInfo;
      final bool isTV =
          androidInfo.systemFeatures.contains('android.software.leanback');

      // بارگذاری لیست کانال
      await _loadChannelList();

      // بررسی به‌روزرسانی
      if (await _updateManager.checkIfAppWasUpdated()) {
        await _showUpdateDialog(_updateManager.getUpdateMessage());
      }

      // ناوبری به صفحه لیست کانال
      if (!mounted) return;
      goToChannelListPage(context: context, isTV: isTV);
    } catch (e) {
      if (mounted) {
        setState(() {
          _bottomMessage = 'خطا در راه‌اندازی برنامه: $e';
        });
      }
    }
  }

  Future<void> _loadChannelList() async {
    List<Channel> channels;

    try {
      // تلاش برای دریافت آنلاین
      final response = await http.get(Uri.parse(_remoteJsonUrl));
      if (response.statusCode == 200) {
        channels = (jsonDecode(response.body) as List)
            .map((e) => Channel.fromJson(e))
            .toList();
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (_) {
      // fallback به فایل لوکال در صورت خطا
      setState(() {
        _bottomMessage = 'بارگذاری آنلاین کانال‌ها شکست خورد';
      });
      final jsonString = await rootBundle.loadString(_localJsonPath);
      channels = (jsonDecode(jsonString) as List)
          .map((e) => Channel.fromJson(e))
          .toList();
    }

    // ذخیره در local storage
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
      // backgroundColor: Colors.pinkAccent.shade700,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/icons/icon.png'),
            const SizedBox(height: 12),
            const Text(
              'Deutsch Live App',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _bottomMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
