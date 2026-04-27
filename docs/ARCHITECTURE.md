# 平台架構（Flutter ↔ API Gateway ↔ 業務模組 ↔ MySQL）

## 目標型態

```
Flutter App
    │
    ▼
API Gateway（Laravel，`/api/v1`）
    │
    ├── user        使用者系統（帳號、個人檔、權限…）
    ├── learning    學習系統（進度、學習紀錄、同步狀態…）
    ├── content     題庫系統 ⭐（學科、課程、單元、題目、詞彙）
    ├── missions    任務系統（成就、每日任務…）
    └── analytics   分析系統（彙總、報表、學習曲線…）
    │
    ▼
MySQL
```

- **Gateway**：統一入口、版本前綴（`v1`）、日後可加認證／節流／觀測。
- **Content** 為目前**唯一已接資料庫與 Filament 後台**的模組；其餘模組可先回傳 `GET …/status` 佔位，再漸進實作。

## HTTP 路徑約定（Laravel）

| 模組 | 前綴 | 說明 |
|------|------|------|
| Content | `/api/v1/content/*` | 正式對外；見下表 |
| User | `/api/v1/user/status` | 預留 |
| Learning | `/api/v1/learning/status` | 預留 |
| Missions | `/api/v1/missions/status` | 預留 |
| Analytics | `/api/v1/analytics/status` | 預留 |

### Content 端點

| 方法 | 路徑 | 用途 |
|------|------|------|
| GET | `/api/v1/content/subjects` | 學科列表 |
| GET | `/api/v1/content/lessons` | 課程列表（可 query：`subject`, `grade`, `semester`） |
| GET | `/api/v1/content/lessons/{code}` | 單一課程含題 |
| GET | `/api/v1/content/questions` | 題目列表 |
| GET | `/api/v1/content/snapshot` | 快照（離線快取用） |

### Legacy（相容）

舊路徑 `/api/v1/subjects`、`/lessons`… 仍指向同一組 Controller，**新建議改走 `/content/*`**。

## Flutter App

- **課程／題庫 HTTP client**：`lib/services/curriculum_api.dart`（語意上即 Content 模組 client），`ApiConfig.defaultBaseUrl` 仍為 `…/api/v1`。
- **內建課綱資料**：`lib/curriculum/`（離線、108 對照）；與後端 Content 可並存（遠端優先或 merge 由產品決策）。

## 程式碼對應（後端）

| 模組 | Controller / 說明 |
|------|---------------------|
| Content | `App\Http\Controllers\Api\V1\Content\CurriculumController` |
| 各模組預留 | `App\Http\Controllers\Api\V1\ModuleStatusController` |
| 路由 | `backend/routes/api.php` |

Eloquent **Model** 目前仍集中在 `app/Models/`（Subject、Lesson、Question…），與 Filament 資源共用；日後若模組邊界變硬，可再拆為 `app/Content/Models` 等並逐步搬遷。

## 資料庫

現有 migration 以 **Content** 相關表為主（`subjects`, `lessons`, `questions`, `vocabulary_items`）。  
User / Learning / Mission / Analytics 新增表時，建議 migration 檔名或註解標註所屬模組，避免單一 `schema` 難以維護。
