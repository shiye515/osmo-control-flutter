/// Camera status model parsed from 0x1D02 status push.
class CameraStatusModel {
  // Basic status
  final int cameraMode;           // 0x00=SlowMotion, 0x01=Video, 0x05=Photo, etc.
  final int cameraStatus;         // 0=screen off, 1=live/idle, 2=playback, 3=recording, 5=pre-recording
  final int powerMode;            // 0=normal, 3=sleep

  // Video/Photo settings
  final int videoResolution;      // Resolution index
  final int fpsIdx;               // Frame rate / burst count / slow motion multiplier
  final int eisMode;              // EIS mode
  final int photoRatio;           // Photo ratio

  // Recording
  final bool isRecording;
  final int recordTimeSec;        // Recording time in seconds

  // Storage
  final int remainCapacityMB;     // SD card remaining capacity (MB)
  final int remainPhotoNum;       // Remaining photo count
  final int remainTimeSec;        // Remaining recording time (seconds)

  // Battery
  final int batteryPercent;       // 0-100

  // Timelapse
  final int timelapseInterval;    // Timelapse interval
  final int timelapseDuration;    // Timelapse duration
  final int realTimeCountdown;    // Real-time countdown

  // Temperature
  final int tempOver;             // Temperature status (0=normal, 1=overheating)

  // User mode
  final int userMode;             // User mode

  // Others
  final int cameraModeNextFlag;   // Mode switch flag
  final int photoCountdownMs;     // Photo countdown (milliseconds)
  final int loopRecordSecs;       // Loop recording duration

  const CameraStatusModel({
    this.cameraMode = 0,
    this.cameraStatus = 0,
    this.powerMode = 0,
    this.videoResolution = 0,
    this.fpsIdx = 0,
    this.eisMode = 0,
    this.photoRatio = 0,
    this.isRecording = false,
    this.recordTimeSec = 0,
    this.remainCapacityMB = 0,
    this.remainPhotoNum = 0,
    this.remainTimeSec = 0,
    this.batteryPercent = 0,
    this.timelapseInterval = 0,
    this.timelapseDuration = 0,
    this.realTimeCountdown = 0,
    this.tempOver = 0,
    this.userMode = 0,
    this.cameraModeNextFlag = 0,
    this.photoCountdownMs = 0,
    this.loopRecordSecs = 0,
  });

  /// Parse from 1D02 payload bytes.
  static CameraStatusModel fromPayload(List<int> payload) {
    // Log payload length for debugging
    // payload[0]=cameraMode, payload[1]=cameraStatus, payload[2]=resolution, payload[3]=fpsIdx

    return CameraStatusModel(
      cameraMode: payload.isNotEmpty ? payload[0] : 0,
      cameraStatus: payload.length > 1 ? payload[1] : 0,
      videoResolution: payload.length > 2 ? payload[2] : 0,
      fpsIdx: payload.length > 3 ? payload[3] : 0,
      eisMode: payload.length > 4 ? payload[4] : 0,
      recordTimeSec: payload.length > 6 ? payload[5] | (payload[6] << 8) : 0,
      photoRatio: payload.length > 8 ? payload[8] : 0,
      realTimeCountdown: payload.length > 10 ? payload[9] | (payload[10] << 8) : 0,
      timelapseInterval: payload.length > 12 ? payload[11] | (payload[12] << 8) : 0,
      timelapseDuration: payload.length > 14 ? payload[13] | (payload[14] << 8) : 0,
      remainCapacityMB: payload.length > 19
          ? payload[15] | (payload[16] << 8) | (payload[17] << 16) | (payload[18] << 24)
          : 0,
      remainPhotoNum: payload.length > 23
          ? payload[19] | (payload[20] << 8) | (payload[21] << 16) | (payload[22] << 24)
          : 0,
      remainTimeSec: payload.length > 27
          ? payload[23] | (payload[24] << 8) | (payload[25] << 16) | (payload[26] << 24)
          : 0,
      userMode: payload.length > 27 ? payload[27] : 0,
      powerMode: payload.length > 28 ? payload[28] : 0,
      cameraModeNextFlag: payload.length > 29 ? payload[29] : 0,
      tempOver: payload.length > 30 ? payload[30] : 0,
      photoCountdownMs: payload.length > 35
          ? payload[31] | (payload[32] << 8) | (payload[33] << 16) | (payload[34] << 24)
          : 0,
      loopRecordSecs: payload.length > 37 ? payload[35] | (payload[36] << 8) : 0,
      batteryPercent: payload.length > 37 ? payload[37] : 0,
      isRecording: payload.length > 1 ? payload[1] == 3 : false,
    );
  }

