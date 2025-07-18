# iOS RSST 錄音問題解決方案

## ✅ 已實施的修復

### 1. **AudioRecorder 優化**
- **iOS 特殊初始化序列**：添加延遲和多重權限檢查
- **iOS 優化的錄音設定**：
  - 採樣率：16 kHz（相容性更好）
  - 比特率：32 kbps（更保守的設定）
  - 格式：WAV 單聲道
- **增強錯誤處理**：提供 iOS 特定的錯誤訊息

### 2. **RSST 測試頁面優化**
- **提前初始化**：在頁面載入時預先初始化錄音器
- **錯誤訊息改進**：針對 iOS 提供詳細的故障排除指導

## 🔧 技術改進詳情

### AudioRecorder 類改進：
```dart
// iOS 特殊處理
if (Platform.isIOS) {
  print('iOS 平台：準備音頻會話...');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 雙重權限檢查
  var doubleCheckStatus = await Permission.microphone.status;
  if (!doubleCheckStatus.isGranted) {
    throw RecordingPermissionException('iOS 權限狀態不穩定');
  }
  
  // 使用 iOS 優化的錄音設定
  await _recorder.start(
    path: _recordingPath,
    encoder: AudioEncoder.wav,
    bitRate: 32000,        // 32 kbps
    samplingRate: 16000,   // 16 kHz
    numChannels: 1,        // 單聲道
  );
}
```

## 🧪 測試步驟

### 1. **基本測試**
1. 確保麥克風權限已在登入時授予
2. 進入 RSST 測驗頁面
3. 觀察控制台輸出是否顯示：
   ```
   提前初始化錄音器...
   iOS 平台：準備音頻會話...
   iOS 權限狀態確認完成
   錄音器提前初始化完成
   ```

### 2. **權限檢查**
在 iOS 設定中確認：
```
設定 → 隱私權與安全性 → 麥克風 → 復健APP ✅
```

### 3. **故障排除**
如果仍然出現錯誤：

#### A. 重新安裝應用程式
1. 完全刪除應用程式
2. 重新安裝
3. 重新授予麥克風權限

#### B. 檢查音頻會話衝突
1. 關閉所有其他音頻應用程式
2. 重新啟動 iPhone
3. 再次測試

#### C. iOS 版本相容性
- iOS 12.0 以上：完全支援
- iOS 11.x：可能需要額外設定
- iOS 10.x 以下：不支援

## 🔍 錯誤診斷

### 常見錯誤訊息和解決方案：

1. **"錄音初始化失敗，檢查麥克風權限"**
   - **原因**：權限未正確授予或音頻會話衝突
   - **解決**：檢查設定中的麥克風權限，重啟應用程式

2. **"iOS 權限狀態不穩定"**
   - **原因**：權限授予後 iOS 需要時間更新狀態
   - **解決**：重新啟動應用程式

3. **"無法獲得錄音權限"**
   - **原因**：其他應用程式正在使用麥克風
   - **解決**：關閉其他音頻應用程式

## 📋 調試檢查清單

### 檢查項目：
- [ ] 應用程式具有麥克風權限（設定中確認）
- [ ] 沒有其他應用程式使用麥克風
- [ ] iOS 版本 12.0 以上
- [ ] 應用程式完全重啟
- [ ] 控制台顯示成功的初始化訊息

### 如果問題持續：
1. **使用 iOS 權限調試工具**（登入頁面的橙色按鈕）
2. **檢查 Xcode 控制台**的詳細錯誤訊息
3. **重置 iPhone 的位置與隱私權設定**

## 💡 預防措施

1. **在應用程式啟動時初始化音頻**
2. **使用保守的錄音設定**
3. **提供清楚的用戶指導**
4. **實施強健的錯誤處理**

這些改進應該能解決大部分 iOS 錄音初始化問題。如果問題持續，請使用 iOS 權限調試工具進行詳細診斷。
