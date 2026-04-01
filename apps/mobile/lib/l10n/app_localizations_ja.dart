// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Osmo コントローラー';

  @override
  String get navController => 'コントローラー';

  @override
  String get navDebug => 'デバッグ';

  @override
  String get navGps => 'GPS';

  @override
  String get navSettings => '設定';

  @override
  String get gpsSettings => 'GPS 設定';

  @override
  String get gpsAcquisition => 'GPS 取得';

  @override
  String get enableGps => 'GPS を有効にする';

  @override
  String get gpsAcquiringLocation => '位置情報を取得中';

  @override
  String get gpsDisabled => 'GPS 取得が無効です';

  @override
  String get locationPermissionDenied => '位置情報の権限が拒否されました';

  @override
  String get allowLocationInSettings => 'システム設定で位置情報へのアクセスを許可してください';

  @override
  String get currentLocation => '現在地';

  @override
  String get latitude => '緯度';

  @override
  String get longitude => '経度';

  @override
  String get altitude => '高度';

  @override
  String get accuracy => '精度';

  @override
  String get time => '時刻';

  @override
  String get noLocationData => '位置情報がありません';

  @override
  String get autoPush => '自動送信';

  @override
  String get enableGpsAutoPush => 'GPS 自動送信を有効にする';

  @override
  String get autoPushDescription => '携帯電話のGPS位置をデバイスに自動送信';

  @override
  String pushFrequency(String frequency) {
    return '送信頻度: $frequency';
  }

  @override
  String get pushNow => '現在地を送信';

  @override
  String get settings => '設定';

  @override
  String get debugSection => 'デバッグ';

  @override
  String get simulateDeviceMode => 'デバイスシミュレーションモード';

  @override
  String get simulateDeviceModeDescription => '実際のハードウェアなしで仮想デバイスを使用してUIデモを実行';

  @override
  String get aboutSection => 'このアプリについて';

  @override
  String get aboutAppTitle => 'Osmo コントローラー';

  @override
  String get aboutAppSubtitle => 'Osmo デバイス Flutter コントローラー v1.0.0';

  @override
  String get openSourceLicenses => 'オープンソースライセンス';

  @override
  String get debugConsole => 'デバッグコンソール';

  @override
  String get clearLogs => 'ログをクリア';

  @override
  String get noLogs => 'ログがありません';

  @override
  String get queryVersion => 'バージョン照会';

  @override
  String get startRecording => '録画開始';

  @override
  String get stopRecording => '録画停止';

  @override
  String get switchToPhoto => '写真モードに切り替え';

  @override
  String get sleep => 'スリープ';

  @override
  String get enterHexCommand => '16進数コマンドを入力 (例: 55 12 00 ...)';

  @override
  String get send => '送信';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get scanDevices => 'デバイスをスキャン';

  @override
  String searchingFor(String deviceName) {
    return '$deviceName を検索中...';
  }

  @override
  String get bluetoothDisabled => 'Bluetoothが無効です。Bluetoothを有効にして再試行してください';

  @override
  String get gotIt => '了解';

  @override
  String get scanningDevices => '近くのデバイスをスキャン中...';

  @override
  String get noDevicesFound => 'デバイスが見つかりません';

  @override
  String get previouslyConnected => '接続履歴あり';

  @override
  String get connect => '接続';

  @override
  String get connectionFailed => '接続に失敗しました。再試行してください';

  @override
  String get battery => 'バッテリー';

  @override
  String get storage => 'ストレージ';

  @override
  String get remaining => '残り';

  @override
  String get recording => '録画';

  @override
  String get temperature => '温度';

  @override
  String get overheating => '過熱';

  @override
  String get normal => '正常';

  @override
  String get status => 'ステータス';

  @override
  String get power => '電源';

  @override
  String get stop => '停止';

  @override
  String get photo => '写真';

  @override
  String get record => '録画';

  @override
  String get gpsNotEnabled => '無効';

  @override
  String get gpsAcquiring => '取得中';

  @override
  String get resolution => '解像度';

  @override
  String get frameRate => 'fps';

  @override
  String get eisMode => '手ブレ';

  @override
  String get pushInterval => '送信間隔';

  @override
  String get interval2s => '2秒';

  @override
  String get interval5s => '5秒';

  @override
  String get interval10s => '10秒';

  @override
  String get disconnected => '未接続';

  @override
  String get positionInfo => '位置情報';

  @override
  String get speedInfo => '速度情報';

  @override
  String get accuracyInfo => '精度情報';

  @override
  String get speed => '速度';

  @override
  String get speedNorth => '北向速度';

  @override
  String get speedEast => '東向速度';

  @override
  String get horizontalAccuracy => '水平精度';

  @override
  String get verticalAccuracy => '垂直精度';

  @override
  String get speedAccuracy => '速度精度';

  @override
  String get satelliteCount => '衛星数';

  @override
  String get notAvailable => '--';
}
