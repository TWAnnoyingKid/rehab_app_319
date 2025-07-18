# iOS 權限測試指南 - 已添加調試工具

## 🛠 調試工具已添加

**已在登入頁面添加 iOS 權限測試按鈕：**
- 橙色按鈕「iOS 權限測試」
- 只在 iOS 平台上顯示
- 點擊後可進入詳細的權限調試界面

## 📱 iOS 權限檢查清單

### ✅ 配置檢查

**Info.plist 配置已正確設定：**
- ✅ NSCameraUsageDescription - 相機權限描述
- ✅ NSMicrophoneUsageDescription - 麥克風權限描述

### 🧪 iOS 權限測試步驟

#### 方法 1: 使用新增的調試工具
1. 在 iOS 設備上運行應用程式
2. 進入登入頁面
3. 點擊橙色的「iOS 權限測試」按鈕
4. 在調試界面中：
   - 查看權限當前狀態
   - 點擊「請求」按鈕測試單個權限
   - 點擊「強制請求」測試所有權限
   - 查看詳細的調試日誌

#### 方法 2: 完全重置測試
```bash
# 1. 完全刪除應用程式（長按圖標 → 刪除APP）
# 2. 重新安裝應用程式
# 3. 首次開啟並登入
```

#### 方法 3: 權限重置測試
在 iOS 設定中重置權限：
```
設定 → 一般 → 傳送或重置 iPhone → 重置 → 重置位置與隱私權
```

#### 方法 4: 手動權限檢查
檢查應用程式權限狀態：
```
設定 → 隱私權與安全性 → 相機 → 復健APP
設定 → 隱私權與安全性 → 麥克風 → 復健APP
```

### 🔍 調試方法

#### 方法 1: 使用權限測試工具
在登入頁面添加測試按鈕來直接測試權限：

```dart
// 在登入頁面臨時添加測試按鈕
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PermissionTestWidget()),
    );
  },
  child: Text('測試權限'),
)
```

#### 方法 2: 檢查 Xcode 控制台
使用 Xcode 運行應用程式並查看控制台輸出：
```
檢查權限 Permission.camera: PermissionStatus.denied
正在請求權限: Permission.camera
權限請求結果: PermissionStatus.granted
```

#### 方法 3: 強制權限請求測試
可以在應用程式中添加強制權限請求按鈕進行測試。

### ⚠️ iOS 特殊注意事項

1. **iOS 模擬器限制**
   - 某些權限在模擬器上無法正常測試
   - 建議使用真實 iOS 設備測試

2. **權限請求時機**
   - iOS 要求在實際使用功能時才能請求權限
   - 批量權限請求可能被系統拒絕

3. **權限狀態檢查**
   - `Permission.status` 在 iOS 上可能返回 `denied` 而不是 `notDetermined`
   - 需要實際調用 `request()` 才能觸發系統權限對話框

### 🛠 故障排除

#### 如果 iOS 不顯示權限請求：

1. **檢查 Info.plist**
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>此應用程式需要使用相機進行復健動作檢測和分析</string>
   <key>NSMicrophoneUsageDescription</key>
   <string>此應用程式需要使用麥克風進行語音識別和音頻分析</string>
   ```

2. **檢查權限狀態**
   ```dart
   // 添加詳細日誌
   PermissionStatus cameraStatus = await Permission.camera.status;
   PermissionStatus micStatus = await Permission.microphone.status;
   print('iOS 相機權限狀態: $cameraStatus');
   print('iOS 麥克風權限狀態: $micStatus');
   ```

3. **強制權限請求**
   ```dart
   // 不檢查狀態，直接請求
   await Permission.camera.request();
   await Permission.microphone.request();
   ```

### 📋 測試檢查表

- [ ] 使用新增的 iOS 權限調試工具測試
- [ ] 檢查調試日誌中的權限狀態
- [ ] 測試強制權限請求功能
- [ ] 應用程式完全刪除並重新安裝
- [ ] Info.plist 包含正確的權限描述
- [ ] 使用真實 iOS 設備（非模擬器）
- [ ] 檢查 Xcode 控制台日誌
- [ ] 手動檢查 iOS 設定中的應用程式權限
- [ ] 測試權限重置後的行為

### 🎯 預期行為

**首次安裝並登入時：**
1. 顯示權限說明對話框
2. 用戶點擊"我知道了"
3. 依序顯示 iOS 系統權限對話框：
   - 相機權限請求
   - 麥克風權限請求
4. 用戶允許權限後進入主頁面

**再次登入時：**
1. 檢查權限狀態
2. 如果已授予，直接進入主頁面
3. 如果缺少權限，只請求缺少的權限
