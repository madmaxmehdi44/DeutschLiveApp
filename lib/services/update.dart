import 'package:deutschliveapp/services/storage.dart';

import 'package:package_info_plus/package_info_plus.dart';

class UpdateManager {
  StorageProvider storageProvider = StorageProvider();
  late PackageInfo packageInfo;

  Future<bool> checkIfAppWasUpdated() async {
    packageInfo = await PackageInfo.fromPlatform();
    String lastVersion =
        storageProvider.storage.get('lastVersion', defaultValue: '0.0.0');
    if (lastVersion == packageInfo.version) {
      return false;
    } else {
      return true;
    }
  }

  String getUpdateMessage() {
    return "نسخه ی به روز همراه  ";
  }

  Future<void> removeUpdate() async {
    storageProvider.storage.put('lastVersion', packageInfo.version);
  }
}
