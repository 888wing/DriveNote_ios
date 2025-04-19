# DriveNote iOS MVP

## 項目介紹

DriveNote是為Uber等車輛共乘平台司機設計的收支管理應用，專注於幫助英國地區的司機追蹤收入、支出、里程和工時，並為稅務申報做好準備。

此版本為最小可行產品(MVP)，實現了基本的收支記錄功能和簡化的用戶界面，採用離線優先的設計理念。

## 架構

本項目採用Clean Architecture(乾淨架構)與MVVM(Model-View-ViewModel)設計模式的結合：

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│                 │      │                 │      │                 │
│  Presentation   │◄────►│    Domain       │◄────►│     Data        │
│     Layer       │      │     Layer       │      │     Layer       │
│                 │      │                 │      │                 │
└─────────────────┘      └─────────────────┘      └─────────────────┘
       │                                                  │
       │                                                  │
       ▼                                                  ▼
┌─────────────────┐                             ┌─────────────────┐
│   UI (SwiftUI)  │                             │   Core Data     │
│   ViewModels    │                             │   Firebase      │
└─────────────────┘                             │   Gemini API    │
                                                └─────────────────┘
```

### 層級說明

1. **Presentation Layer**
   - 包含所有UI元素和ViewModels
   - 使用SwiftUI實現界面
   - 遵循MVVM模式組織代碼

2. **Domain Layer**
   - 包含業務邏輯和用例(UseCases)
   - 定義業務實體(Entities)
   - 定義Repository接口(Protocols)

3. **Data Layer**
   - 包含數據源實現(目前僅Local)
   - Repository實現類
   - Core Data管理

## 目前已實現功能

- ✅ 基本支出記錄與查看
- ✅ 支出分類與篩選
- ✅ 稅務信息標記
- ✅ 儀表板視圖基本骨架
- ✅ 工時計時器UI
- ✅ 離線數據存儲(Core Data)
- ✅ 現代化UI設計

## 未實現但已規劃的功能

- 📋 收據拍照與OCR分析
- 📋 里程記錄詳細功能
- 📋 工時記錄保存與查看
- 📋 收入記錄
- 📋 雲端同步(Firebase)
- 📋 稅務報表生成

## 技術規範

### 命名規範

- **類型**：使用駝峰式命名法，首字母大寫 (ExpenseRepository)
- **變量和函數**：使用駝峰式命名法，首字母小寫 (saveExpense)
- **常量**：全部大寫，用下劃線分隔 (MAX_UPLOAD_SIZE)
- **枚舉成員**：使用駝峰式命名法，首字母小寫 (expenseCategory.fuel)

### 文件結構

每個Swift文件應包含：
1. 版權聲明 (如適用)
2. 導入語句
3. 協議聲明
4. 類/結構體實現
5. 擴展

### 注釋

所有公開API必須添加文檔注釋，複雜的私有方法和算法應當有解釋性注釋。

## 開發環境

- Xcode 14.3+
- Swift 5.9+
- iOS 15.0+ (最低支持版本)
- macOS Ventura+

## 開始使用

### 安裝步驟

1. 克隆儲存庫
   ```
   git clone https://github.com/yourusername/drivenote-ios.git
   ```

2. 打開Xcode項目文件
   ```
   open DriveNote.xcodeproj
   ```

3. 選擇目標設備/模擬器並運行

### 編譯說明

對於性能較低的開發機器(如2017 MacBook Pro)：

1. 關閉Xcode中的實時預覽功能
2. 使用單一模擬器實例進行測試
3. 定期清理衍生數據與緩存
4. 考慮使用外部SSD進行開發

## 依賴注入

本項目使用自定義依賴注入容器(DIContainer)來管理依賴關係，可以在`App/DIContainer.swift`中找到。

使用示例：

```swift
// 獲取視圖模型
@StateObject private var viewModel = DIContainer.shared.makeDashboardViewModel()
```

## 開發規範

1. 提交前請確保代碼遵循項目的編碼風格
2. 提交消息應清晰描述更改內容
3. 重要更新應添加單元測試
4. UI更改應確保在不同尺寸的設備上測試

## 參與貢獻

1. Fork項目
2. 創建特性分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 提交Pull Request

## 授權

本項目僅供學習和演示用途，未經授權不得用於商業用途。
