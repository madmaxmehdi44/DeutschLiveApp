import 'package:deutschliveapp/services/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateManager {
  final StorageProvider storageProvider = StorageProvider();
  late PackageInfo packageInfo;

  /// بررسی اینکه آیا نسخه فعلی با نسخه ذخیره‌شده متفاوت است
  Future<bool> checkIfAppWasUpdated() async {
    packageInfo = await PackageInfo.fromPlatform();
    final String lastVersion =
        storageProvider.storage.get('lastVersion', defaultValue: '0.0.0');

    return lastVersion != packageInfo.version;
  }

  /// پیام آپدیت شامل نسخه جدید
  String getUpdateMessage() {
    return "برنامه به نسخه ${packageInfo.version} به‌روزرسانی شد.";
  }

  /// ذخیره نسخه فعلی به‌عنوان آخرین نسخه اجرا شده
  Future<void> removeUpdate() async {
    await storageProvider.storage.put('lastVersion', packageInfo.version);
    await storageProvider.storage.put(
      'lastUpdateDate',
      DateTime.now().toIso8601String(),
    );
  }

  /// گرفتن نسخه فعلی برنامه
  Future<String> getCurrentVersion() async {
    packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// گرفتن نسخه قبلی ذخیره‌شده
  String getLastStoredVersion() {
    return storageProvider.storage.get('lastVersion', defaultValue: '0.0.0');
  }

  /// گرفتن تاریخ آخرین آپدیت (در صورت وجود)
  String? getLastUpdateDate() {
    return storageProvider.storage.get('lastUpdateDate');
  }

  /// بررسی اینکه آیا نسخه خاصی نصب شده است
  Future<bool> isSpecificVersion(String version) async {
    packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version == version;
  }
}
