# DJI Osmo 蓝牙协议文档

> 基于 DJI R SDK 协议，参考官方文档：https://github.com/dji-sdk/Osmo-GPS-Controller-Demo

## 1. BLE 特征值

| 特性 | UUID | 说明 |
|------|------|------|
| Service | 0xFFF0 | Osmo 设备服务 |
| Notify | 0xFFF4 | 相机发送，遥控器接收，需使能通知 |
| Write | 0xFFF5 | 相机接收，遥控器发送 |

**注意**: 遥控器作为 Master（主设备），相机作为 Slave（从设备）。

## 2. DJI R SDK 协议帧结构

```
| SOF | Ver/Length | CmdType | ENC | RES | SEQ | CRC-16 | DATA | CRC-32 |
|-----|-------------|---------|-----|-----|-----|--------|------|--------|
| 1B  | 2B          | 1B      | 1B  | 3B  | 2B  | 2B     | nB   | 4B     |
```

| 区域 | 偏移 | 大小 | 描述 |
|------|------|------|------|
| SOF | 0 | 1 | 帧头固定为 **0xAA** |
| Ver/Length | 1 | 2 | [15:10] 版本号（默认0），[9:0] 帧长度（LSB first） |
| CmdType | 3 | 1 | [4:0] 应答类型，[5] 帧类型（0=命令帧，1=应答帧） |
| ENC | 4 | 1 | [7:5] 加密类型（0=不加密），[4:0] 补充字节长度 |
| RES | 5 | 3 | 保留字节 |
| SEQ | 8 | 2 | 序列号（LSB first） |
| CRC-16 | 10 | 2 | 校验 SOF 到 SEQ 段（前10字节） |
| DATA | 12 | n | CmdSet(1B) + CmdID(1B) + Payload |
| CRC-32 | n+12 | 4 | 校验 SOF 到 DATA 段（整帧减最后4字节） |

**重要**: 整个数据包采用**小端存储**（Little-Endian）。

### CmdType 应答类型

| 值 | 含义 |
|----|------|
| 0 | 发送后不需要应答 |
| 1 | 发送后需要应答，但不应答也没关系 |
| 2-31 | 发送后必须要应答 |

## 3. CRC 校验算法

### 3.1 CRC-16（校验前10字节）

初始值: `0x3aa3`

Lookup Table:
```dart
static const List<int> crc16Table = [
  0x0000, 0xc0c1, 0xc181, 0x0140, 0xc301, 0x03c0, 0x0280, 0xc241,
  0xc601, 0x06c0, 0x0780, 0xc741, 0x0500, 0xc5c1, 0xc481, 0x0440,
  0xcc01, 0x0cc0, 0x0d80, 0xcd41, 0x0f00, 0xcfc1, 0xce81, 0x0e40,
  0x0a00, 0xcac1, 0xcb81, 0x0b40, 0xc901, 0x09c0, 0x0880, 0xc841,
  0xd801, 0x18c0, 0x1980, 0xd941, 0x1b00, 0xdbc1, 0xda81, 0x1a40,
  0x1e00, 0xdec1, 0xdf81, 0x1f40, 0xdd01, 0x1dc0, 0x1c80, 0xdc41,
  0x1400, 0xd4c1, 0xd581, 0x1540, 0xd701, 0x17c0, 0x1680, 0xd641,
  0xd201, 0x12c0, 0x1380, 0xd341, 0x1100, 0xd1c1, 0xd081, 0x1040,
  0xf001, 0x30c0, 0x3180, 0xf141, 0x3300, 0xf3c1, 0xf281, 0x3240,
  0x3600, 0xf6c1, 0xf781, 0x3740, 0xf501, 0x35c0, 0x3480, 0xf441,
  0x3c00, 0xfcc1, 0xfd81, 0x3d40, 0xff01, 0x3fc0, 0x3e80, 0xfe41,
  0xfa01, 0x3ac0, 0x3b80, 0xfb41, 0x3900, 0xf9c1, 0xf881, 0x3840,
  0x2800, 0xe8c1, 0xe981, 0x2940, 0xeb01, 0x2bc0, 0x2a80, 0xea41,
  0xee01, 0x2ec0, 0x2f80, 0xef41, 0x2d00, 0xedc1, 0xec81, 0x2c40,
  0xe401, 0x24c0, 0x2580, 0xe541, 0x2700, 0xe7c1, 0xe681, 0x2640,
  0x2200, 0xe2c1, 0xe381, 0x2340, 0xe101, 0x21c0, 0x2080, 0xe041,
  0xa001, 0x60c0, 0x6180, 0xa141, 0x6300, 0xa3c1, 0xa281, 0x6240,
  0x6600, 0xa6c1, 0xa781, 0x6740, 0xa501, 0x65c0, 0x6480, 0xa441,
  0x6c00, 0xacc1, 0xad81, 0x6d40, 0xaf01, 0x6fc0, 0x6e80, 0xae41,
  0xaa01, 0x6ac0, 0x6b80, 0xab41, 0x6900, 0xa9c1, 0xa881, 0x6840,
  0x7800, 0xb8c1, 0xb981, 0x7940, 0xbb01, 0x7bc0, 0x7a80, 0xba41,
  0xbe01, 0x7ec0, 0x7f80, 0xbf41, 0x7d00, 0xbdc1, 0xbc81, 0x7c40,
  0xb401, 0x74c0, 0x7580, 0xb541, 0x7700, 0xb7c1, 0xb681, 0x7640,
  0x7200, 0xb2c1, 0xb381, 0x7340, 0xb101, 0x71c0, 0x7080, 0xb041,
  0x5000, 0x90c1, 0x9181, 0x5140, 0x9301, 0x53c0, 0x5280, 0x9241,
  0x9601, 0x56c0, 0x5780, 0x9741, 0x5500, 0x95c1, 0x9481, 0x5440,
  0x9c01, 0x5cc0, 0x5d80, 0x9d41, 0x5f00, 0x9fc1, 0x9e81, 0x5e40,
  0x5a00, 0x9ac1, 0x9b81, 0x5b40, 0x9901, 0x59c0, 0x5880, 0x9841,
  0x8801, 0x48c0, 0x4980, 0x8941, 0x4b00, 0x8bc1, 0x8a81, 0x4a40,
  0x4e00, 0x8ec1, 0x8f81, 0x4f40, 0x8d01, 0x4dc0, 0x4c80, 0x8c41,
  0x4400, 0x84c1, 0x8581, 0x4540, 0x8701, 0x47c0, 0x4680, 0x8641,
  0x8201, 0x42c0, 0x4380, 0x8341, 0x4100, 0x81c1, 0x8081, 0x4040
];
```

