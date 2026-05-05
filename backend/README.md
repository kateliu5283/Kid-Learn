# Kid Learn Backend (Laravel 11 + Filament 3)

這是「小學堂 Kid Learn」的後端服務，負責：

1. **API Gateway（`/api/v1`）**：依業務模組分區（**Content** 題庫／課程為核心；User／Learning／Missions／Analytics 預留）。詳見專案根目錄 [`../docs/ARCHITECTURE.md`](../docs/ARCHITECTURE.md)。
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
│   ├── Http/Controllers/Api/V1/
│   │   ├── Content/
│   │   │   └── CurriculumController.php  # Content 模組：課程／題目 API
│   │   └── ModuleStatusController.php    # 其他模組預留 GET …/status
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

這會建立資料表，並種入 **6 個學科、示範課程（含與 App 同步的小一自然 11 單元）、380+ 題題目**（另含約 30 題綁定小一自然各課）以及 **三種角色的示範帳號**（管理者／教師／家長，見下表）：

**與 Flutter 課程同步（小一自然）**：請維護 `database/data/science_g1_sync.php`，並與專案根目錄 `lib/curriculum/science/science_g1_lessons.dart` 對齊（`code` = App 的 `Lesson.id`）。變更後執行 `php artisan db:seed --class=ScienceG1CurriculumSeeder` 或整體 `migrate:fresh --seed`。

| 帳號                       | 密碼       | 角色   | 登入網址（本機範例） |
| -------------------------- | ---------- | ------ | -------------------- |
| `admin@kidlearn.local`     | `password` | 管理者 | `/admin`             |
| `teacher@kidlearn.local`   | `password` | 教師   | `/teacher`           |
| `parent@kidlearn.local`    | `password` | 家長   | `/parent`            |

`users.role` 為 `admin` / `teacher` / `parent`，各面板僅允許對應角色進入。管理者儀表板會顯示帳號數量統計；付費與訂閱需另接金流後再串資料表。教師／家長儀表板預留學習狀態區塊（目前 App 進度多在裝置本機，雲端學習紀錄 API 尚未實作）。

### 3. 啟動開發伺服器

```bash
php artisan serve
```

Server 預設跑在 <http://127.0.0.1:8000>。

- **管理者**（課程／題庫 CRUD）： <http://127.0.0.1:8000/admin>
- **教師後台**： <http://127.0.0.1:8000/teacher>
- **家長後台**： <http://127.0.0.1:8000/parent>
- API 健康檢查： <http://127.0.0.1:8000/api/v1/ping>

若開 `/parent` 或 `/teacher` 曾出現 **403**：多半是同一瀏覽器已在 `/admin` 以**管理者**登入（共用 `web` session）。請先從管理者後台登出，或改用無痕視窗，再以 `parent@kidlearn.local`／`teacher@kidlearn.local` 登入（密碼見上方帳號表）。程式已加上中介層，會自動登出錯誤角色並帶到該面板的登入頁，避免只看到 403。

## API 清單（Gateway `/api/v1`）

### Content（題庫系統）— 建議使用

| Method | 路徑 | 說明 |
| ------ | ---- | ---- |
| GET | `/content/subjects` | 取得所有學科 |
| GET | `/content/lessons` | 課程列表（`?subject=math&grade=1&semester=first`） |
| GET | `/content/lessons/{code}` | 單一課程詳情（含題目 + 字詞） |
| GET | `/content/questions` | 題目列表（`?subject=math&grade=2&random=1&limit=10`） |
| GET | `/content/snapshot` | 快照（學科、課程、免費題）供 Flutter 快取 |

### User（App 家長帳號，Sanctum Bearer）

僅建立／登入 **`role=parent`** 的帳號；教師與管理者請用 Filament 網頁登入。題庫 API 仍 **不需** 帶 Token。

| Method | 路徑 | 說明 |
| ------ | ---- | ---- |
| POST | `/user/register` | 註冊（JSON：`name`, `email`, `password`, `password_confirmation`） |
| POST | `/user/login` | 登入（`email`, `password`）→ 回傳 `data.token` |
| POST | `/user/logout` | 登出（Header：`Authorization: Bearer {token}`） |
| GET | `/user/me` | 目前使用者（需 Bearer） |

### 其他模組（預留）

| Method | 路徑 | 說明 |
| ------ | ---- | ---- |
| GET | `/user/status` | 使用者模組階段說明 |
| GET | `/learning/status` | 學習紀錄模組階段說明 |
| GET | `/missions/status` | 任務模組階段說明 |
| GET | `/analytics/status` | 分析模組階段說明 |

### Legacy（相容舊路徑）

`/subjects`、`/lessons`、`/questions`、`/snapshot` 仍指向同一組實作；**新客戶端請改走 `/content/*`**。

### 範例

```bash
curl "http://127.0.0.1:8000/api/v1/content/questions?subject=math&grade=1&random=1&limit=5"
```

## 管理後台操作

- **管理者**（`/admin`）：學科、課程單元、題目等內容維護；儀表板有帳號角色數量與付費／訂閱佔位說明。
- **教師**（`/teacher`）、**家長**（`/parent`）：目前為獨立 Filament 面板與儀表板說明區塊；待學習紀錄 API 與學生／綁定模型上線後，可改為圖表與列表。

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

### `users`（後台登入 + App 家長）
- `role`：`admin`（/admin）／`teacher`（/teacher）／`parent`（/parent 與 App 家長註冊）
- App 登入使用 Sanctum：`personal_access_tokens` 表

## 未來擴充

- [ ] 付費機制（`is_premium=true` 的內容需要登入 + 訂閱）
- [ ] 多媒體題目（圖片、音檔上傳）
- [ ] 老師帳號權限分級
- [ ] 學生答題紀錄 API（讓 Flutter 可以上傳成績到雲端）
- [ ] 匯入／匯出題庫 CSV
