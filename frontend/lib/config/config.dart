abstract class Config {
  Config._();

  // Cloud Functions URLs
  static const healthCheckUrl = 'https://xxxxxx.a.run.app';
  static const estimatePriceUrl = 'https://xxxxxx.a.run.app';

  // デバッグ用のローカルURL
  // static const String localHealthCheckUrl = 'http://localhost:8080';
  // static const String localEstimatePriceUrl = 'http://localhost:8080';

  // // 本番環境かどうかを判定
  // static const bool isProduction = bool.fromEnvironment('dart.vm.product');

  // // 使用するAPIのURL
  // static String get healthCheckApiUrl =>
  //     isProduction ? healthCheckUrl : localHealthCheckUrl;
  // static String get estimatePriceApiUrl =>
  //     isProduction ? estimatePriceUrl : localEstimatePriceUrl;

  static String get healthCheckApiUrl => healthCheckUrl;
  static String get estimatePriceApiUrl => estimatePriceUrl;
}
