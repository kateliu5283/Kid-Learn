# 小學堂 Kid Learn 📚

結合台灣國小課程（108 課綱）的兒童學習 App，支援 **iOS** 與 **Android** 雙平台，使用 Flutter 開發；搭配 **Laravel 11 + Filament 3** 管理後台，提供題庫 CRUD 與題目同步 API。

## ✨ 功能特色

- 🏠 **首頁儀表板**：今日任務、每日一句、最近學習單元
- 📖 **學科學習**：對應學校六大領域
  - 國語、英語、數學、自然、社會、綜合活動
- 📚 **對標 108 課綱**：內容完全以課綱為依據，不綁定任何教科書版本
  - 國語：小一 ~ 小四（上下學期，共 27 單元）
  - 數學：小一 ~ 小二（上下學期，共 21 單元）
  - 其餘學科：逐步擴充中
- 🎯 **分年級內容**：國小 1–6 年級（可切換）
- 🧩 **互動測驗**：選擇題、填空題、看圖選答，即時回饋
- 📖 **步驟式學習流程**：
  - **預習**：學習目標 → 重點搶先看 → 關鍵字詞
  - **學習**：課程內容 + TTS 朗讀
  - **測驗**：檢驗學習成果
  - **複習**：重點回顧 + 延伸題庫混合題
- ✨ **每日複習**：綜合學過的課程 + 延伸題庫，一天 10 題讓知識更牢固
- 📚 **延伸題庫**：本地超過 150 題 + 後端雲端題庫 380+ 題（可持續新增）
- ☁️ **雲端題庫同步**：App 啟動時自動從 Laravel 後端拉最新題目，並在 `SharedPreferences` 快取，離線也能用
- 🎮 **學習小遊戲**：
  - 🃏 記憶翻牌 Memory Match（國語／英語／數學）
  - ⚡ 數學快閃 Math Blitz（60 秒限時挑戰，依年級調整難度）
  - 🌧️ 單字雨 Word Rain（接英文單字，三條命）
- ✍️ **國字手寫練習**：
  - 用手指在九宮格畫布上描字
  - 內建分年級字庫：數字、基礎字、家人、動物、顏色、情緒
  - 淺字提示、筆刷顏色／粗細、復原與清除、語音發音
- 👥 **多帳號支援**：
  - 一台裝置可建立多位小朋友帳號
  - 每個小朋友獨立保存年級、頭像、學習進度
  - 首頁點頭像即可切換，家長頁可管理／刪除
- 🏆 **成就系統**：學習星星、徽章、連續打卡
- 👨‍👩‍👧 **家長模式**：查看孩子學習進度、單元完成率
- 🔊 **語音朗讀**：內建 TTS，支援中英文發音
- 🎨 **童趣 UI**：圓角、鮮明色彩、大字體、易於點擊

## 📁 專案結構

```
lib/
├── main.dart                 # App 進入點
├── app.dart                  # App 根元件 / 路由
├── theme/
│   └── app_theme.dart        # 主題設定（色彩、字型）
├── models/                   # 資料模型
│   ├── subject.dart
│   ├── lesson.dart
│   ├── question.dart
│   └── user_progress.dart
├── data/
│   ├── curriculum_data.dart      # 課程資料（108 課綱對應）
│   ├── chinese_lessons.dart      # 國語課文（對標 108 課綱）
│   ├── math_lessons.dart         # 數學課文（對標 108 課綱）
│   ├── character_sets.dart       # 國字手寫練習字庫
│   └── review_question_pool.dart # 延伸題庫（按學科×年級）
├── providers/
│   └── progress_provider.dart # 學習進度狀態管理
├── services/                 # 雲端 API 與快取
│   ├── api_config.dart
│   ├── curriculum_api.dart       # 呼叫後端 /api/v1 的 HTTP client
│   └── remote_question_repository.dart # 遠端題庫 + SharedPreferences 快取
├── screens/                  # 主要畫面
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── subjects_screen.dart
│   ├── lesson_list_screen.dart
│   ├── lesson_detail_screen.dart # 課程步驟導覽：預習／學習／測驗／複習
│   ├── quiz_screen.dart
│   ├── lesson/                   # 預習／學習／複習子畫面
│   │   ├── preview_screen.dart
│   │   ├── lesson_study_screen.dart
│   │   ├── review_screen.dart
│   │   └── daily_review_hub.dart
│   ├── achievements_screen.dart
│   ├── parent_screen.dart
│   ├── main_scaffold.dart
│   ├── profile/              # 多帳號：選擇 / 新增 / 編輯
│   │   ├── profile_select_screen.dart
│   │   └── profile_edit_sheet.dart
│   ├── games/                # 學習小遊戲
│   │   ├── games_hub_screen.dart
│   │   ├── memory_match_game.dart
│   │   ├── math_blitz_game.dart
│   │   └── word_rain_game.dart
│   └── handwriting/          # 國字手寫練習
│       ├── handwriting_hub_screen.dart
│       ├── handwriting_practice_screen.dart
│       └── handwriting_canvas.dart
└── widgets/                  # 共用元件
    ├── subject_card.dart
    ├── lesson_tile.dart
    ├── progress_ring.dart
    └── kid_button.dart

backend/                      # Laravel 11 + Filament 3 後端（詳 backend/README.md）
├── app/
│   ├── Filament/Resources/   # 管理後台 CRUD（學科／課程／題目）
│   ├── Http/Controllers/Api/CurriculumController.php  # 題庫 API
│   └── Models/               # Subject / Lesson / Question / VocabularyItem
├── database/
│   ├── data/science_g1_sync.php  # 小一自然課程（與 lib/data/science_g1_lessons.dart 對齊）
│   ├── migrations/           # subjects / lessons / questions / vocabulary_items
│   └── seeders/              # 題庫 + ScienceG1CurriculumSeeder 等
└── routes/api.php            # /api/v1/*
```

