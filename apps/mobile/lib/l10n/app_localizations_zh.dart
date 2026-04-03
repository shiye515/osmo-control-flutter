// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Osmo 遥控器';

  @override
  String get navController => '遥控器';

  @override
  String get navDebug => '调试台';

  @override
  String get navGps => 'GPS';

  @override
  String get navSettings => '设置';

  @override
  String get gpsSettings => 'GPS 设置';

  @override
  String get gpsAcquisition => 'GPS 获取';

  @override
  String get enableGps => '启用 GPS';

  @override
  String get gpsAcquiringLocation => '正在获取位置数据';

  @override
  String get gpsDisabled => 'GPS 数据获取已关闭';

  @override
  String get locationPermissionDenied => '位置权限被拒绝';

  @override
  String get allowLocationInSettings => '请在系统设置中允许位置访问';

  @override
  String get currentLocation => '当前位置';

  @override
  String get latitude => '纬度';

  @override
  String get longitude => '经度';

  @override
  String get altitude => '海拔';

  @override
  String get accuracy => '精度';

  @override
  String get time => '时间';

  @override
  String get noLocationData => '暂无位置数据';

  @override
  String get autoPush => '自动推送';

  @override
  String get enableGpsAutoPush => '启用 GPS 自动推送';

  @override
  String get autoPushDescription => '自动将手机GPS位置推送到设备';

  @override
  String pushFrequency(String frequency) {
    return '推送频率: $frequency';
  }

  @override
  String get pushNow => '立即推送当前位置';

  @override
  String get settings => '设置';

  @override
  String get debugSection => '调试';

  @override
  String get simulateDeviceMode => '模拟设备模式';

  @override
  String get simulateDeviceModeDescription => '无需真实硬件，使用虚拟设备进行界面演示';

  @override
  String get aboutSection => '关于';

  @override
  String get aboutAppTitle => 'Osmo 遥控器';

  @override
  String get aboutAppSubtitle => 'Osmo 设备 Flutter 控制端 v1.0.0';

  @override
  String get openSourceLicenses => '开源许可';

  @override
  String get debugConsole => '调试台';

  @override
  String get clearLogs => '清除日志';

  @override
  String get noLogs => '暂无日志';

  @override
  String get queryVersion => '版本查询';

  @override
  String get startRecording => '开始录制';

  @override
  String get stopRecording => '停止录制';

  @override
  String get switchToPhoto => '切换拍照';

  @override
  String get sleep => '休眠';

  @override
  String get enterHexCommand => '输入十六进制指令 (如: 55 12 00 ...)';

  @override
  String get send => '发送';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get scanDevices => '扫描设备';

  @override
  String searchingFor(String deviceName) {
    return '正在寻找 $deviceName...';
  }

  @override
  String get bluetoothDisabled => '蓝牙未开启，请开启蓝牙后重试';

  @override
  String get gotIt => '知道了';

  @override
  String get scanningDevices => '正在扫描附近设备...';

  @override
  String get noDevicesFound => '未发现设备';

  @override
  String get previouslyConnected => '曾连接';

  @override
  String get connect => '连接';

  @override
  String get connectionFailed => '连接失败，请重试';

  @override
  String get battery => '电量';

  @override
  String get storage => '存储';

  @override
  String get remaining => '剩余';

  @override
  String get recording => '录制';

  @override
  String get temperature => '温度';

  @override
  String get overheating => '过热';

  @override
  String get normal => '正常';

  @override
  String get status => '状态';

  @override
  String get power => '电源';

  @override
  String get stop => '停止';

  @override
  String get photo => '拍照';

  @override
  String get record => '录制';

  @override
  String get gpsNotEnabled => '未启用';

  @override
  String get gpsAcquiring => '获取中';

  @override
  String get resolution => '分辨率';

  @override
  String get frameRate => '帧率';

  @override
  String get eisMode => '增稳';

  @override
  String get pushInterval => '推送间隔';

  @override
  String get interval2s => '2秒';

  @override
  String get interval5s => '5秒';

  @override
  String get interval10s => '10秒';

  @override
  String get disconnected => '未连接';

  @override
  String get positionInfo => '位置信息';

  @override
  String get speedInfo => '速度信息';

  @override
  String get accuracyInfo => '精度信息';

  @override
  String get speed => '速度';

  @override
  String get speedNorth => '向北速度';

  @override
  String get speedEast => '向东速度';

  @override
  String get horizontalAccuracy => '水平精度';

  @override
  String get verticalAccuracy => '垂直精度';

  @override
  String get speedAccuracy => '速度精度';

  @override
  String get satelliteCount => '卫星数量';

  @override
  String get notAvailable => '--';

  @override
  String get userMode => '用户模式';

  @override
  String get remainingPhotos => '剩余张数';

  @override
  String get loopRecording => '循环录像';

  @override
  String get photoCountdown => '拍照倒计时';

  @override
  String get timelapseInterval => '延时间隔';

  @override
  String get disconnect => '断开连接';

  @override
  String get pushDisabled => '推送未开启';

  @override
  String get pushEnabled => '推送已开启';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Osmo 遙控器';

  @override
  String get navController => '遙控器';

  @override
  String get navDebug => '除錯台';

  @override
  String get navGps => 'GPS';

  @override
  String get navSettings => '設定';

  @override
  String get gpsSettings => 'GPS 設定';

  @override
  String get gpsAcquisition => 'GPS 取得';

  @override
  String get enableGps => '啟用 GPS';

  @override
  String get gpsAcquiringLocation => '正在取得位置資料';

  @override
  String get gpsDisabled => 'GPS 資料取得已關閉';

  @override
  String get locationPermissionDenied => '位置權限被拒絕';

  @override
  String get allowLocationInSettings => '請在系統設定中允許位置存取';

  @override
  String get currentLocation => '目前位置';

  @override
  String get latitude => '緯度';

  @override
  String get longitude => '經度';

  @override
  String get altitude => '海拔';

  @override
  String get accuracy => '精度';

  @override
  String get time => '時間';

  @override
  String get noLocationData => '暫無位置資料';

  @override
  String get autoPush => '自動推送';

  @override
  String get enableGpsAutoPush => '啟用 GPS 自動推送';

  @override
  String get autoPushDescription => '自動將手機GPS位置推送到裝置';

  @override
  String pushFrequency(String frequency) {
    return '推送頻率: $frequency';
  }

  @override
  String get pushNow => '立即推送目前位置';

  @override
  String get settings => '設定';

  @override
  String get debugSection => '除錯';

  @override
  String get simulateDeviceMode => '模擬裝置模式';

  @override
  String get simulateDeviceModeDescription => '無需真實硬體，使用虛擬裝置進行介面演示';

  @override
  String get aboutSection => '關於';

  @override
  String get aboutAppTitle => 'Osmo 遙控器';

  @override
  String get aboutAppSubtitle => 'Osmo 裝置 Flutter 控制端 v1.0.0';

  @override
  String get openSourceLicenses => '開源授權';

  @override
  String get debugConsole => '除錯台';

  @override
  String get clearLogs => '清除日誌';

  @override
  String get noLogs => '暫無日誌';

  @override
  String get queryVersion => '版本查詢';

  @override
  String get startRecording => '開始錄製';

  @override
  String get stopRecording => '停止錄製';

  @override
  String get switchToPhoto => '切換拍照';

  @override
  String get sleep => '休眠';

  @override
  String get enterHexCommand => '輸入十六進位指令 (如: 55 12 00 ...)';

  @override
  String get send => '發送';

  @override
  String get copiedToClipboard => '已複製到剪貼簿';

  @override
  String get scanDevices => '掃描裝置';

  @override
  String searchingFor(String deviceName) {
    return '正在尋找 $deviceName...';
  }

  @override
  String get bluetoothDisabled => '藍牙未開啟，請開啟藍牙後重試';

  @override
  String get gotIt => '知道了';

  @override
  String get scanningDevices => '正在掃描附近裝置...';

  @override
  String get noDevicesFound => '未發現裝置';

  @override
  String get previouslyConnected => '曾連接';

  @override
  String get connect => '連接';

  @override
  String get connectionFailed => '連接失敗，請重試';

  @override
  String get battery => '電量';

  @override
  String get storage => '儲存';

  @override
  String get remaining => '剩餘';

  @override
  String get recording => '錄製';

  @override
  String get temperature => '溫度';

  @override
  String get overheating => '過熱';

  @override
  String get normal => '正常';

  @override
  String get status => '狀態';

  @override
  String get power => '電源';

  @override
  String get stop => '停止';

  @override
  String get photo => '拍照';

  @override
  String get record => '錄製';

  @override
  String get gpsNotEnabled => '未啟用';

  @override
  String get gpsAcquiring => '取得中';

  @override
  String get resolution => '解析度';

  @override
  String get frameRate => '幀率';

  @override
  String get eisMode => '增穩';

  @override
  String get pushInterval => '推送間隔';

  @override
  String get interval2s => '2秒';

  @override
  String get interval5s => '5秒';

  @override
  String get interval10s => '10秒';

  @override
  String get disconnected => '未連接';

  @override
  String get positionInfo => '位置資訊';

  @override
  String get speedInfo => '速度資訊';

  @override
  String get accuracyInfo => '精度資訊';

  @override
  String get speed => '速度';

  @override
  String get speedNorth => '向北速度';

  @override
  String get speedEast => '向東速度';

  @override
  String get horizontalAccuracy => '水平精度';

  @override
  String get verticalAccuracy => '垂直精度';

  @override
  String get speedAccuracy => '速度精度';

  @override
  String get satelliteCount => '衛星數量';

  @override
  String get notAvailable => '--';

  @override
  String get userMode => '使用者模式';

  @override
  String get remainingPhotos => '剩餘張數';

  @override
  String get loopRecording => '循環錄製';

  @override
  String get photoCountdown => '拍照倒數';

  @override
  String get timelapseInterval => '延時間隔';

  @override
  String get disconnect => '中斷連線';

  @override
  String get pushDisabled => '推送未開啟';

  @override
  String get pushEnabled => '推送已開啟';
}
