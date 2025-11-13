# 🧹 **PRD: Công cụ Quản lý & Gợi ý Xóa File An Toàn (SafeClean)**

**Version:** 1.0
**Ngày:** 2025-11-11
**Tác giả:** NhaKy Product Team
**Mục tiêu:** Xây dựng CLI tool giúp người dùng quản lý, phân tích, và dọn dẹp file rác một cách an toàn, minh bạch và dễ kiểm soát.

---

## 1. 🎯 Mục tiêu sản phẩm

**SafeClean** giúp người dùng:

* **Nhận diện & tổ chức** file rác, trùng lặp, cũ hoặc tạm thời.
* **Gợi ý & hỗ trợ xóa an toàn** thông qua workflow xác nhận thủ công.
* **Xuất báo cáo & tương tác trực quan** bằng CSV hoặc web preview (Sinatra).

Mục tiêu cốt lõi:

* Không xóa nhầm file quan trọng.
* Người dùng có **toàn quyền kiểm soát**.
* Trải nghiệm **CLI mượt, thân thiện, dễ dùng**, dù không rành kỹ thuật.

---

## 2. 👥 Đối tượng người dùng

| Loại người dùng     | Mục tiêu sử dụng                | Nhu cầu chính                       |
| ------------------- | ------------------------------- | ----------------------------------- |
| Cá nhân (Mac user)  | Dọn dẹp ổ đĩa định kỳ           | Dễ thao tác, ít rủi ro              |
| Nhân viên văn phòng | Dọn thư mục Download, Documents | Gợi ý rõ ràng, không xóa nhầm       |
| DevOps/System Admin | Dọn log, cache, backup          | Có thể tự động hóa bằng config file |

---

## 3. 🧭 Workflow Tổng Thể (CLI UX Flow)

### 3.1 Bước 1 — Chọn thư mục để quét

CLI hiển thị danh sách thư mục phổ biến:

```bash
> Chọn thư mục bạn muốn quét:
  1. ~/Downloads
  2. ~/Documents
  3. ~/Desktop
  4. ~/Projects
  5. Nhập đường dẫn khác...
```

Nếu người dùng chọn “Nhập đường dẫn khác”, CLI yêu cầu path thủ công và xác thực tồn tại.

🔹 **UX yêu cầu:**

* Sử dụng `tty-prompt` cho menu tương tác.
* Tự động highlight thư mục lớn (>1GB) hoặc gần đây được quét.
* Có lựa chọn “quét nhiều thư mục” (multi-select).

---

### 3.2 Bước 2 — Quét & phân tích file

* Scan đệ quy toàn bộ cây thư mục.
* Thu thập metadata: tên file, extension, kích thước, hash (SHA256), thời gian tạo/chỉnh sửa/truy cập, quyền truy cập.
* Phân loại file theo rule:

  * Duplicate (trùng hash)
  * Temp (đuôi .tmp, .log, .bak, cache)
  * Large (top N file lớn nhất)
  * Old (không truy cập > 180 ngày)

🧠 Có thể bổ sung rule mới trong tương lai qua config YAML.

🔹 **UI/UX yêu cầu:**

* Hiển thị progress bar bằng `tty-progressbar` hoặc tương tự.
* Mỗi 1000 file quét → cập nhật thống kê tạm thời.
* Sau khi hoàn tất, hiển thị bảng tóm tắt:

```bash
✅ Hoàn tất quét trong 42s
📂 Tổng file: 12,343
⚠️ Trùng: 324 | Tạm: 95 | Cũ: 120 | Lớn: 18
💾 Dung lượng có thể giải phóng: 2.4 GB
```

---

### 3.3 Bước 3 — Xuất kết quả ra CSV/Excel

CLI hỏi:

```bash
Bạn có muốn xuất kết quả ra CSV/Excel không?
> 1. CSV (nhẹ, dễ xem)
> 2. Excel (.xlsx)
> 3. Bỏ qua
```

File gồm các cột:

| Path | Filename | Size | Extension | Duplicate Group | Last Modified | Warning Type | Mark for delete | Note |
| ---- | -------- | ---- | --------- | --------------- | ------------- | ------------ | --------------- | ---- |

🔹 **Yêu cầu kỹ thuật:**

* Dùng `CSV` và `roo` gem để hỗ trợ đọc/ghi Excel.
* Encoding UTF-8, có BOM để Excel đọc đúng tiếng Việt.
* CSV lưu tại `./exports/safeclean_<timestamp>.csv`.

---

### 3.4 Bước 4 — Review & Mark file

Người dùng mở CSV/Excel, tick `TRUE` hoặc `X` trong cột `Mark for delete`.

CLI cung cấp lựa chọn:

```bash
> Bạn muốn review kết quả bằng cách nào?
  1. Mở file CSV trong Finder
  2. Mở web preview (Sinatra)
  3. Bỏ qua, tôi sẽ tự mở
```

Nếu chọn (2) → khởi chạy Sinatra app:

* Giao diện web có checkbox, filter, preview text file.
* Cho phép mark/xóa file trực tiếp.
* Nút “Save changes” → cập nhật CSV.

🔹 **Web UX yêu cầu (Sinatra):**

* Giao diện tối giản, responsive.
* Table filterable & sortable.
* Hiển thị preview file text (<=50KB).
* Có nút “Export lại CSV” để đồng bộ.

---

### 3.5 Bước 5 — Xử lý file đã mark

CLI đọc lại file CSV:

* Chỉ xóa (hoặc di chuyển) file có `Mark for delete = TRUE`.
* Thực hiện **safe delete**:

  * Chuyển file vào thư mục `./safe_delete/`
  * Không xóa vĩnh viễn trong 7 ngày.
