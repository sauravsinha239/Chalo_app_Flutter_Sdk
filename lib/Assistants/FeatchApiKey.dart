import 'package:firebase_remote_config/firebase_remote_config.dart';

class MapConfig {
  static Future<String>getMapsApiKey() async{
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout : const Duration(seconds: 10),
       minimumFetchInterval : const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getString('key');
  }
  static Future<String>getToken() async{
    final remoteConfig = FirebaseRemoteConfig.instance;

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout : const Duration(seconds: 10),
      minimumFetchInterval : const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
    return remoteConfig.getString('token');
  }
}
