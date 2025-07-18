# iOS 權限問題故障排除指南

## 常見問題和解決方案

### 1. 權限請求不顯示
**可能原因：**
- Info.plist 中缺少權限描述
- 應用程式已經請求過權限並被拒絕
- iOS 版本相容性問題

**解決方案：**
```bash
# 1. 完全刪除應用程式
# 2. 清理建置
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 3. 重新建置和安裝
flutter build ios
```

### 2. 語音識別權限特殊處理
在 iOS 上，語音識別權限需要：
- 正確的 Info.plist 配置
- 在實際使用時請求
- 可能需要用戶手動到設定中開啟

### 3. 檢查權限狀態
使用 Xcode 的控制台查看詳細的權限請求日誌：
```
檢查權限: Permission.microphone
權限狀態: PermissionStatus.denied
正在請求權限: Permission.microphone
權限請求結果: PermissionStatus.granted
```

### 4. 手動檢查 iOS 設定
如果自動權限請求失敗，引導用戶手動開啟：
設定 → 隱私權與安全性 → [相關權限] → 復健APP

### 5. iOS 模擬器注意事項
某些權限在 iOS 模擬器上無法正常測試，建議使用真實設備測試。

## 調試步驟

1. **查看控制台輸出**
   檢查應用程式是否正確輸出權限檢查和請求的日誌

2. **檢查 iOS 設定**
   在 iOS 設定中檢查應用程式的權限狀態

3. **重置權限**
   設定 → 一般 → 傳送或重置 iPhone → 重置 → 重置位置與隱私權

4. **Xcode 調試**
   使用 Xcode 直接運行應用程式，查看更詳細的錯誤信息