* Log lại chi tiết: thời gian, đường dẫn, trạng thái.

🧱 Nếu xóa lỗi (permission denied) → cảnh báo nhưng không crash.

🔹 **CLI UX yêu cầu:**

```bash
⚠️ Bạn sắp xóa 154 file, tổng 2.1 GB
Các file sẽ được chuyển vào ./safe_delete/ (giữ 7 ngày)
Tiếp tục? (yes/No)
```

Sau khi xong:

```bash
✅ Đã di chuyển 154 file
🕒 Log: logs/delete_2025-11-11.csv
```

Kèm thông báo hệ thống:

```bash
osascript -e 'display notification "Hoàn tất dọn dẹp 2.1GB - 154 files moved to safe_delete/" with title "SafeClean"'
```

---

### 3.6 Bước 6 — Rollback & Cleanup

Trong vòng 7 ngày:

* Người dùng có thể chạy:

  ```bash
  safeclean rollback
  ```

  → CLI phục hồi toàn bộ file từ `safe_delete/` về vị trí cũ.

Sau 7 ngày:

* Tool tự động dọn `safe_delete/` nếu được bật auto-clean trong config.

---

## 4. 🛡️ Tính năng An Toàn

| Tính năng        | Mô tả                                                                 |
| ---------------- | --------------------------------------------------------------------- |
| Safe delete      | Không xóa thật, chỉ di chuyển                                         |
| Rollback         | Phục hồi file trong 7 ngày                                            |
| Dry run          | Chạy mô phỏng, không thao tác file                                    |
| Whitelist        | Không quét các thư mục như `/System`, `/Library`, `.git/`, `.bundle/` |
| Permission check | Cảnh báo nếu file bị giới hạn quyền                                   |
| Double confirm   | Phải xác nhận 2 lần khi xóa >100 file                                 |

---

## 5. ⚙️ Tùy chỉnh & Config

Tạo file `.safeclean.yml` (tùy chọn):

```yaml
default_paths:
  - ~/Downloads
  - ~/Documents
rules:
  min_size_mb: 5
  max_age_days: 180
  include_extensions: ["tmp", "bak", "log"]
  exclude_dirs: ["Projects/active"]
safe_delete_days: 7
notify: true
```

CLI đọc config mặc định nếu có:

```bash
safeclean --auto
```

---

## 6. 💡 UX/UI Guidelines

| Thành phần  | Yêu cầu UX/UI                                                 |
| ----------- | ------------------------------------------------------------- |
| CLI         | Tối giản, có màu (gem `pastel`), dễ đọc, có biểu tượng ✅⚠️🗑️ |
| Menu        | Sử dụng `tty-prompt`, hỗ trợ mũi tên chọn                     |
| Progress    | Hiển thị % hoặc spinner khi quét                              |
| Web Preview | Dạng bảng, có filter, checkbox, note, nút Save                |
| Notify      | macOS notification bằng `osascript`                           |
| Âm thanh    | Khi hoàn tất: `afplay /System/Library/Sounds/Glass.aiff`      |

---

## 7. 🧠 Yêu cầu Hiệu Năng

| Tiêu chí              | Mục tiêu                      |
| --------------------- | ----------------------------- |
| Tốc độ scan           | 10.000 file / 30 giây (ổ SSD) |
| Sử dụng CPU           | <50% 1 core                   |
| Memory footprint      | <300MB                        |
| Độ trễ khi xuất CSV   | <3s cho 10k dòng              |
| Web preview load time | <2s trên dataset 10k record   |
| Xử lý rollback        | Phục hồi 1000 file <10s       |

---

## 8. 🧩 Kiến trúc Kỹ Thuật

**Ngôn ngữ:** Ruby 3.4.4
**Gem dependencies:**

```
csv
roo
sinatra
fileutils
digest
tty-prompt
tty-progressbar
pastel
```

**Cấu trúc thư mục:**

```
safeclean/
├── lib/
│   ├── scanner.rb
│   ├── analyzer.rb
│   ├── exporter.rb
│   ├── deleter.rb
│   ├── rollback.rb
│   └── config_loader.rb
├── web/
│   └── app.rb
├── exports/
├── safe_delete/
├── logs/
└── safeclean.rb
```

---

## 9. 🔔 Thông báo & Feedback vòng đời

| Sự kiện       | Loại notify                   |
| ------------- | ----------------------------- |
| Scan hoàn tất | macOS notification + âm thanh |
| Export CSV    | “File xuất thành công”        |
| Xóa hoàn tất  | Thông báo tổng dung lượng xóa |
| Rollback      | “Phục hồi hoàn tất”           |

---

## 10. 🔍 Kế hoạch QA & Test

* Unit test cho từng module (`scanner`, `analyzer`, `deleter`).
* Test performance với dataset > 50.000 file.
* Test rollback trên macOS thực tế.
* Test thông báo `osascript` (không crash khi tắt sound).
* RSpec coverage ≥ 90%.

---

## 11. 🚀 Mở rộng Tương Lai

* Hỗ trợ Windows/Linux (CLI thuần).
* Plugin rules mở rộng (custom logic).
* Tích hợp API (CLI sync kết quả về server).
* Auto-clean định kỳ bằng cron.

---

### ✅ Tóm tắt triết lý sản phẩm

> SafeClean không chỉ là tool dọn rác —
> mà là một **người trợ lý an toàn, thông minh và lịch sự** trên CLI.
> Nó không bao giờ xóa trước khi hỏi, và luôn cho bạn cơ hội để đổi ý.

