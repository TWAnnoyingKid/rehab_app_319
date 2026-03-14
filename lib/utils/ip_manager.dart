import 'package:shared_preferences/shared_preferences.dart';

class IpManager {
  static const String _ipKey = 'app_ip_address';
  static const String _defaultIp = 'http://163.15.164.85:10073';
  static const String _legacyIp = 'https://hpds.klooom.com:10073/flutterphp/';

  static final IpManager _instance = IpManager._internal();
  factory IpManager() => _instance;
  IpManager._internal();

  String _currentIp = _defaultIp + '/flutterphp/';

  String get currentIp => _currentIp;

  String get displayIp => _currentIp.replaceAll('/flutterphp/', '');

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString(_ipKey);

      if (savedIp != null && savedIp.isNotEmpty) {
        _currentIp = savedIp;
        print('已載入儲存的IP設定: $_currentIp');
      } else {
        _currentIp = _defaultIp + '/flutterphp/';
        print('使用預設IP設定: $_currentIp');
      }
    } catch (e) {
      print('載入IP設定失敗: $e');
      _currentIp = _defaultIp + '/flutterphp/';
    }
  }

  Future<bool> setIp(String newIp) async {
    try {
      String cleanIp = newIp.trim();

      if (!cleanIp.startsWith('http://') && !cleanIp.startsWith('https://')) {
        cleanIp = 'http://' + cleanIp;
      }

      if (cleanIp.endsWith('/')) {
        cleanIp = cleanIp.substring(0, cleanIp.length - 1);
      }

      final fullIp = cleanIp + '/flutterphp/';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ipKey, fullIp);

      _currentIp = fullIp;

      print('IP設定已更新: $_currentIp');
      return true;
    } catch (e) {
      print('設定IP失敗: $e');
      return false;
    }
  }

  Future<bool> resetToLegacy() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_ipKey, _legacyIp);
      _currentIp = _legacyIp;
      print('IP已重設為舊設定: $_currentIp');
      return true;
    } catch (e) {
      print('重設IP失敗: $e');
      return false;
    }
  }

  Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final defaultFullIp = _defaultIp + '/flutterphp/';
      await prefs.setString(_ipKey, defaultFullIp);
      _currentIp = defaultFullIp;
      print('IP已重設為預設設定: $_currentIp');
      return true;
    } catch (e) {
      print('重設IP失敗: $e');
      return false;
    }
  }

  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_ipKey);
      _currentIp = _defaultIp + '/flutterphp/';
      print('IP設定已清除，恢復為預設值');
    } catch (e) {
      print('清除IP設定失敗: $e');
    }
  }
}
