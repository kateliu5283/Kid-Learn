# Kid Learn Backend (Laravel 11 + Filament 3)

這是「小學堂 Kid Learn」的後端服務，負責：

1. **題庫／課程管理 API**：Flutter app 透過 `GET /api/v1/*` 拉取最新題目和課程。
2. **網頁端管理後台（Filament）**：老師／內容管理員可以在瀏覽器新增、編輯、上下架題目，無需改 code。

## 技術堆疊

| 層       | 選擇                              |
| -------- | --------------------------------- |
| 框架     | Laravel 11                        |
| 管理後台 | Filament 3                        |
| 資料庫   | **MySQL 8+（utf8mb4）**           |
| API 認證 | Laravel Sanctum（預留）           |
| PHP      | 8.2+                              |

## 目錄結構重點

```
backend/
├── app/
│   ├── Filament/Resources/          # 管理後台各資源
│   │   ├── SubjectResource.php        # 學科 CRUD
│   │   ├── LessonResource.php         # 課程單元 CRUD
│   │   │   └── RelationManagers/
│   │   │       ├── QuestionsRelationManager.php      # 在課程頁直接管題目
│   │   │       └── VocabularyItemsRelationManager.php# 在課程頁直接管字詞
│   │   └── QuestionResource.php       # 題目總覽 CRUD
│   ├── Http/Controllers/Api/
│   │   └── CurriculumController.php   # 題庫／課程 API 實作
│   ├── Models/
│   │   ├── Subject.php
│   │   ├── Lesson.php
│   │   ├── Question.php
│   │   └── VocabularyItem.php
│   └── Providers/Filament/
│       └── AdminPanelProvider.php
├── database/
│   ├── migrations/
│   │   ├── *_create_subjects_table.php
│   │   ├── *_create_lessons_table.php
│   │   ├── *_create_questions_table.php
│   │   └── *_create_vocabulary_items_table.php
│   ├── data/
│   │   └── science_g1_sync.php        # 與 Flutter 同步的小一自然課程＋題目（見下）
│   └── seeders/
│       ├── DatabaseSeeder.php         # 建立 admin 帳號 + 呼叫以下 seeders
│       ├── SubjectSeeder.php          # 6 個學科
│       ├── LessonSeeder.php           # 範例課程（國／數／英／社）
│       ├── ScienceG1CurriculumSeeder.php # 小一自然 11 課（code 與 App 一致）
│       └── QuestionBankSeeder.php     # 380+ 題題庫（含未綁單元之綜合題）
└── routes/
    ├── api.php                        # Flutter 用的 REST API
    └── web.php                        # Filament 登入頁面會自動註冊
```

## 快速啟動

### 1. 安裝依賴（第一次）

```bash
cd backend
composer install
cp .env.example .env         # 若還沒有 .env
php artisan key:generate
```

### 2. 建立資料庫 + 匯入題庫

預設使用 MySQL。先建立資料庫（utf8mb4）：

```bash
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS kid_learn CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

確認 `.env` 裡的連線設定（預設）：

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=kid_learn
DB_USERNAME=root
DB_PASSWORD=         # ← 填你的 MySQL 密碼
```

然後建表 + 種入題庫：

```bash
php artisan migrate:fresh --seed
```

這會建立資料表，並種入 **6 個學科、示範課程（含與 App 同步的小一自然 11 單元）、380+ 題題目**（另含約 30 題綁定小一自然各課）以及一個 admin 帳號：

**與 Flutter 課程同步（小一自然）**：請維護 `database/data/science_g1_sync.php`，並與專案根目錄 `lib/data/science_g1_lessons.dart` 對齊（`code` = App 的 `Lesson.id`）。變更後執行 `php artisan db:seed --class=ScienceG1CurriculumSeeder` 或整體 `migrate:fresh --seed`。

| 帳號                       | 密碼       |
| -------------------------- | ---------- |
| `admin@kidlearn.local`     | `password` |

### 3. 啟動開發伺服器

```bash
php artisan serve
```

Server 預設跑在 <http://127.0.0.1:8000>。

- 後台（Filament）： <http://127.0.0.1:8000/admin>
- API 健康檢查： <http://127.0.0.1:8000/api/v1/ping>

## API 清單

所有 endpoints 都在 `/api/v1` 下：

| Method | 路徑                    | 說明                                  |
| ------ | ----------------------- | ------------------------------------- |
| GET    | `/ping`                 | 健康檢查                              |
| GET    | `/subjects`             | 取得所有學科                          |
| GET    | `/lessons`              | 取得課程列表，可用 `?subject=math&grade=1&semester=first` 過濾 |
| GET    | `/lessons/{code}`       | 單一課程詳情（含該課所有題目 + 字詞） |
| GET    | `/questions`            | 取得題目，可用 `?subject=math&grade=2&random=1&limit=10` |
| GET    | `/snapshot`             | 一次抓整份快照（學科、課程、免費題目）給 Flutter app 做本地快取 |

### 範例

```bash
curl "http://127.0.0.1:8000/api/v1/questions?subject=math&grade=1&random=1&limit=5"
```

## 管理後台操作

登入 <http://127.0.0.1:8000/admin> 後，左側會有：

- **學科**：6 個預設學科，可改名字、顏色、圖示。
- **課程單元**：課程總覽，打開任何一課可以直接在頁面下方 **同時編輯** 該課的題目與關鍵字詞（Relation Manager）。
- **題目**：所有題目總覽，可依學科／年級／難度／發佈狀態過濾，支援批次發佈／下架。

## 資料庫 Schema 摘要

### `subjects`
- `code` (unique) - chinese / math / english / science / social / life
- `name`, `english_name`, `icon`, `color`, `description`

### `lessons`
- `code` (unique) - 例：`cl-m-1-1-u1`
- `subject_id`, `grade`, `semester`, `unit`, `track`
- `title`, `summary`, `content`
- `objectives` (JSON), `key_points` (JSON)
- `is_published`, `is_premium`

### `questions`
- `code` (unique) - 例：`q-math-1-001`
- `subject_id`, `lesson_id` (nullable), `grade`
- `type` (multiple_choice / true_false / fill_blank), `difficulty`
- `prompt`, `options` (JSON), `correct_index`
- `explanation`, `is_published`, `is_premium`

### `vocabulary_items`
- `lesson_id`, `term`, `meaning`, `example`, `sort`

## 未來擴充

- [ ] 付費機制（`is_premium=true` 的內容需要登入 + 訂閱）
- [ ] 多媒體題目（圖片、音檔上傳）
- [ ] 老師帳號權限分級
- [ ] 學生答題紀錄 API（讓 Flutter 可以上傳成績到雲端）
- [ ] 匯入／匯出題庫 CSV
