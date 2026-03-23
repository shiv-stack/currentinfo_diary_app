import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults({
        "min_version": "1.0.1+0",
        "force_update": false,
        "update_url": "",
        "update_url_ios": "",
      });
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero, // Set to zero for immediate updates during testing
        ),
      );
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Log or handle error
    }
  }

  Future<bool> shouldForceUpdate() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String localVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
      final String minVersion = _remoteConfig.getString("min_version");
      final bool isForceUpdateActive = _remoteConfig.getBool("force_update");
      print("RemoteConfig: Local Version: $localVersion");
      print("RemoteConfig: Min Version: $minVersion");
      print("RemoteConfig: Force Update Active: $isForceUpdateActive");

      if (!isForceUpdateActive) return false;

      final isLower = _isVersionLower(localVersion, minVersion);
      print("RemoteConfig: Should Update: $isLower");
      return isLower;
    } catch (e) {
      print("RemoteConfig Error: $e");
      return false;
    }
  }

  bool _isVersionLower(String current, String required) {
    try {
      // Split into [version, build]
      final List<String> currentParts = current.split('+');
      final List<String> requiredParts = required.split('+');

      // Compare semantic version (1.0.1)
      final List<int> curVer = currentParts[0].split('.').map(int.parse).toList();
      final List<int> reqVer = requiredParts[0].split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        if (curVer[i] < reqVer[i]) return true;
        if (curVer[i] > reqVer[i]) return false;
      }

      // If version is same, compare build number
      if (currentParts.length > 1 && requiredParts.length > 1) {
        return int.parse(currentParts[1]) < int.parse(requiredParts[1]);
      }
    } catch (e) {
      // Fallback
    }
    return false;
  }

  String get updateUrl {
    if (Platform.isIOS) {
      return _remoteConfig.getString("update_url_ios");
    }
    return _remoteConfig.getString("update_url");
  }
}