  CameraStatusModel copyWith({
    int? cameraMode,
    int? cameraStatus,
    int? powerMode,
    int? videoResolution,
    int? fpsIdx,
    int? eisMode,
    int? photoRatio,
    bool? isRecording,
    int? recordTimeSec,
    int? remainCapacityMB,
    int? remainPhotoNum,
    int? remainTimeSec,
    int? batteryPercent,
    int? timelapseInterval,
    int? timelapseDuration,
    int? realTimeCountdown,
    int? tempOver,
    int? userMode,
    int? cameraModeNextFlag,
    int? photoCountdownMs,
    int? loopRecordSecs,
  }) {
    return CameraStatusModel(
      cameraMode: cameraMode ?? this.cameraMode,
      cameraStatus: cameraStatus ?? this.cameraStatus,
      powerMode: powerMode ?? this.powerMode,
      videoResolution: videoResolution ?? this.videoResolution,
      fpsIdx: fpsIdx ?? this.fpsIdx,
      eisMode: eisMode ?? this.eisMode,
      photoRatio: photoRatio ?? this.photoRatio,
      isRecording: isRecording ?? this.isRecording,
      recordTimeSec: recordTimeSec ?? this.recordTimeSec,
      remainCapacityMB: remainCapacityMB ?? this.remainCapacityMB,
      remainPhotoNum: remainPhotoNum ?? this.remainPhotoNum,
      remainTimeSec: remainTimeSec ?? this.remainTimeSec,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      timelapseInterval: timelapseInterval ?? this.timelapseInterval,
      timelapseDuration: timelapseDuration ?? this.timelapseDuration,
      realTimeCountdown: realTimeCountdown ?? this.realTimeCountdown,
      tempOver: tempOver ?? this.tempOver,
      userMode: userMode ?? this.userMode,
      cameraModeNextFlag: cameraModeNextFlag ?? this.cameraModeNextFlag,
      photoCountdownMs: photoCountdownMs ?? this.photoCountdownMs,
      loopRecordSecs: loopRecordSecs ?? this.loopRecordSecs,
    );
  }

  // Formatted getters

  /// Battery display string (e.g., "85%")
  String get batteryDisplay => '$batteryPercent%';

  /// Storage display string (e.g., "32.5GB")
  String get storageDisplay {
    final gb = remainCapacityMB / 1024;
    return '${gb.toStringAsFixed(1)}GB';
  }

  /// Remaining recording time display (e.g., "2h30m")
  String get remainTimeDisplay {
    final hours = remainTimeSec ~/ 3600;
    final minutes = (remainTimeSec % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h${minutes}m';
    }
    return '${minutes}m';
  }

  /// Recording time display (e.g., "00:05:23")
  String get recordTimeDisplay {
    final hours = recordTimeSec ~/ 3600;
    final minutes = (recordTimeSec % 3600) ~/ 60;
    final seconds = recordTimeSec % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Camera mode display name
  String get cameraModeDisplay {
    switch (cameraMode) {
      case 0x00: return '慢动作';
      case 0x01: return '视频';
      case 0x02: return '静止延时';
      case 0x05: return '拍照';
      case 0x0A: return '运动延时';
      case 0x28: return '低光视频';
      case 0x34: return '人物跟随';
      default: return '视频';
    }
  }

  /// Camera status display name
  String get cameraStatusDisplay {
    switch (cameraStatus) {
      case 0: return '屏幕关闭';
      case 1: return '空闲';
      case 2: return '回放';
      case 3: return '录制中';
      case 5: return '预录制';
      default: return '未知';
    }
  }

  /// Resolution display name
  String get resolutionDisplay {
    // Mapping from DJI R SDK protocol documentation
    switch (videoResolution) {
      case 10: return '1080P';
      case 16: return '4K';
      case 45: return '2.7K';
      case 66: return '1080P 9:16';
      case 67: return '2.7K 9:16';
      case 95: return '2.7K 4:3';
      case 103: return '4K 4:3';
      case 109: return '4K 9:16';
      // Photo ratio (Osmo Action)
      case 4: return 'L';
      case 3: return 'M';
      // Photo ratio (Osmo 360)
      case 2: return '12MP';
      default: return videoResolution.toString();
    }
  }

  /// FPS display string
  String get fpsDisplay {
    // Mapping from DJI R SDK protocol documentation
    switch (fpsIdx) {
      case 1: return '24fps';
      case 2: return '25fps';
      case 3: return '30fps';
      case 4: return '48fps';
      case 5: return '50fps';
      case 6: return '60fps';
      case 7: return '120fps';
      case 8: return '240fps';
      case 10: return '100fps';
      case 19: return '200fps';
      default: return '${fpsIdx}fps';
    }
  }

  /// EIS mode display name
  String get eisModeDisplay {
    // Mapping from DJI R SDK protocol documentation
    // 0: OFF, 1: RS (RockSteady), 2: HS (HorizonSteady), 3: RS+, 4: HB (HorizonBalancing)
    switch (eisMode) {
      case 0: return 'OFF';
      case 1: return 'RS';
      case 2: return 'HS';
      case 3: return 'RS+';
      case 4: return 'HB';
      default: return 'OFF';
    }
  }

  /// Temperature status
  bool get isOverheating => tempOver > 0;

  /// Is sleeping
  bool get isSleeping => powerMode == 3;
}