算法:
```dart
int crc16Update(int crc, List<int> data) {
  for (final byte in data) {
    final tblIdx = (crc ^ byte) & 0xff;
    crc = (crc16Table[tblIdx] ^ (crc >> 8)) & 0xffff;
  }
  return crc;
}

int calculateCrc16(List<int> data) {
  int crc = 0x3aa3; // 初始值
  return crc16Update(crc, data);
}
```

### 3.2 CRC-32（校验整帧减最后4字节）

初始值: `0x00003aa3`

Lookup Table（256个32位值，略，见实现代码）

算法:
```dart
int calculateCrc32(List<int> data) {
  int crc = 0x00003aa3; // 初始值
  for (final byte in data) {
    final tblIdx = (crc ^ byte) & 0xff;
    crc = (crc32Table[tblIdx] ^ (crc >> 8)) & 0xffffffff;
  }
  return crc;
}
```

## 4. DATA 数据段结构

```
| CmdSet | CmdID | Payload |
|--------|-------|---------|
| 1B     | 1B    | (n-2)B  |
```

## 5. 命令集列表

### 5.1 连接请求 (0x00, 0x19)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| device_id | 0 | 4 | uint32 | 发送端设备ID |
| mac_addr_len | 4 | 1 | uint8 | MAC地址长度（6） |
| mac_addr | 5 | 16 | int8[16] | MAC地址 |
| fw_version | 21 | 4 | uint32 | 固件版本（填0） |
| conidx | 25 | 1 | uint8 | 预留 |
| verify_mode | 26 | 1 | uint8 | 0=不需校验，1=需校验，2=校验结果 |
| verify_data | 27 | 2 | uint16 | 校验码 |
| reserved | 29 | 4 | uint8[4] | 预留 |

### 5.2 拍录控制 (0x1D, 0x03)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| device_id | 0 | 4 | uint32 | 设备ID |
| record_ctrl | 4 | 1 | uint8 | 0=开始，1=停止 |
| reserved | 5 | 4 | uint8[4] | 预留 |

### 5.3 模式切换 (0x1D, 0x04)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| device_id | 0 | 4 | uint32 | 设备ID |
| mode | 4 | 1 | uint8 | 目标模式 |
| reserved | 5 | 4 | uint8[4] | 预留 |

### 5.4 相机状态订阅 (0x1D, 0x05)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| push_mode | 0 | 1 | uint8 | 0=关闭，1=单次，2=周期，3=周期+变化 |
| push_freq | 1 | 1 | uint8 | 频率（固定20=2Hz） |
| reserved | 2 | 4 | uint8[4] | 预留 |

### 5.5 相机状态推送 (0x1D, 0x02)

