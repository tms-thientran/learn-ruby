# 🧭 **UX_FLOW.md — SafeClean CLI & Web Preview**

**Version:** 1.0
**Date:** 2025-11-11
**Scope:** UX mô phỏng tương tác thực tế của người dùng với CLI và web preview (Sinatra).
**Audience:** Developer team, QA team, UX writer

---

## 1️⃣ CLI Interaction — Mock Conversation Flow

### 💡 Lệnh khởi tạo

```bash
$ safeclean start
```

---

### 👣 Bước 1 — Chọn thư mục quét

```bash
🧹 SafeClean — Quản lý & Gợi ý Xóa File An Toàn
─────────────────────────────────────────────
> Chọn thư mục bạn muốn quét:
  1. ~/Downloads
  2. ~/Documents
  3. ~/Desktop
  4. ~/Projects
  5. Nhập đường dẫn khác...
```

**(User chọn 1 — Downloads)**

```bash
📁 Đã chọn: /Users/admin/Downloads
Bạn có muốn thêm thư mục khác không? (y/N)
```

🔹 **UX Note:**

* Multi-select cho phép quét nhiều folder.
* Nếu người dùng chọn sai → xác nhận lại trước khi bắt đầu scan.

---

### 🌀 Bước 2 — Quét & phân tích

```bash
🔍 Đang quét... 3,425 file (12%) | 1.2 GB | ETA 00:35
```

(Hiển thị thanh progress bar bằng `tty-progressbar`)

Khi hoàn tất:

```bash
✅ Hoàn tất quét trong 38s
📦 Tổng file: 12,343
⚠️ Trùng: 324 | Tạm: 95 | Cũ: 120 | Lớn: 18
💾 Có thể giải phóng: 2.4 GB
```

---

### 📤 Bước 3 — Xuất file kết quả

```bash
> Chọn định dạng xuất kết quả:
  1. CSV (nhẹ, dễ xem)
  2. Excel (.xlsx)
  3. Bỏ qua

🗂️ Đã xuất: ./exports/safeclean_2025-11-11_15-40.csv
```

---

### 👁️ Bước 4 — Review file

```bash
> Chọn cách review file:
  1. Mở file CSV trong Finder
  2. Mở web preview (Sinatra)
  3. Bỏ qua, tôi sẽ tự mở
```

**Nếu chọn 2:**

```bash
🌐 Đang khởi động web preview tại http://localhost:4567
(Ấn Ctrl+C để dừng)
```

---

### 🗑️ Bước 5 — Thực hiện xóa

Sau khi người dùng mark trong CSV hoặc web:

```bash
$ safeclean delete --from exports/safeclean_2025-11-11_15-40.csv
```

```bash
⚠️ Xác nhận xóa 154 file (~2.1 GB)
Các file sẽ được chuyển vào ./safe_delete/
Tiếp tục? (yes/No)
```

Người dùng nhập `yes`

```bash
✅ Đã di chuyển 154 file vào safe_delete/
🕒 Log: ./logs/delete_2025-11-11.csv
```

> 🔔 (Thông báo macOS)

```bash
osascript -e 'display notification "Hoàn tất dọn dẹp 2.1GB - 154 files moved to safe_delete/" with title "SafeClean"'
afplay /System/Library/Sounds/Glass.aiff
```

---

### 🔁 Bước 6 — Rollback (phục hồi)

```bash
$ safeclean rollback
```

```bash
🔄 Phục hồi 154 file từ safe_delete/ về vị trí cũ
✅ Rollback hoàn tất (thời gian: 9.2s)
```

---

## 2️⃣ Web Preview (Sinatra UI Wireframe)

### 🧱 Trang chính — File Overview

```
───────────────────────────────────────────────
 SafeClean Web Preview
───────────────────────────────────────────────

[Filter by Type: All ▼]  [Sort by Size ▼]  [Search ________________]

| Checkbox | Filename       | Type      | Size   | Modified    | Suggestion | Mark | Note              |
|-----------|----------------|-----------|--------|-------------|-------------|------|-------------------|
| ☑         | a.tmp          | temp      | 1MB    | 2024-01-02  | Delete      | ✅   |                   |
| ☐         | design_v2.psd  | large     | 500MB  | 2023-05-01  | Review      |      | Đang sử dụng      |
| ☑         | test.log       | temp      | 50KB   | 2021-10-12  | Delete      | ✅   |                   |
| ☐         | report.xlsx    | old       | 12KB   | 2020-03-15  | Keep        |      | Quan trọng        |

[ Save changes ]  [ Export updated CSV ]
───────────────────────────────────────────────
```

### 🧩 Sidebar Actions

* **Summary panel:**

  ```
  Tổng file: 12,343
  Đã mark: 154
  Tổng dung lượng dự kiến xóa: 2.1GB
  ```
* **Buttons:**

  * “Select all duplicates”
  * “Unmark all”
  * “Preview file” (chỉ hiển thị nếu là .txt, .log, .md)