## 🚀 快速開始

### 1. 安裝 Flutter SDK

請參考官方文件安裝 Flutter（>= 3.19）：
<https://docs.flutter.dev/get-started/install>

macOS 可使用 Homebrew：
```bash
brew install --cask flutter
```

安裝後確認：
```bash
flutter --version
flutter doctor
```

### 2. 產生原生平台資料夾

首次在本專案執行（會產生 `android/` 和 `ios/` 資料夾）：
```bash
cd /Users/kateliu/Documents/Code/child
flutter create . --project-name kid_learn --org tw.kidlearn --platforms=ios,android
```

### 3. 安裝相依套件

```bash
flutter pub get
```

### 4. 執行 App

```bash
# iOS 模擬器
open -a Simulator
flutter run

# Android 模擬器
flutter emulators --launch <emulator_id>
flutter run

# 或指定裝置
flutter devices
flutter run -d <device_id>
```

### 5. 打包發行

```bash
# Android APK
flutter build apk --release

# iOS (需要 Apple Developer 帳號)
flutter build ios --release
```

### 6. 連接後端（Laravel + Filament 管理後台 + MySQL）

先建 MySQL 資料庫（假設已安裝 MySQL 8+）：

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS kid_learn CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

然後：

```bash
cd backend
composer install
cp .env.example .env && php artisan key:generate   # 第一次
# 編輯 .env 的 DB_PASSWORD 填入你的 MySQL 密碼
php artisan migrate:fresh --seed                   # 建表 + 匯入題庫與課程（含小一自然 11 單元）
php artisan serve                                  # http://127.0.0.1:8000
```

小一自然課程與 App 內 `science_g1_lessons` 使用相同 `code`（例如 `science-g1-plants`）。**以檔案為準同步進資料庫**：先改 `lib/data/science_g1_lessons.dart` 與 `backend/database/data/science_g1_sync.php` 保持一致，再執行 `php artisan db:seed --class=ScienceG1CurriculumSeeder`（會依該 PHP 檔 `updateOrCreate` 課程與題目）。若只在 Filament 改 DB、未改上述檔案，下次執行該 Seeder 時內容會被檔案覆寫。

管理後台：<http://127.0.0.1:8000/admin>
- 預設帳號：`admin@kidlearn.local`
- 預設密碼：`password`

Flutter 連後端時的 BaseUrl（在 `lib/services/api_config.dart`）：

| 環境           | URL                                  |
| -------------- | ------------------------------------ |
| Web / iOS 模擬器 | `http://127.0.0.1:8000/api/v1`       |
| Android 模擬器 | `http://10.0.2.2:8000/api/v1`        |
| 實機           | `http://<電腦內網 IP>:8000/api/v1`   |

也可以用編譯參數指定：

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

更多後端說明見 [`backend/README.md`](backend/README.md)。

## 🎨 設計理念

- **以孩子為中心**：介面大、按鈕大、文字大，6 歲以上即可獨立操作
- **即時回饋**：答題後立即顯示正確／錯誤與解說
- **獎勵導向**：完成單元解鎖星星、徽章，增加學習動機
- **家校整合**：家長／老師可查看進度，對照校內課程進度

## 🧱 技術棧

**前端（App）**
- Flutter 3.19+（Material 3）
- Provider 狀態管理
- shared_preferences 本地儲存 / 快取
- http HTTP client（呼叫 Laravel API）
- google_fonts（Noto Sans TC）
- flutter_tts 語音朗讀
- confetti 慶祝動畫

**後端（API + 管理後台）**
- Laravel 11（PHP 8.2+）
- Filament 3（管理後台）
- MySQL 8+（utf8mb4）
- Laravel Sanctum（API Token 驗證，未來付費功能使用）

## 📋 待辦（未來版本）

- [x] 多帳號（多孩子）
- [x] 預習 / 複習 / 每日複習
- [x] 延伸題庫（本地 + 雲端）
- [x] 手寫筆跡練習（國字）
- [x] **Laravel + Filament 管理後台**（可新增／編輯題目）
- [x] **REST API + App 端快取同步**
- [ ] 付費機制（目前後端已預留 `is_premium` 欄位，暫不啟用）
- [ ] 老師後台派作業
- [ ] 離線下載單元
- [ ] 手寫筆順比對（用軌跡辨識正確性）
- [ ] 家長控管（使用時間）
- [ ] 為更多課程補齊 objectives / keyPoints / vocabulary
- [ ] 題庫 CSV 匯入／匯出

## 📜 License

MIT