| 字段 | 偏移 | 大小 | 描述 |
|------|------|------|------|
| camera_mode | 0 | 1 | 相机模式 |
| camera_status | 1 | 1 | 0=屏幕关闭，1=直播/亮屏，2=回放，3=录制中，5=预录制 |
| video_resolution | 2 | 1 | 分辨率 |
| fps_idx | 3 | 1 | 帧率/连拍数/慢动作倍率 |
| EIS_mode | 4 | 1 | 增稳模式 |
| record_time | 5 | 2 | 录像时间（秒） |
| photo_ratio | 8 | 1 | 图片比例 |
| real_time_countdown | 9 | 2 | 实时倒计时 |
| timelapse_interval | 11 | 2 | 延时间隔 |
| timelapse_duration | 13 | 2 | 延时时长 |
| remain_capacity | 15 | 4 | SD卡剩余容量（MB） |
| remain_photo_num | 19 | 4 | 剩余拍照张数 |
| remain_time | 23 | 4 | 剩余录像时间（秒） |
| user_mode | 27 | 1 | 用户模式 |
| power_mode | 28 | 1 | 0=正常，3=休眠 |
| camera_mode_next_flag | 29 | 1 | 预切换标志 |
| temp_over | 30 | 1 | 温度状态 |
| photo_countdown_ms | 31 | 4 | 拍照倒计时（毫秒） |
| loop_record_sends | 35 | 2 | 循环录像时长 |
| camera_bat_percentage | 37 | 1 | 电池电量 |

### 5.6 GPS数据推送 (0x00, 0x17)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| year_month_day | 0 | 4 | int32 | year*10000+month*100+day |
| hour_minute_second | 4 | 4 | int32 | (hour+8)*10000+minute*100+second |
| gps_longitude | 8 | 4 | int32 | 经度×10^7 |
| gps_latitude | 12 | 4 | int32 | 纬度×10^7 |
| height | 16 | 4 | int32 | 高度（mm） |
| speed_to_north | 20 | 4 | float | 向北速度（cm/s） |
| speed_to_east | 24 | 4 | float | 向东速度（cm/s） |
| speed_to_downward | 28 | 4 | float | 下降速度（cm/s） |
| vertical_accuracy_estimate | 32 | 4 | uint32 | 垂直精度（mm） |
| horizontal_accuracy_estimate | 36 | 4 | uint32 | 水平精度（mm） |
| speed_accuracy_estimate | 40 | 4 | uint32 | 速度精度（cm/s） |
| satellite_number | 44 | 4 | uint32 | 卫星数量 |

### 5.7 电源模式 (0x00, 0x1A)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| power_mode | 0 | 1 | uint8 | 0=正常，3=休眠 |

### 5.8 按键上报 (0x00, 0x11)

| 字段 | 偏移 | 大小 | 类型 | 描述 |
|------|------|------|------|------|
| key_code | 0 | 1 | uint8 | 0x01=拍录键，0x02=QS键，0x03=快照键 |
| mode | 1 | 1 | uint8 | 0x00=按下/松开，0x01=事件 |
| key_value | 2 | 2 | uint16 | mode=0: 0x00按下/0x01松开；mode=1: 0x00短按/0x01长按/0x02双击 |

## 6. 连接流程

```
步骤1: 遥控器 → 相机: 连接请求 (verify_mode=0或1)
步骤2: 相机 → 遥控器: 连接应答 (立即返回)
步骤3: 相机 → 遥控器: 连接请求 (verify_mode=2, verify_data=0允许/1拒绝)
步骤4: 遥控器 → 相机: 连接应答 (包含相机编号)
```

- 首次配对: verify_mode=1，相机弹窗显示校验码
- 已配对: verify_mode=0，相机自动判断

## 7. 设备ID映射

| 型号 | device_id |
|------|-----------|
| Osmo Action 4 | 0xFF33 |
| Osmo Action 5 Pro | 0xFF44 |
| Osmo Action 6 | 0xFF55 |
| Osmo 360 | 0xFF66 |

## 8. 相机模式值

| camera_mode | 模式 |
|-------------|------|
| 0x00 | 慢动作 |
| 0x01 | 视频 |
| 0x02 | 静止延时 |
| 0x05 | 拍照 |
| 0x0A | 运动延时 |
| 0x28 | 低光视频 |
| 0x34 | 人物跟随 |
| 0x38+ | Osmo 360 特有模式 |

## 9. 休眠唤醒

相机休眠后通过 BLE 广播唤醒：

广播数据: `[10, 0xFF, 'W','K','P', MAC地址(反转)]`

持续时间: 2秒

前提条件: 30分钟内已配对设备

## 10. 帧示例

切换到运动延时模式（camera_mode=0x0A）:

```
AA 1B 00 01 00 00 00 00 05 00 57 EE 1D 04 00 00 33 FF 0A 01 47 39 36 F4 FA E1 D0
```

解析:
- AA: SOF
- 1B 00: 长度27（LSB first）
- 01: CmdType（命令帧，需要应答但可选）
- 00: ENC（不加密）
- 00 00 00: RES
- 05 00: SEQ=5
- 57 EE: CRC-16
- 1D 04: CmdSet/CmdID
- 00 00 33 FF: device_id=0xFF33（Osmo Action 4）
- 0A: mode=运动延时
- 01 47 39 36: reserved
- F4 FA E1 D0: CRC-32