---

### 👁️ Trang Preview file (modal)

```
───────────────────────────────────────────────
📄 File Preview — /Documents/notes/meeting.txt
───────────────────────────────────────────────
2023-05-10: Meeting with product team
Discussed new UX flow for SafeClean tool.
───────────────────────────────────────────────
[ Close ]
```

---

### ✅ Trang Confirm Delete

```
───────────────────────────────────────────────
⚠️ Xác nhận xóa file đã mark
───────────────────────────────────────────────
Tổng: 154 file (~2.1GB)
File sẽ được chuyển vào ./safe_delete/ trong 7 ngày

[ Confirm & Execute ]  [ Cancel ]
───────────────────────────────────────────────
```

---

## 3️⃣ UX Behavior & Tone Guide

| Hạng mục                | Quy tắc UX                                                                                                             |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Tone CLI**            | Giọng nhẹ nhàng, chuyên nghiệp, không mệnh lệnh. Ví dụ: “Hãy xác nhận để tiếp tục nhé 😊” thay vì “Bắt buộc xác nhận.” |
| **Emoji**               | Sử dụng tối đa 1 emoji/dòng, ưu tiên biểu tượng chức năng (✅ ⚠️ 🗑️ 🔄 🧹)                                             |
| **Color coding**        | - Xanh lá: Success / Hoàn tất<br>- Vàng: Warning / Review<br>- Đỏ: Danger / Error                                      |
| **Sound feedback**      | `afplay /System/Library/Sounds/Glass.aiff` khi hoàn tất thao tác                                                       |
| **Notify timing**       | Notify hệ thống sau mỗi thao tác hoàn tất: Scan, Export, Delete, Rollback                                              |
| **Keyboard navigation** | - ↑ ↓ để chọn menu<br>- Enter xác nhận<br>- q để thoát menu                                                            |
| **Performance UX**      | CLI không được freeze quá 1s, luôn có spinner hoặc status bar                                                          |
| **Fail-safe UX**        | Nếu mất kết nối hoặc crash → Tự động log lại tiến trình chưa hoàn tất                                                  |

---

## 4️⃣ Bonus: Interaction Flow Summary

```
┌────────────────────────────────────────────────┐
│ safeclean start                                │
├────────────────────────────────────────────────┤
│ 1. User chọn folder (CLI menu)                 │
│ 2. Tool scan + progress bar                    │
│ 3. Hiển thị summary & hỏi xuất file            │
│ 4. User review (CSV hoặc web)                  │
│ 5. User mark file cần xóa                      │
│ 6. safeclean delete (safe move + notify)       │
│ 7. safeclean rollback (nếu cần phục hồi)       │
└────────────────────────────────────────────────┘
```

---

## 5️⃣ Developer Notes

* **CLI framework:** pure Ruby + `tty-prompt`, `tty-progressbar`, `pastel`.
* **Web preview:** Sinatra + Tailwind (hoặc pure CSS), chạy cục bộ.
* **Notify integration:**

  ```bash
  osascript -e 'display notification "#{message}" with title "SafeClean"'
  ```
* **Sound:** optional, bật bằng config `sound: true`.
* **Cross-platform:**

  * macOS ✅
  * Linux: notify-send fallback
  * Windows: TBD

---

## 6️⃣ Visual UX Example (CLI Screenshot Concept)

```
🧹 SafeClean — Quản lý & Gợi ý Xóa File An Toàn
─────────────────────────────────────────────
📁 Thư mục đang quét: /Users/admin/Downloads
🔍 Đang phân tích... [■■■■■■■■■■■■■■■■■■      ] 82%
Tổng file: 8,201 | Dung lượng: 3.2 GB
─────────────────────────────────────────────
✅ Hoàn tất!
⚠️ Trùng: 142 | Tạm: 60 | Cũ: 85 | Lớn: 9
💾 Có thể giải phóng: 1.1 GB
─────────────────────────────────────────────
Bạn có muốn xuất kết quả? (Y/n)
```

---

## 7️⃣ UX QA Checklist

| Mục                                   | Yêu cầu đạt | Người kiểm |
| ------------------------------------- | ----------- | ---------- |
| CLI không crash khi user ấn Ctrl+C    | ✅           | QA         |
| Progress bar cập nhật đúng            | ✅           | QA         |
| Web preview hiển thị <2s / 10k record | ✅           | QA         |
| CSV encoding UTF-8 BOM                | ✅           | Dev        |
| Notify hoạt động trên macOS Sonoma    | ✅           | QA         |
| Safe delete rollback hoạt động        | ✅           | Dev/QA     |

---

## ✅ Kết luận

> SafeClean hướng tới trải nghiệm CLI **“người thật — việc thật”**,
> nơi người dùng không sợ lệnh xoá, mà **tận hưởng cảm giác dọn sạch có kiểm soát**.
>
> CLI phải dễ như trò chuyện, nhanh như terminal, và an toàn như Time Machine.
