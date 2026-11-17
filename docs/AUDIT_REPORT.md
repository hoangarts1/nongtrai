# KIỂM TOÁN TIẾN ĐỘ — THE LIFE

Ngày kiểm toán: **18/11/2026, Asia/Bangkok**. Workspace: `D:/godot/game-godot`.
HEAD tại lúc bắt đầu: `e7136608199a5d758433f7c599c8f89f31515cea`.

**Kết quả chính:** full launcher hiện tại PASS, nhưng toàn bộ kế hoạch chưa hoàn tất. Sổ đối chiếu bên dưới có **200 mục: 42 DONE, 38 DONE_UNCOMMITTED, 70 PARTIAL, 38 NOT_STARTED, 3 DOC_ONLY, 9 BLOCKED**. Theo đúng điều kiện phải có commit, tỷ lệ là **42/200 = 21,0%**. Nếu gộp cả phần hoàn tất chưa commit thì80/200=40,0%; đây KHÔNG phải tỷ lệ DONE theo định nghĩa yêu cầu.

Các con số đếm **mục đối chiếu của báo cáo**, bao gồm mục cha, phạm vi con đã duyệt, mốc lịch sử và mục tiêu hình ảnh đầy đủ. Chúng không phải ước lượng khối lượng công việc/thời gian hay phần trăm sản phẩm chơi được. Một ISO được giao hẹp có thể DONE trong khi mockup đầy đủ tương ứng vẫn PARTIAL; hai phạm vi đó được ghi riêng, không đánh đồng.

Phạm vi chỉ đọc: không sửa code/scene/asset/InputMap, không stage/commit/push. File duy nhất được tạo trong repo là báo cáo này. Các log, hash, danh mục phân tích đặt trong thư mục TEMP bên dưới; runner dùng APPDATA thử nghiệm riêng. Không cập nhật PROGRESS/API_INDEX theo ngoại lệ rõ ràng của nhiệm vụ kiểm toán.

## 1. Nguồn và cách kiểm chứng

Đã quét đầy đủ nội dung các nguồn bắt buộc trên đĩa, lập danh mục heading/TASK/ACCEPTANCE/ALLOW_LIST/trạng thái xuyên suốt PROGRESS, đối chiếu với mã/data/scene/Git/test thật. Các đoạn kế hoạch, bảng API tương lai và biên bản giao việc lịch sử không tự được coi là implementation. Việc xem mã tập trung vào đường runtime và các mục có bằng chứng/mâu thuẫn; không khẳng định đã chứng minh hình thức mọi dòng của toàn repository.

| Nguồn bắt buộc | Số dòng | Byte | SHA256 tại lúc bắt đầu |
|---|---:|---:|---|
| `AGENTS.md` | 75 | 5541 | `2746e0c51afede587c94cf67216ac3949eacdbc5bd8c874d6c39534d64443533` |
| `docs/PROJECT_RULES.md` | 183 | 14854 | `da8181977c4d12e8ef76073509110a26d263d17d2154f0e0117f42c29faa51d5` |
| `docs/ARCHITECTURE.md` | 397 | 60319 | `d6c83865d3f5610e5f3cc2f505990eedc52743842e0bde3a0f1007a4fe93164f` |
| `docs/ROADMAP.md` | 270 | 35667 | `3a7df19692c8b0efd02a191a2a1aeafeff1d2f9ab5d5d28a850135df996857f1` |
| `docs/PROGRESS.md` | 7621 | 797203 | `33ed4063b6b8ca0ed44b9261bad38bd15adb56d2f48b18a04445f42ec507966a` |
| `docs/DECISIONS.md` | 573 | 111211 | `35a8d2f26b66ea4dc0daf99a8f3c913363e2d650e586cab6cafec92642e7e29c` |
| `docs/API_INDEX.md` | 830 | 146811 | `d21f9f9dc41db552c336312f60ddc69730e68566e4fdd07971fd1ce1776fea63` |
| `docs/reference/THE_LIFE_MASTER_PLAN.txt` | 3159 | 219940 | `3f47d3103d33969a7e413002e0435b45b8b86b38f82e3e02edd8396ba7f54a9d` |
| `assets/crops/crops_manifest.json` | 218 | 3776 | `5280787388a406b0ecbfb1947a89e0ec1db0cfc449f9ecccd0cde39e7d486f31` |
| `assets/machines/machines_manifest.json` | 78 | 1187 | `00a08d3d17729025bab26f3881dc89fbbb5583cd224b9f7fbba2ce72504adaa0` |

Đã kiểm kê và xem16 ảnh trong `docs/ui_reference/`: overview00 và15 mockup01–15. Các ảnh01–15 thực tế2304×1296, tương ứng2× khung thiết kế1152×648; overview2536×3246. Đã đọc thêm `the_life_master_prompt.md` (untracked), `docs/MASTER_PROMPT.md`, `docs/CHIBI_STYLE_PROMPT.md`, prompt gốc trong attachment và các scene contract liên quan để truy các mốc M/C, manager và phạm vi đã duyệt. Không dùng PNG mockup làm texture runtime: không tìm thấy tham chiếu runtime tới thư mục `docs/ui_reference/`.

Bằng chứng máy đọc đầy đủ và log audit: `C:/Users/daova/AppData/Local/Temp/the_life_progress_audit_20261118_001357/`, gồm `full-source-catalog.json`, `progress-narrative-extract.txt`, `workspace-before.json`, `git-status-before.txt`, `audit-goals.json`, `asset-census.json`, `test-census.json`, `input-map-census.json`, `test-logs/`. Đây là bằng chứng cục bộ có thể mất khi dọn TEMP; đường dẫn không phải artifact đã commit.

Quy ước trạng thái:

- **DONE:** phần hành vi có implementation, test GUT hiện pass và commit trên nhánh HEAD làm bằng chứng. Commit nền được ghi rõ khi bước mới chỉ xác minh lại implementation đó. Thay đổi mở rộng sau commit được tính ở phạm vi riêng.
- **DONE_UNCOMMITTED:** implementation của phạm vi được kiểm đã có, test hiện pass, nhưng chưa có commit trên lịch sử HEAD chứa phần đó.
- **PARTIAL:** chỉ thỏa một phần tiêu chí hoặc còn thiếu kiểm chứng bắt buộc; phần thiếu được nêu cụ thể.
- **NOT_STARTED:** chưa tìm thấy implementation/runtime/test của mục tiêu đó. Có ảnh/data mẫu hoặc kế hoạch không đồng nghĩa đã bắt đầu hệ thống.
- **DOC_ONLY:** chỉ áp dụng cho tuyên bố implementation cụ thể mà tài liệu đã mô tả như có/đã xong, nhưng không có implementation/test tương ứng. Không áp dụng cho bảng ghi rõ là target.
- **BLOCKED:** cần quyết định, đầu vào hoặc nghiệm thu của người dùng; mỗi hàng chỉ rõ đang chờ gì.

DONE ở đây dùng định nghĩa của yêu cầu kiểm toán (implementation + GUT pass + commit), không tự xác nhận GateA/GateB hoặc mọi checkbox F5 của PROJECT_RULES. Nghiệm thu người dùng còn thiếu được ghi riêng.

## 2. Kiểm thử thực tế trong lượt kiểm toán

Chạy **nguyên launcher trong repo**, không sửa cấu hình/bound/test:

```powershell
cmd /c tools\run_tests.bat
```

Launcher gọi `tools/check_parse.bat`, `tools/run_godot_bounded.ps1`, validator,63 test headless cố định, `tools/run_graphics_tests.ps1` cho toàn bộ test được discovery, rồi Main headless. Binary thực tế: `D:/godot/Godot_v4.7.2-stable_win64.exe`; `--version` trả `4.7.2.stable.official.ed1daf0bf`. GUT9.7.1, renderer Forward+/D3D12. Không có phiên F5 đang chạy khi đo; Godot Editor được giữ mở.

| Gate | Kết quả thật |
|---|---|
| Version/parse | Đúng4.7.2; `[check_parse] OK`; stdout/stderr parse không có Script/Parse/Error |
| Data | `[validate_data] PASS`, exit0 |
| Headless | 16 script,63/63 test,882 assertion,5.416s |
| Graphics nhóm1 | 70 script,291/291 test,15.782 assertion,108.399s |
| Graphics nhóm2 | 70 script,292/292 test,17.824 assertion,121.166s |
| Graphics tổng | 140 script,583/583 test,33.606 assertion; GUT229.565s; wall241.8400934s |
| Main headless | PASS; stdout/stderr không có Script/Parse/Error |
| Launcher toàn bộ | exit0; wall258.7937525s |

Trích output thật (bỏ mã màu ANSI, không thay số):

```text
[check_parse] OK
[validate_data] PASS
Scripts              16
Tests                63
Passing Tests        63
Asserts             882
Time              5.416s
---- All tests passed! ----
[graphics_tests] PASS: 140 scripts, 583/583 tests, 33606 assertions; GUT 229.565s, wall 241.8400934s
[run_tests] starting main scene headless
Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org
[run_tests] PASS
```

**Không có test fail hay lỗi harness trong lượt này.** Discovery thực tế là140 file/583 hàm `test_*`; hai nhóm bao phủ đủ140 file, runner kiểm hash/test count trước-sau, không có pending/ignored/orphan/leak/error bị summary bỏ qua.63 case headless là tập con được chạy lại trong583 case graphics; không cộng thành646 test độc lập.

stderr GUT vẫn có cảnh báo, không được gọi là hoàn toàn sạch warning: fixture sai/corrupt/reentry cố ý của ChickenCoop/FarmSave/Inventory/Weather/Land, và fallback crop `turnip`/một số crop cũ không có ảnh. `Main`, parse và validator không có stderr. Các expected-warning không phải test fail. Không có lỗi SCRIPT ERROR, Parse Error, Failed to load script, ERROR hoặc leak/orphan dương trong log graphics theo kiểm tra nghiêm của runner.

D72-C1/6.4a từng timeout180s được PROGRESS ghi lại là **lịch sử**. D72-C2 hiện chia tuần tự2 child, mỗi child vẫn180000ms; tổng wall>180s là đúng hợp đồng, không phải nới bound một process. Một lượt pass không chứng minh hết flaky trên mọi máy. Không chạy lại những bước đã pass vì không sửa implementation.

Log thô đã giữ trong `test-logs/the_life_{version,parse,validate,headless,gut_1,gut_2,main}.log.{stdout,stderr}`, cùng `the_life_gut.manifest.json`, `the_life_gut.summary.json`, `full-audit.log`, `full-result.json` ở thư mục bằng chứng.

## 3. Bảng đối chiếu toàn bộ mục tiêu

Mỗi hàng dưới đây có đúng một trạng thái. Những tên trùng trong roadmap được gắn hậu tố: ISO-17-SHOP/MANAGER,6.4-MACHINE/LAND,6.5-PRESENTATION/UPGRADES. Phần còn lại của Phase10–12 được tách theo số mục trong bản master. Các API dự kiến không có trong mã được ghi thiếu, không suy từ tên trong sơ đồ.


### ISO

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 001. ISO-0 — đặc tả/chuyển đổi và kiểm kê tham chiếu | ROADMAP ISO-0; PROGRESS ISO-0; D33–35 | DONE | docs/DECISIONS.md; docs/SCENE_CONTRACTS/gray_box_world.md; scripts/view/isometric_grid.gd; tests/unit/test_isometric_migration.gd; commit 818a7de | Các checkbox nghiệm thu người dùng chưa có kết quả xác nhận. |
| 002. ISO-1 — runtime 2D, chọn ô, va chạm, y-sort, save cũ | ROADMAP ISO-1; D36 | DONE | scenes/world/gray_box_world.tscn; scripts/view/isometric_grid.gd; tests/unit/test_isometric_migration.gd; commit 818a7de | Node3D lịch sử được giữ làm kho tư liệu; không có trong cây gameplay được test. |
| 003. ISO-2 — Theme/font/component/gallery placeholder dùng chung | ROADMAP ISO-2; D37 | DONE | ui/theme/the_life_theme.tres; ui/ui_gallery.tscn; tests/unit/test_ui_theme.gd, test_ui_components.gd, test_ui_gallery.gd; commit bf8ed55 | Bộ minh họa cuối cùng và icon PNG theo mockup chưa đủ; xem bảng UI-15. |
| 004. ISO-3 — HUD nhỏ, 8 ô, tiền/giờ/nhiệm vụ/toast thật | ROADMAP ISO-3; D38 | DONE | ui/hud/hud_root.tscn; ui/hud/hud_presenter.gd; tests/unit/test_isometric_hud.gd; commit 8706dfb | Phạm vi đã duyệt ẩn stamina/sự kiện; không đồng nghĩa đủ mockup03/04. |
| 005. ISO-4 — kết thúc ngày, sổ thu/chi, chống chuyển ngày lặp | ROADMAP ISO-4; D39 | DONE | ui/day_end/day_end_flow.gd; scripts/domain/economy/day_ledger_state.gd; tests/unit/test_day_end_flow.gd, test_day_end_rollover.gd, test_day_end_save.gd; commit c8b94f9 | XP/stamina/sự kiện chưa có; UI dùng dữ liệu thật. |
| 006. ISO-5 — túi40 ô, lọc/chọn/sắp xếp/vứt, tab dùng chung | ROADMAP ISO-5; D40 | DONE | ui/inventory/inventory_screen.tscn; scripts/domain/inventory_actions.gd; tests/unit/test_inventory_screen.gd, test_inventory_actions.gd; commit 67c63a2 | Ăn/chất lượng/stamina chưa có; F nhanh chọn stack trên thanh công cụ đúng D40. Nâng52 ô thuộc6.5g chưa commit. |
| 007. ISO-6 — toàn bộ farming/balance theo prompt | ROADMAP ISO-6 | PARTIAL | data/crops/; tests/unit/test_crop_care.gd, test_crop_regrow.gd, test_crop_economy_data.gd | Phân bón, mở ngô theo cấp nhà, chia4 stage và hình cây lâu năm sau thu chưa đủ. |
| 008. ISO-6a — chăm cây/rain-order/save7 theo phạm vi cũ | PROGRESS ISO-6a; D41 | DONE | scripts/domain/farm_grid_state.gd; tests/unit/test_crop_care.gd, test_crop_care_save.gd; commit 7f7a429 | Quy tắc héo terminal của6a đã được D56 thay bằng hồi phục/chết; không coi lịch sử6a là luật hiện tại. |
| 009. ISO-6b1 — bảng giá/growth, cà chua tái sinh2 ngày, cap80/save8 | PROGRESS ISO-6b1; D42 | DONE | data/crops/summer_tomato.tres; data/crop_economy_config.tres; scripts/domain/crop_cycle_rules.gd; tests/unit/test_crop_regrow.gd, test_crop_regrow_save.gd; commit 4b3ca62 | Chỉ hoàn thành phạm vi6b1; chưa có phân bón/nhà. |
| 010. ISO-6b phần phân bón/nhà còn lại | ROADMAP ISO-6; D42; prompt §4 | BLOCKED | PROGRESS mục ISO-6b1 ghi hoãn; không có HouseState/FertilizerData trong census lớp/data | Cần chốt cấp/giá/vật liệu nhà, tác dụng và cách dùng phân bón; giá mẫu15 chưa đủ đặc tả. |
| 011. ISO-7 — pause/settings/save phần có hệ thống hỗ trợ | ROADMAP ISO-7; D43 | DONE | ui/pause/pause_shell.tscn; tests/unit/test_pause_settings.gd, test_pause_layout.gd; commit 4ccc8de | Không bao gồm tùy chọn bị vô hiệu hóa trên ảnh14. |
| 012. ISO-8a — menu chính và bản lưu gần nhất thật | ROADMAP ISO-8a; D44 | DONE | ui/title/title_screen.tscn; ui/title/latest_save_card.gd; tests/unit/test_title_flow.gd, test_title_layout.gd; commit a683feb | Chưa đủ chân dung/thời lượng/cấp nhà trong mockup01. |
| 013. ISO-8b — tạo nông dân/chia lớp/xem trước tóc2D | ROADMAP ISO-8b; D45 | DONE | ui/title/profile_form.tscn; scripts/view/avatar_hair_2d.gd; tests/unit/test_profile_creation.gd, test_profile_preview.gd; commit 57008ab | Hiện vẫn hoạt động sau D62; target audit mới yêu cầu gỡ, xem DESIGN-1. |
| 014. ISO-9 — bản tin sáng sau rollover thật | ROADMAP ISO-9; D46 | DONE | ui/morning/morning_flow.gd; tests/unit/test_morning_flow.gd, test_morning_layout.gd; commit ec3c6d3 | Dự báo3 ngày thật, không phải5; thiếu sinh nhật/lễ hội/trend. |
| 015. ISO-10 — hồ sơ/quan hệ thật, không giả XP | ROADMAP ISO-10; D47 | DONE | ui/character/character_flow.gd; tests/unit/test_character_screen.gd, test_character_layout.gd; commit b44c5d5 | Kỹ năng/XP/sinh nhật chưa khả dụng; target audit mới yêu cầu gỡ màn, hiện chưa áp dụng. |
| 016. ISO-11 — sổ nhiệm vụ thật/chia lớp nhỏ | ROADMAP ISO-11; D48 | DONE | ui/quests/quest_book.tscn; tests/unit/test_quest_book.gd, test_quest_book_layout.gd; commit 962bba9 | Hằng ngày/Ghim T/Bản đồ/XP unavailable. |
| 017. ISO-12 — ground/assets và đầy đủ lớp Ground/Path/Farmland/Decor/Objects/Highlight | ROADMAP ISO-12; D50-ground | PARTIAL | assets/tiles/tileset/ground_tileset_128x64.tres; scripts/view/gray_box_world.gd; tests/unit/test_isometric_migration.gd::test_ground_uses_imported_atlas_variants_without_grid_lines; commit d1bc16a | Atlas/nền/Farmland đã có và commit; chưa có Path/Decor layer riêng và chưa dùng decor/objects supplied. Phạm vi import hẹp đã duyệt được ghi DONE ở ISO12-IMPORT bên dưới. |
| 018. ISO-13 — xác minh font/Theme/HUD đã có | ROADMAP ISO-13; D51 | DONE | ui/theme/the_life_theme.tres; tests/unit/test_ui_theme.gd, test_isometric_hud.gd; commits bf8ed55, 8706dfb; PROGRESS ISO-13 | Không có commit runtime ISO-13 riêng vì đây là xác minh lại nền đã commit. |
| 019. ISO-14 — đá/bụi cỏ theo hash, đá lớn có va chạm | ROADMAP ISO-14; D52 | DONE | scripts/view/world_presentation.gd; assets/rocks/; assets/grass_clumps/; tests/unit/test_world_presentation.gd; commit ceb17bd | Decor9 sprite riêng/cây fruit/bush chưa dùng; gameplay dọn đá được chủ động hoãn. |
| 020. ISO-15 — mục tiêu rộng16 cây + care/perennial | ROADMAP ISO-15 [x]; D49 | PARTIAL | scripts/view/crop_presentation.gd; data/crops/supplied_crop_catalog.tres; tests/unit/test_farm_view.gd, test_crop_regrow.gd | Tick roadmap rộng hơn phạm vi visual đã duyệt; chia4 stage đều và sau thu vềstage3 chưa đúng. |
| 021. ISO-15-VISUAL — phạm vi nhập ảnh/chỉ nối crop cũ khớp basename | PROGRESS ISO-15; D53 | DONE | assets/crops/crops_manifest.json; scripts/view/crop_presentation.gd; tests/unit/test_farm_view.gd; commit 25a1ff2 | Ở thời điểm commit chỉ có9 CropData; đăng ký16 crop mới là ISO-18 chưa commit. |
| 022. ISO-16 — giữ3 màn hỗ trợ/không bịa dữ liệu | ROADMAP ISO-16; D54 | DONE | ui/day_end/day_end_flow.gd; ui/inventory/inventory_screen.tscn; ui/pause/pause_shell.tscn; tests/unit/test_day_end_layout.gd, test_inventory_screen.gd, test_pause_layout.gd; commits c8b94f9,67c63a2,4ccc8de; xác nhận bba2d1c | Không phải hoàn thành tất cả màn01–15. |
| 023. ISO-17-SHOP — cửa hàng vật phẩm trồng theo dữ liệu đang đăng ký | ROADMAP ISO-17-shop; D55 | DONE | scripts/view/seed_shop_panel.gd; tests/unit/test_seed_shop.gd; runtime nền c459ba7, xác nhận 4eed9a0 | Luồng dùng WalletState/InventoryState thật; tên EconomyService/InventoryService trong D55 không tồn tại. |
| 024. ISO-17-MANAGER — bỏ Player/creation/Character, tương tác trực tiếp | ROADMAP ISO-17-manager; D50-manager; D62 | PARTIAL | scenes/world/gray_box_world.tscn; scripts/player/player.gd; ui/character/character_flow.gd; tests/unit/test_player_restoration.gd | Có kéo/zoom giới hạn, nhưng Player/reach/creation/Character vẫn hoạt động sau D62 khôi phục. Theo target audit mới, phần gỡ bỏ chưa hoàn tất; cần phạm vi migration riêng, không tự thực hiện trong audit. |
| 025. ISO-18 — đăng ký16 cây/items, đất khô/ướt, héo/hồi phục/chết/xẻng | ROADMAP ISO-18; D56 | DONE_UNCOMMITTED | data/crops/supplied_crop_catalog.tres; scripts/core/data_registry.gd; scripts/domain/farm_grid_state.gd; data/tools/shovel.tres; tests/unit/test_farm_view.gd, test_crop_care.gd, test_crop_care_ui.gd | Chưa commit; hợp đồng hình cây lâu năm/chia stage rộng hơn còn thiếu ở ISO-15. |

### ROADMAP P–5

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 026. P-1 — các quyết định nền được xác nhận hết | ROADMAP P-1 | PARTIAL | docs/DECISIONS.md có D01–D86 và quyết định đã khóa; nhiều D02–D18 còn DEFAULT/[ ] | Không xác định được xác nhận toàn bộ quyết định gốc; không suy từ việc đã có code. |
| 027. P-2 — spike asset1 tuần có PASS/FAIL | ROADMAP P-2; Master10.9 | BLOCKED | D33 đã chọn2D; không tìm thấy biên bản spike1 tuần trong docs | Chờ chủ dự án xác nhận đã thử/miễn spike; hiện có build art và GUT không thay được biên bản này. |
| 028. P-3 — công cụ/repo/docs/quy tắc | ROADMAP P-3 | PARTIAL | project.godot; AGENTS.md; tools/run_tests.bat; addons/gut/plugin.cfg; test_project_config.gd; commit 98677d8 | Get-Command không tìm gdlint/gdformat; không xác định được checklist cài đặt của người dùng đã xong. |
| 029. 0.1 — repo/config/parse/test launcher | ROADMAP0.1 | DONE | tools/check_parse.bat; tools/run_tests.bat; tests/unit/test_smoke.gd; commit 98677d8; lượt kiểm toán exit0 | Bộ chia2 nhóm hiện tại là D72-C2 chưa commit, được tính riêng. |
| 030. 0.2 — InputMap/layer/font/autoload | ROADMAP0.2; D33 | PARTIAL | project.godot; tests/unit/test_project_config.gd, test_localization.gd, test_ui_theme.gd; commits 98677d8,818a7de,bf8ed55 | K/T chưa có, M chưa mở màn; tài liệu tối đa6 autoload nhưng thực tế7 (gồm helper plugin). |
| 031. 0.3 — GridMath âm/biên/footprint/xoay | ROADMAP0.3 | DONE | scripts/util/grid_math.gd; tests/unit/test_grid_math.gd; commit 98677d8 | Projection runtime đã chuyển sang IsometricGrid theo D33; Vector3 cũ chỉ adapter logic/wire. |
| 032. 0.4 — graybox/chọn ô/highlight theo nền2D thay thế | ROADMAP0.4; D33,D36 | DONE | scenes/world/gray_box_world.tscn; tests/unit/test_isometric_migration.gd; commit 818a7de | Không cần khôi phục plane/Camera3D/lưới debug lịch sử. |
| 033. 0.5 — DetRandom và golden | ROADMAP0.5 | DONE | scripts/domain/quests/det_random.gd; tests/unit/test_merchant_service.gd; commit 186bc59 | Golden weather mới nằm Phase7.1b chưa commit. |
| 034. 0.6 — Log utility + debug overlay | ROADMAP0.6 | PARTIAL | scripts/view/debug_menu.gd; tests/unit/test_tutorial_quest_and_debug.gd; census không có Log | Thiếu Log có context; Ctrl+M hiện chuyển sang machine shop, không mở debug overlay cũ. |
| 035. 1.1 — di chuyển theo màn hình/chuẩn hóa chéo | ROADMAP1.1; D33 | DONE | scripts/player/player.gd; tests/unit/test_move_dir.gd, test_isometric_migration.gd; commit 818a7de | Là hành vi Player hiện tại, trái mục tiêu bỏ Player mới chưa chốt lại. |
| 036. 1.2 — va chạm/trượt vật cản | ROADMAP1.2; D33 | DONE | scripts/view/gray_box_world.gd; tests/unit/test_isometric_migration.gd::test_player_swept_collision_cannot_cross_a_house_footprint; commit 818a7de | Chưa có biên bản người dùng thử mọi góc tường. |
| 037. 1.3 — camera follow/bounds/zoom | ROADMAP1.3; D72 | DONE_UNCOMMITTED | scripts/view/camera_rig.gd; data/isometric_world_config.tres; tests/unit/test_camera_rig.gd, test_d72_camera_input.gd | 5 mức hiện tại và kéo chuột mới chưa commit; camera còn theo Player. |
| 038. 1.4 — node state machine Idle/Move | ROADMAP1.4 | NOT_STARTED | scripts/player/ chỉ player.gd/player_config.gd; không có player/states hay class state-machine | Animation cosmetic trong avatar không thay state machine điều khiển. |
| 039. 1.5 — Interactable tái sử dụng/nearest detector/prompt | ROADMAP1.5 | PARTIAL | scripts/components/interaction_prompt.gd; scripts/view/gray_box_world.gd; tests/unit/test_interaction_range.gd | Tương tác từng anchor có điều kiện riêng; không tìm thấy component Interactable/nearest detector dùng chung. |
| 040. 1.6 — fade/dither vật che người chơi | ROADMAP1.6 | PARTIAL | assets/generated/shaders/; tests/unit/test_chibi_art_foundation.gd | Shader3D được lưu kho; chưa có fade/occlusion policy gắn active2D. |
| 041. 2.1 — clock/pause/ngủ/chuyển mùa/năm | ROADMAP2.1 | DONE | scripts/core/game_clock.gd; tests/unit/test_game_clock.gd, test_seasons.gd; commit a7ed5ac | Clock là Node autoload, khác ClockState RefCounted mục tiêu; xem nợ kiến trúc. |
| 042. 2.2 — HUD ngày/giờ/mùa | ROADMAP2.2 | DONE | ui/hud/clock_card.gd; tests/unit/test_isometric_hud.gd; commit 8706dfb | Phần sự kiện/stamina là hệ thống khác chưa có. |
| 043. 2.3 — console set_time/set_day/speed | ROADMAP2.3 | PARTIAL | scripts/view/debug_menu.gd::_register_default_actions; tests/unit/test_tutorial_quest_and_debug.gd | Có nút giờ/speed/cho đồ debug, chưa console set_day/set_season/give tùy ý/tp/dump_state/simulate_days; Director/force_event chưa có hệ. Ctrl+M đã thay lối mở DebugMenu cũ. |
| 044. 3.1 — ItemData/Registry/Validator | ROADMAP3.1 | DONE | scripts/data/item_data.gd; scripts/core/data_validator.gd; tests/unit/test_data_validator.gd; commit 09604e6 | Bộ16 cây/items/machines/caps bổ sung chưa commit, kiểm riêng. |
| 045. 3.2 — kho add/remove/stack/full/âm/codec | ROADMAP3.2 | DONE | scripts/domain/inventory_state.gd; tests/unit/test_inventory_state.gd; commit a7ed5ac | Nâng cấp52 ô bổ sung chưa commit. |
| 046. 3.3 — hotbar/túi + drag/drop qua service | ROADMAP3.3 | PARTIAL | scripts/view/hotbar_panel.gd; ui/inventory/; tests/unit/test_inventory_screen.gd, test_hotbar_panel.gd | Chọn ô/sort/discard có; chưa tìm thấy drag/drop chuyển stack qua service. |
| 047. 3.4 — tr()/vi-en/key/font/switch | ROADMAP3.4 | DONE | scripts/core/localization.gd; localization/strings_vi.csv; tests/unit/test_localization.gd; commit 233a7de | Live nhãn/toast bổ sung D72-C4 chưa commit; còn2 default text trong scene, ghi bên dưới. |
| 048. 4.1 — CropData/FarmGridState lifecycle | ROADMAP4.1; D56 thay care cũ | PARTIAL | scripts/domain/farm_grid_state.gd; tests/unit/test_farm_grid_state.gd, test_crop_care.gd; nền commit 9bba112 | Core đã làm; mục gốc ngoài mùa=dormant khác current wither/death; domain còn gọi GameClock/DataRegistry autoload trực tiếp. |
| 049. 4.2 — FarmView phản ánh state, placeholder thay được | ROADMAP4.2 | DONE | scripts/view/farm_view.gd; tests/unit/test_farm_view.gd; commit 3f5583d | Hình supplied crops bổ sung xem ISO-15/18; không đồng nghĩa art cuối hoàn chỉnh. |
| 050. 4.3 — ToolAction/cell/reach/feedback | ROADMAP4.3 | PARTIAL | scripts/domain/tool_action.gd; scripts/view/tool_action_controller.gd; tests/unit/test_tool_action.gd, test_interaction_range.gd; commit 645c400 | ToolAction/reach/highlight/feedback và cosmetic play_tool đã có, commit645c400. Chưa có signal tool_hit hoặc action thực thi đúng animation-hit như target gốc; ToolActionController gọi apply trực tiếp khi nhận yêu cầu. |
| 051. 4.4 — thu vào túi, fullbag giữ cây, chống lặp | ROADMAP4.4 | DONE | scripts/view/tool_action_controller.gd; tests/unit/test_harvest.gd; commit 5b5bb4c | 16 cây mới dùng đường xử lý chung; không có test lifecycle riêng cho từng cây lâu năm. |
| 052. 4.5 — một đường DaySimulator và ngủ N ngày | ROADMAP4.5 | DONE_UNCOMMITTED | scripts/domain/day_simulator.gd; tests/unit/test_day_simulator.gd, test_chicken_coop_runtime.gd, test_weather_rollover_guard.gd | Farm→gà→máy→weather runtime hiện tại qua583 test, chưa commit; ecology/economy/director trong sơ đồ tương lai chưa có. |
| 053. 4.6 — save/migrate/backup/fuzz | ROADMAP4.6 | PARTIAL | scripts/core/save_service.gd; tests/unit/test_save_service.gd; tests/golden_saves/save_v1.json; commit 3e2e221 | Có rotate3backup và rejectfilehỏng; load_game chỉ đọc slot chính, không tự phục hồi backup; không tìm fuzz harness tổng quát. |
| 054. 4.7 — game feel âm thanh/effect/animation | ROADMAP4.7 | PARTIAL | assets/audio/; scripts/view/farm_effects.gd; tests/unit/test_audio_assets.gd, test_game_feel.gd; commit 19abb21 | 4 SFX/effect có; tiêu chí muốn chơi thêm cần người dùng ở Gate A, chưa có kết quả. |
| 055. GATE A — vòng trồng/thu 10–15 phút có vui | ROADMAP GateA; Master3.5 | BLOCKED | PROGRESS các checklist F5 còn [ ]; không có biên bản chấp thuận GateA | Chờ chủ dự án ghi kết quả chơi thử và top vấn đề. |
| 056. 5.1 — EconomyService/ledger/reason/atomic | ROADMAP5.1 | PARTIAL | scripts/domain/economy/wallet_state.gd; day_ledger_state.gd; tests/unit/test_wallet_state.gd, test_day_ledger_state.gd; commits e7b6f8c,c8b94f9 | Không có EconomyService; reason có default rỗng; giao dịch còn nằm ở view, không đúng single-service contract. |
| 057. 5.2 — mua/bán + saturation + luôn có hạt cơ bản | ROADMAP5.2 | PARTIAL | scripts/view/seed_shop_panel.gd; shipping_bin_panel.gd; tests/unit/test_seed_shop.gd, test_shipping_bin.gd; commits c459ba7,5c4f5a5 | Thiếu saturation/sold_pressure và kiểm chống softlock theo giá động/đơn hàng. |
| 058. 5.3 — OrderBoard công thức/seed/expiry/persist | ROADMAP5.3 | NOT_STARTED | Không có lớp OrderBoard/OrderTemplateData hay data/orders; census scripts/domain và data | Quest giao3củ cải và merchant offer không phải bảng đơn hàng công thức. |
| 059. 5.4 — sim_economy4–5chiến lược/CSV | ROADMAP5.4; Master8.2 | PARTIAL | tests/unit/test_full_year_economy_simulation.gd; commit 376ff60; tools/sim_economy.gd không tồn tại | Mới test112 ngày; chưa có tool/CSV4–5chiến lược và chỉ số thời gian mua đất. |
| 060. 5.5 — shop/order UI và save pressure/orders | ROADMAP5.5 | PARTIAL | scripts/view/seed_shop_panel.gd; scripts/core/save_service.gd; tests/unit/test_seed_shop.gd, test_save_service.gd | Shop/wallet/inventory được lưu; pressure/orders/UI OrderBoard chưa có. |
| 061. 5.6 — balance vòng1 từ sim/giá data/time-to-land | ROADMAP5.6 | PARTIAL | data/crops/; data/crop_economy_config.tres; tests/unit/test_crop_economy_data.gd; commit 4b3ca62 | Cap/data giá có, chưa có kết quả4–5chiến lược/target mở đất từsim; thành phẩm7 máy vẫn giá0. |

### ROADMAP6

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 062. 6.1 — máy hoàn thành theo total_minutes | ROADMAP6.1; MasterS10/D03 | PARTIAL | scripts/domain/production/machine_state.gd; tests/unit/test_machine_state.gd | Runtime dùng days_remaining/advance_day, chưa có finish_at_total_minutes, hoàn tất giữa ngày hay hủy job hoàn nguyên liệu. |
| 063. 6.1-D57 — phạm vi máy theo ngày đã duyệt | PROGRESS6.1; D57 | DONE_UNCOMMITTED | scripts/data/recipe_data.gd; scripts/domain/production/machine_state.gd; data/recipes/; tests/unit/test_machine_state.gd | Đúng phạm vi D57, chưa commit; không gán DONE cho yêu cầu total_minutes rộng hơn. |
| 064. 6.1a — Machine Shop domain/prices/house/inventory | ROADMAP6.1a; D58 | DONE_UNCOMMITTED | scripts/domain/production/machine_shop_service.gd; machine_inventory.gd; data/machine_shop.tres; tests/unit/test_machine_shop.gd | Chưa commit; giá tạm và cấp nhà ở data, chưa có tiến trình nâng nhà thật. |
| 065. 6.2 — OccupancyMap/footprint/rotation/landlock | ROADMAP6.2; D59 | DONE_UNCOMMITTED | scripts/domain/building/occupancy_map.gd; scripts/domain/production/machine_placement_state.gd; tests/unit/test_machine_placement.gd | Roadmap[x] nhưng các file implementation hiện ??; chưa commit. |
| 066. 6.3 — đặt/xoay/dời/cất domain/save | ROADMAP6.3; D60 | DONE_UNCOMMITTED | scripts/domain/building/machine_build_service.gd; tests/unit/test_machine_build_lifecycle.gd, test_machine_placement.gd | Trả máy vào kho, không hoàn xu; toàn bộ chưa commit. Xoay hình4hướng vẫn thiếu art. |
| 067. 6.4-MACHINE — shop/vận hành thử bằng E | ROADMAP6.4-machine; D61 | DONE_UNCOMMITTED | scripts/view/machine_shop_panel.gd; scripts/domain/production/machine_operation_service.gd; tests/unit/test_machine_operation.gd, test_machine_screen.gd | Luồng nghiệp vụ có; presentation ref10 còn thiếu, xem6.5c/UI10. |
| 068. 6.5-PRESENTATION — máy manifest/pivot/E/animation | ROADMAP6.5-direct; PROGRESS6.5 | DONE_UNCOMMITTED | scripts/view/machine_presentation.gd; machine_interaction_controller.gd; tests/unit/test_machine_presentation.gd, test_d72_animation.gd | Chưa commit; thiếu orientation sprites không thuộc3 trạng thái đã cấp. |
| 069. 6.5b — thu7 đầu ra vào túi đúng1 lần/fullbag/reentry | ROADMAP6.5b; D63 | DONE_UNCOMMITTED | scripts/domain/production/machine_operation_service.gd; data/items/temp_*.tres; tests/unit/test_machine_collection.gd | Bảy ItemData có, sell/buy=0 theo duyệt; chưa commit. |
| 070. 6.5c — UI máy chia lớp theo ảnh10 | ROADMAP6.5c; D64 | PARTIAL | ui/machine/machine_screen.gd; tests/unit/test_machine_screen.gd; ảnh phase65c_vi_1152_shop.png | Nghiệp vụ/locale/test pass nhưng tiêu đề chiếm khoảng nửa chiều cao, nội dung bị ép; Sell/Buyback disabled, chưa giống đầy đủ ảnh10; chưa commit. |
| 071. 6.5d — bảo vệ job khi đặt/xoay/dời/cất | ROADMAP6.5d; D65 | DONE_UNCOMMITTED | scripts/domain/building/machine_build_service.gd; tests/unit/test_machine_build_lifecycle.gd | Chưa commit; máy chạy/còn đầu ra bị chặn dời/cất, xoay tại chỗ không xóa job. |
| 072. 6.5e — đặt bằng chuột/preview/cất máy rảnh | ROADMAP6.5e; D66 | DONE_UNCOMMITTED | scripts/view/machine_placement_flow.gd; ui/machine/; tests/unit/test_machine_placement_request.gd, test_machine_placement_ui.gd | Chưa commit; vùng sở hữu được6.4b mở thêm, không chỉ6×6 cũ. |
| 073. 6.5e-P1 — tối ưu fixture, giữ6 test/36 ảnh | ROADMAP6.5e-P1; PROGRESS | DONE_UNCOMMITTED | tests/unit/test_inventory_screen.gd; PROGRESS ghi before/after; full gate hiện vẫn có6 test | Chưa commit; chưa đo lại3lượt timing riêng trong kiểm toán này, chỉ xác nhận full gate và file/capture. |
| 074. 6.5f — UI dời máy rảnh/xoay/hủy an toàn | ROADMAP6.5f; D67 | DONE_UNCOMMITTED | scripts/domain/building/machine_placement_request.gd; scripts/view/machine_placement_flow.gd; tests/unit/test_machine_move_request.gd, test_machine_move_ui.gd | Chưa commit; xoay thay rotation logic nhưng dùng cùng1hướng sprite. |
| 075. 6.4-LAND — mở đất theo nhiều parcel/công thức | ROADMAP6.4-land | PARTIAL | data/land_expansion/first_east.tres; scripts/domain/building/land_expansion_rules.gd; tests/unit/test_land_expansion.gd | Có lô đầu36 ô/500 và công thức; mới đăng ký1lô; chưa commit/chơi thử của người dùng. |
| 076. 6.4a — data/domain lô đầu phía đông | ROADMAP6.4a; D68 | DONE_UNCOMMITTED | data/land_expansion_config.tres; scripts/domain/building/land_ownership_state.gd; tests/unit/test_land_expansion.gd | Chưa commit; kiểm giá/nguyên tử/codec được full gate chạy lại. |
| 077. 6.4b — ownership vào farm/máy/UI/save9 | PROGRESS6.4b; D69 | DONE_UNCOMMITTED | scripts/view/land_runtime.gd; ui/land/; tests/unit/test_land_runtime.gd, test_land_save.gd, test_land_screen.gd | Chưa commit; không có merchant/nhà/terrain editor mới. |
| 078. 6.5-UPGRADES — toàn bộ nâng túi/bình | ROADMAP6.5-upgrades | PARTIAL | data/bag_upgrade_config.tres; data/watering_can_config.tres; tests/unit/test_bag_upgrade.gd, test_watering_can_upgrade.gd | Mới túi40→52/300 và bình20→40/200; tier sau80/giá600/1800 chưa chốt. |
| 079. 6.5g — túi40→52 giá300 giữ đồ/save | ROADMAP6.5g; D70 | DONE_UNCOMMITTED | scripts/domain/inventory_upgrade_service.gd; ui/bag_upgrade/; tests/unit/test_bag_upgrade_flow.gd, test_bag_upgrade_screen.gd | Chưa commit; không phải hệ nhiều tier túi. |
| 080. 6.5h1 — nền bình20/40/200 và giữ lượng nước | ROADMAP6.5h1; D71 | DONE_UNCOMMITTED | scripts/domain/watering_can_state.gd; watering_can_upgrade_service.gd; tests/unit/test_watering_can_state.gd, test_watering_can_upgrade.gd | Chưa commit; phần runtime đã được h2b nối sau đó. |
| 081. 6.5h2a — map85×85/đi39×39/giếng-suối-ao | PROGRESS6.5h2a; D77 | DONE_UNCOMMITTED | data/isometric_world_config.tres; data/water_sources.tres; scripts/view/water_source_view.gd; tests/unit/test_water_source_world.gd | Chưa commit; đây là vùng đi lại, không phải39×39 đất đều được canh tác. |
| 082. 6.5h2b — tiêu hao/nạp E/HUD/save10 | PROGRESS6.5h2b; D78 | DONE_UNCOMMITTED | scripts/view/watering_runtime.gd; scripts/domain/water_refill_service.gd; ui/hud/water_meter.gd; tests/unit/test_watering_runtime.gd, test_watering_runtime_save.gd | Chưa commit; nguồn nạp thật đủ3 loại, không tự nạp qua đêm. |
| 083. 6.5h3 — nút nâng bình/confirm/refund/ledger/save10 | PROGRESS6.5h3; D79 | DONE_UNCOMMITTED | ui/watering_upgrade/; tests/unit/test_watering_upgrade_flow.gd, test_watering_upgrade_ledger.gd, test_watering_upgrade_screen.gd | Chưa commit; tiêu hao cũ được giữ sau20→40. |
| 084. 6.5h-LATER — bình80/túi tier sau/giá còn lại | D71; PROGRESS6.5h3 | BLOCKED | data/watering_can_config.tres chỉ20/40/200; ghi chú600/1800 chưa ánh xạ | Người dùng cần chốt bước nâng, giá và điều kiện; không tự suy từ3giá cho2 bước. |
| 085. 6.6 — chuồng/gà/trứng mỗi ngày playable | ROADMAP6.6; D80–83 | DONE_UNCOMMITTED | scripts/domain/chicken_coop_state.gd; scripts/view/chicken_coop_runtime.gd; ui/chicken_coop/; tests/unit/test_chicken_coop_runtime.gd, test_chicken_coop_runtime_save.gd | Chưa commit/human acceptance; chỉ1chuồng cố định4 gà, không khẳng định có vật nuôi khác. |
| 086. 6.6a — domain4 gà/cho ăn từng phần/giữtrứng/codec | PROGRESS6.6a; D80 | DONE_UNCOMMITTED | scripts/domain/chicken_coop_state.gd; tests/unit/test_chicken_coop_state.gd | Chưa commit; source độc lập có codec từ đầu. |
| 087. 6.6b — egg30/thu túi một lần/fullbag | PROGRESS6.6b; D81 | DONE_UNCOMMITTED | data/items/egg.tres; scripts/domain/chicken_coop_collection_service.gd; tests/unit/test_chicken_coop_collection.gd, test_chicken_coop_collection_callbacks.gd | Chưa commit; icontrứng dùng fallback. |
| 088. 6.6c — feed20/trừ túi thật/chặn callback | PROGRESS6.6c; D82 | DONE_UNCOMMITTED | data/items/chicken_feed.tres; scripts/domain/chicken_coop_feeding_service.gd; tests/unit/test_chicken_coop_feeding.gd, test_chicken_coop_feeding_callbacks.gd | Chưa commit; giữ egg30/wheat42 đúng quyết định. |
| 089. 6.6d — chuồng700/UIE/day-path/save11 | PROGRESS6.6d; D83 | DONE_UNCOMMITTED | data/chicken_coop_site.tres; scripts/view/chicken_coop_runtime.gd; tests/unit/test_chicken_coop_purchase.gd, test_chicken_coop_screen.gd, test_chicken_coop_callback_lifecycle.gd | Chưa commit; không nâng nhà/di dời chuồng/mood/hunger death. |
| 090. 6.7 — validator profit crops/recipes | ROADMAP6.7; D84 | DONE_UNCOMMITTED | scripts/domain/economy/recipe_economy_rules.gd; data/recipe_economy_config.tres; tools/validate_recipe_economy.gd; tests/unit/test_recipe_validator_cli.gd, test_recipe_economy.gd | Chưa commit; cap15/40/120 theo cấp,24h/ngày, crop80. Giá thành phẩm0 nên chưa chứng minh balance sản xuất thực tế. |

### ROADMAP7–9

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 091. 7.1 — weather có seed, dự báo3 ngày, lưu và khóa ngày | ROADMAP7.1; D86 | DONE_UNCOMMITTED | scripts/domain/weather_state.gd; weather_roller.gd; weather_save_codec.gd; tests/unit/test_weather_rolls.gd, test_weather_daily_state.gd, test_weather_runtime_save.gd, test_weather_rollover_guard.gd; tests/fixtures/weather_rng_v12.json | Chưa commit; seed/today/forecast cũ giữ nguyên, day-save12 và1000 ngày có test. Seasonalweights/storyunlock tách bên dưới. |
| 092. 7.1a — WeatherProfile validator + codec độc lập | PROGRESS7.1a; D85 | DONE_UNCOMMITTED | scripts/domain/weather_snapshot_codec.gd; scripts/data/weather_profile.gd; tests/unit/test_weather_profile_validation.gd, test_weather_snapshot_codec.gd | Chưa commit; mô tả gap runtime ở đoạn lịch sử7.1a đã được7.1b giải quyết. |
| 093. 7.1b — nối DetRandom/token ngày/save12 | PROGRESS7.1b; D86 | DONE_UNCOMMITTED | scripts/domain/weather_roller.gd; scripts/core/save_service.gd; tests/golden_saves/save_v12.json; 4suite weather mới trong full583/583 | Đúng57 đường dẫn đã duyệt và fixture thật; chưa commit/human F5. |
| 094. 7.2 — daynight/rain + ambience theo giờ/thời tiết | ROADMAP7.2 | PARTIAL | scripts/view/gray_box_world.gd; scripts/view/weather_fx.gd; data/day_night_profile.tres; tests/unit/test_day_night.gd, test_weather.gd; commits 655077b,59292c1 | Có sáng tối/cửa sổ/mưa; chưa có nhạc/ambience khu vực/ngày/thời tiết và5audio bus. |
| 095. 7.3 — EcologyState metrics/easing/threshold | ROADMAP7.3 | NOT_STARTED | Census không có EcologyState/data ecology; ARCH WorldState table ghi target | Chưa có state/codec/threshold tests; art bướm không đồng nghĩa ecology. |
| 096. 7.4 — phản hồi sinh thái theo ngưỡng | ROADMAP7.4 | NOT_STARTED | Chỉ có WeatherFx/WorldSeasonFx cosmetic; không có nơi nhận metrics/ngưỡng sinh thái | Thiếu bướm/chim/nước trong gắn dữ liệu sinh thái. |
| 097. 7.5 — Director3events/trace/debug/sim1000days | ROADMAP7.5 | NOT_STARTED | Không có EventDirector/DirectorEventData/tools/sim_director.gd | Weather1000daytest không thay Director1000days; toàn bộ cơ chế còn thiếu. |
| 098. 7.6 — dự báo + journal giải thích/đối phó | ROADMAP7.6 | PARTIAL | ui/morning/weather_column.gd; ui/hud/clock_card.gd; tests/unit/test_morning_layout.gd | Có dự báo thật3 ngày; chưa có sổ sinh thái/telegraph/counter sự kiện. |
| 099. 8.1 — dialogue data + service conditions/actions | ROADMAP8.1 | PARTIAL | scripts/data/dialogue_data.gd; scripts/domain/quests/npc_social_state.gd; data/npcs/phase8_world.tres; tests/unit/test_npc_ui.gd | Hội thoại theo data/conditions có; không có DialogueService/actiondispatcher tổng quát; bố cục ảnh12 chưa làm. |
| 100. 8.2 — queststate1quest/save/atomicreward | ROADMAP8.2 | DONE | scripts/domain/quests/quest_manager.gd; data/quests/quest_turnip_delivery.tres; tests/unit/test_npc_quest_delivery.gd, test_npc_social_save.gd; commits f4a4a8b,5da2d1a | Chưa có campaign/daily quests; không nằm phạm vi1quest này. |
| 101. 8.3 — NPCschedule/AStar/routes/load | ROADMAP8.3 | DONE | scripts/domain/quests/npc_schedule.gd; tests/unit/test_npc_schedule.gd; commit cafc3ee | Dynamic coop obstacles mới thuộc6.6d chưa commit; NPCMinh/Linh2người, không4 NPC của câu chuyện. |
| 102. 8.4 — Minh theo lịch/offer seeded | ROADMAP8.4 | DONE | scripts/domain/quests/merchant_service.gd; data/shops/; tests/unit/test_merchant_service.gd, test_npc_ui.gd; commit 186bc59 | Merchant xuất hiện không bị khóa bởi sửa cầu M2.3; cốt truyện là việc riêng chưa có. |
| 103. 8.5 — chó theo người/đặt tên | ROADMAP8.5 | NOT_STARTED | Có dog calibration trong assets/generated/models/characters và test_chibi_characters.gd; không có pet domain/follow/name/runtime | Model chó/tranh nền không tính chó gameplay. |
| 104. 8.6 — ChươngI + M2.1–M2.4 quest/dialogue/moment | ROADMAP8.6; Master4.3 | NOT_STARTED | data/quests chỉquest_turnip_delivery.tres; không có Chapter/MomentData/cờ sửatrạm | Chưa có tuyến chuyện khôi phục trạm và mốc mở hệ thống. |
| 105. 9.1 — onboarding3 phút người lạ tự qua | ROADMAP9.1 | PARTIAL | scripts/domain/tutorial_quest_state.gd; tests/unit/test_onboarding.gd, test_starter_seeds_and_quest.gd; commit 6ad6eef | 7 bước tự động có; chưa có số đo người lạ hiểu mục tiêu trong3 phút/thư bà/campaign. |
| 106. 9.2 — làng/rừng đủslice + âm thanh vùng | ROADMAP9.2 | PARTIAL | scripts/view/world_presentation.gd; data/npcs/phase8_world.tres; data/water_sources.tres | Có nhà/NPC/đá/cỏ/suối/ao placeholder; chưa có vùng làng/rừng có nội dung/audio vùng. |
| 107. 9.3 — thay graybox asset thật đồng nhất/license | ROADMAP9.3 | PARTIAL | Ground/CropPresentation/MachinePresentation dùng PNG mới; tests/unit/test_world_presentation.gd, test_d72_visual_review.gd | Nhà/người/NPC/UI phần lớn procedural, nhiều PNG chưa bind; CREDITS thiếu dòng pack supplied, chưa có final style review toàn cảnh. |
| 108. 9.4 — settings/accessibility/notebook | ROADMAP9.4 | PARTIAL | ui/pause/; ui/quests/; tests/unit/test_pause_settings.gd, test_quest_book.gd | Chưa fullscreen/đổi cỡ chữ/đổi phím/shake/colorblind/sổ tay đầy đủ; một số nút hiện unavailable. |
| 109. 9.5 — bugbash/toàn bộ slice/save qua mọi mốc | ROADMAP9.5 | PARTIAL | FullGUT583/583 và12goldens là bằng chứng automation | Không có chiến dịch hoàn chỉnh để chơi hết; không có biên bản bugbash/end-to-end human. |
| 110. 9.6 — Windows export/cài cleanPC | ROADMAP9.6 | NOT_STARTED | Không có export_presets.cfg trong project; không có artifact release được tài liệu dẫn | Chưa xác định exporttemplates/build .exe/clean-machine result; không khẳng định có bản chạy ngoài repo. |
| 111. 9.7 —3–5người lạ/30 phút/metrics | ROADMAP9.7 | BLOCKED | Không có playtest record đáp ứng Master16.6 trong docs | Chờ chủ dự án tuyển/ghi3–5người, tỷ lệmuốn tiếp>=~60% và3vấn đề ưu tiên. |
| 112. GATE B — xác nhận strangers muốn chơi tiếp | ROADMAP GateB; Master3.5/16.6 | BLOCKED | PROGRESS không có biên bản GateB passed;9.7 chưa có | Chờ kết quả9.7; không tự mở scope social từ test pass. |

### ROADMAP10–12

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 113. 10.1 — NetworkGateway/MockBackend/offlinefallback | ROADMAP10.1 | NOT_STARTED | Census không có NetworkGateway/MockBackend/scripts/net; ARCH network là target | Chưa có interface/mock; chỉ triển khai sau GateB. |
| 114. 10.2 — sign-in/friendcode/gift idempotent/capped | ROADMAP10.2 | NOT_STARTED | Không có auth/friends/inbox owner, schema hay test tương ứng | Cần GateB và lựa chọn backend/provider/quota; không có tài khoản người dùng hiện tại. |
| 115. 10.3 — versioned friendfarm snapshots | ROADMAP10.3 | NOT_STARTED | Không có network farm snapshot/visit endpoint/test | Local save không phải snapshot thăm bạn. |
| 116. 10.4 — community project ledger/caps/solo | ROADMAP10.4 | NOT_STARTED | Không có CommunityProjectState/service/test | DayLedger là sổ thu/chi cá nhân, không phải sổ đóng góp cộng đồng. |
| 117. 10.5 — casualleaderboard/servervalidation/report | ROADMAP10.5 | NOT_STARTED | Không có leaderboard/server validation/report flow | Chưa có backend; không coi leaderboard giả là chức năng đã có. |
| 118. 10.6 — privacy/accountdelete/serverdown | ROADMAP10.6 | NOT_STARTED | Không có tài khoản/backend/privacy/deleteaccount flow trong project | Quyết định provider và thông tin dữ liệu thu thập còn thiếu; legal checklist chưa được nghiệm thu. |
| 119. 11.1 — optionalofflinecatchup/cap/clockrewind | ROADMAP11.1; D03 | NOT_STARTED | Runtime chỉ tiến ngày khi clock game chạy; không có offline catch-up service/test | D03 chủ động tắt MVP; đây là chưa bắt đầu, không phải lỗi mấttiếnbộ offline. |
| 120. 11.2 —4mùa đầy đủ/lễhội | ROADMAP11.2 | PARTIAL | data/seasons/; data/crops/; tests/unit/test_seasons.gd; commit a3b6f56 | Có4mùa/cropdata; chưa đủ hoạt động/decor/lễhội/calendar từng mùa. |
| 121. 11.3 — extendedweather +15–25Director events | ROADMAP11.3 | PARTIAL | data/weather_profile.tres có sunny/cloudy/rain/storm; tests/unit/test_weather.gd | Chưa fog/heat/snow gameplay và chưa có bất kỳ Director event; cosmetic snow lịch sử không thay dữ liệu thời tiết. |
| 122. 11.4 — fishing/foraging/collections | ROADMAP11.4 | NOT_STARTED | Không có FishingState/ForageState/CollectionState hay data tương ứng | Ao/suối nạp bình chưa có câu cá/hái lượm. |
| 123. 11.5 — quality/fertilizer/soil/irrigationautomation | ROADMAP11.5 | NOT_STARTED | Không có quality metadata/fertilizer/soilfertility/sprinkler domain; CropData chỉ waterneed/growth | Bình có giới hạn và mưa tự tưới không phải hệ tự động hóa tưới. |
| 124. 11.6 —6–8 NPC/outfits/trang trí sâu | ROADMAP11.6 | PARTIAL | CharacterAppearanceCatalog có recipe4 NPC/art; actual data/npcs/phase8_world.tres chỉMinh/Linh; test_chibi_characters.gd | Chưa6–8 NPC gameplay/outfits sau tạo nhân vật/xây trang trí tự do/thú cưng thêm. |
| 125. 11.7 — ChapterIII/postgame/directormaintenance | ROADMAP11.7 | NOT_STARTED | Không có campaign/director/endgame flags/quest data | Chưa có ChươngI/II nên chưa có nội dung hậu game. |
| 126. 11.8 — gamepad/fullaccessibility/achievements | ROADMAP11.8 | NOT_STARTED | project.godot không đăng ký joypad events; không có achievements owner | GUI focus bằng bàn phím có nhưng không đủ hỗ trợ gamepad/trợ năng/thành tựu. |
| 127. 11.9 — profiling/quality/loadingoptimization | ROADMAP11.9 | PARTIAL | C0–C3 có meshbudget tests; D72-C2 có thời gian runner | Chưa có GPU/CPU/FPS/memory baseline và benchmark trên phần cứng mục tiêu; thời gian test không phải gameperf. |
| 128. 11.10 — localization hoàn thiện/editorial dài | ROADMAP11.10 | PARTIAL | localization/strings_vi.csv, strings_en.csv; test_localization.gd; layout vi/en3size | Có wiring/captures, chưa có biên bản người dịch kiểm toàn nội dung/ultrawide/DPI. |
| 129. 12.1 — Steam/store/trailer/gallery/description | Master roadmap12.1; ROADMAP12 | NOT_STARTED | Không có store/trailer artifact được project dẫn | Không xác định được store ngoài repo; thiếu link/bằng chứng người dùng. |
| 130. 12.2 — closedbeta20–100người/2–4tuần | Master12.2; ROADMAP12 | NOT_STARTED | Không có beta plan/result/player metrics | GateB chưa có; chưa có export để chia sẻ. |
| 131. 12.3 — bugfix/balance ổn định sau beta | Master12.3; ROADMAP12 | NOT_STARTED | Không có beta issue ledger/exitcriteria | Các bugfix riêng đã có không chứng minh hoàn thành release balance. |
| 132. 12.4 — legal/privacy/license releasecomplete | Master12.4; ROADMAP12 | BLOCKED | docs/CREDITS.md chưa có dòng tác giả/giấy phép pack supplied tiles/crops/machines; chưa có privacy artifact | Cần người dùng cung cấp nguồn/quyền sử dụng pack và thông tin dịch vụ/dữ liệu của bản phát hành. |
| 133. 12.5 — phát hànhv1.0 | Master12.5; ROADMAP12 | NOT_STARTED | Version hiển thị0.1.0 trong Main/title/save; không có export_presets.cfg/release artifact | Chưa QA/beta/đóng gói/phát hành. |
| 134. 12.6 — hậu kỳ/patch/freeupdates | Master12.6; ROADMAP12 | NOT_STARTED | Không có releasev1.0/postlaunch plan được nghiệm thu | Chỉ bắt đầu sau phát hành; không tính sửa code hiện tại là postlaunch. |

### Kế hoạch bổ sung và bàn giao

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 135. D62 — khôi phục Player, giữ cây/máy | PROGRESS repair2026-11-04; D62 | DONE_UNCOMMITTED | scripts/player/player.gd; scripts/view/main.gd; tests/unit/test_player_restoration.gd | Đúng yêu cầu khôi phục trước đây, chưa commit. Hiện đối lập với mục tiêu gỡ Player trong danh sách audit mới; phải ghi lại thứ tự quyết định khi triển khai chuyển đổi. |
| 136. D72 — polishcamera/avatar/world/frame offline | PROGRESS D72; D72/D73 | DONE_UNCOMMITTED | tools/build_isometric_2d_assets.gd; scripts/view/placeholder_avatar_2d.gd; tests/unit/test_d72_visual_review.gd, test_d72_animation.gd | Đúng bản handoff đã làm rõ:5 PNG draft chưa phải runtimebindings; chưa commit. |
| 137. D72-C1 — wheelcamera/hotbar, máy xong vềidle, generator | PROGRESS D72-C1; D73 | DONE_UNCOMMITTED | scripts/view/camera_rig.gd; machine_presentation.gd; tests/unit/test_d72_camera_input.gd, test_d72_animation.gd, test_d72_visual_review.gd | Các timeout180s cũ không còn tái hiện vớiC2 trong lượt audit; chưa commit. |
| 138. D72-C2 — fullrunner2 nhóm tuần tự/giữtest vàbound | PROGRESS D72-C2; D74 | DONE_UNCOMMITTED | tools/run_graphics_tests.ps1; tools/run_tests.bat; audit manifest140scripts/583tests,2nhóm70/70,180s/nhóm | Chưa commit; fullwall241.840s không phải giới hạn180s cho tổng2 nhóm. |
| 139. D72-C3 —4 tool/4item/page/highlight/legacy9 | PROGRESS D72-C3; D75 | DONE_UNCOMMITTED | ui/hud/toolbar.gd; scripts/view/hotbar_panel.gd; tests/unit/test_d72_toolbar_selection.gd | Chưa commit; ghi chú API5item cũ chưa được dọn hết. |
| 140. D72-C4 — locale nhãn nhà/shop/NPC/toast | PROGRESS D72-C4; D76 | DONE_UNCOMMITTED | scripts/view/world_presentation.gd; npc_system.gd; ui/hud/toast_stack.gd; tests/unit/test_d72_locale_refresh.gd | Chưa commit; ảnh/callback/locale được full gate chạy lại. |
| 141. M0 — baseline/smoke/autoplay/fullcapture/build_assets | docs/MASTER_PROMPT.md; D28 | PARTIAL | tools/run_tests.bat và các tools/art_review_*.bat tồn tại; PROGRESS ghi M0 hoãn | Thiếu tools/smoke_run.bat, autoplay.bat, capture_screenshots.bat, build_assets.bat và baseline FPS/tag theo yêu cầu; captureGUT không đủ ma trận toàn game. |
| 142. M1 — NPC/quest/social/save đã làm | docs/MASTER_PROMPT.md M1 | DONE | scripts/view/npc_system.gd; scripts/domain/quests/quest_manager.gd; tests/unit/test_npc_quest_delivery.gd, test_npc_social_save.gd, test_npc_schedule.gd; commit 8a30283/tag npc-quests | Giới hạn nội dung2 NPC được ghi rõ; không gán DONE cho chó/ChươngI. |
| 143. C0/M2 — artfoundation lịch sử/builder/budget | PROGRESS C0; CHIBI_STYLE_PROMPT C0 | DONE | data/art/palette/chibi_valley.tres; tools/art/chibi/chibi_mesh_builder.gd; tests/unit/test_chibi_art_foundation.gd; commit 8654a50 | Runtime3D đã bị ISO-1 thay, kho art/test vẫn giữ; không phải art2D cuối. |
| 144. C1/M3 — character/model/cosmetic/emotion lịch sử | PROGRESS C1; D29 | DONE | tools/art/chibi/chibi_character_builder.gd; tests/unit/test_chibi_characters.gd; commit 18f1715 | Chó chỉ art/reference; không bao gồm pet8.5 hay4 NPC gameplay. |
| 145. C2/M4 — crop/item/tool/soil/effect art lịch sử | PROGRESS C2; D30 | DONE | tools/art/chibi/chibi_farming_builder.gd; tests/unit/test_chibi_farming.gd; commit 879d689 | Crop3D ở archive; sticker/tool/icon vẫn có consumer, suppliedcrop mới xử lý riêng. |
| 146. C3/M5–M6 — world/cosmeticseason art lịch sử | PROGRESS C3; D31 | DONE | tools/art/chibi/chibi_world_builder.gd; tests/unit/test_chibi_world.gd; commit 59d002b | Không tính archivebutterflies là ecology runtime mới. |
| 147. C4/M7 — UI/motion/cursor lịch sử | PROGRESS C4; D32 | DONE | scripts/view/chibi_ui_motion.gd; chibi_cursor.gd; tests/unit/test_chibi_ui.gd, test_ui_mouse.gd; commit dfd481c | Theme cũ đã có baselineISO-2 thay; giữ phạm vi lịch sử không yêu cầu menu3D quay lại. |
| 148. C5/M8 — music/ambient/NPCmumble/buses | PROGRESS NEXT C5; CHIBI_STYLE_PROMPT | PARTIAL | scripts/core/audio_service.gd; assets/audio/hoe.wav; seed.wav; water.wav; harvest.wav; tests/unit/test_audio_assets.gd; commit 19abb21 | Chỉ4SFX; chưa nhạc mùa/ambient/NPC/bus/transition. Không có tag chibi-audio. |
| 149. C6 — consistency/FPS/size/finalimage review | CHIBI_STYLE_PROMPT C6 | NOT_STARTED | Không có tag chibi-v1/biên bản tổng hợp FPS-size-finalreview trong docs | Có review từngmốc không thay final toàn game; 3D superseded cần chốt chuẩn2D. |
| 150. M9 — ít nhất2 máy/chế biến/buffer qua ngủ | docs/MASTER_PROMPT.md M9 | DONE_UNCOMMITTED | data/machines/7 Resource; scripts/domain/production/machine_state.gd; tests/unit/test_machine_state.gd, test_machine_collection.gd | Chưa commit/tag crafting; giá sản phẩm0/tiến trình nâng nhà thiếu được ghi việc riêng. |
| 151. M10 — xây dựng/decor/hàngrào/thùng/máy/đất | docs/MASTER_PROMPT.md M10 | PARTIAL | MachinePlacementFlow/LandRuntime; tests/unit/test_machine_move_ui.gd, test_land_runtime.gd | Máy/đất có; chưa generic BuildingData/uid/fences/chests/decor placement. |
| 152. M11 — sinh thái/Cỗmáy/cốttruyện/endcredits/freeplay | docs/MASTER_PROMPT.md M11 | NOT_STARTED | Census không EcologyState/EventDirector/MomentData/campaign flags | Thiếu cả câu chuyện/hệ thống/màn kết; không có tag ecosystem-story. |
| 153. M12 — thư bà/tutorial/notebook/codex/context hints | docs/MASTER_PROMPT.md M12 | PARTIAL | TutorialQuestState/QuestBook/InteractionPrompt; tests/unit/test_onboarding.gd, test_quest_book.gd | Có hướng dẫn7 bước và1quest; thiếu thư bà tiến trình/sổ cây-NPC-côngthức/collection. |
| 154. M13 — sim200 ngày/2năm/balance các hệv1 | docs/MASTER_PROMPT.md M13 | PARTIAL | test_full_year_economy_simulation.gd112 ngày; test_weather_rolls.gd golden | Chưa multi-strategy/200/730 ngày toàn economy/gifts; weather1000 ngày không thay economy200 ngày. |
| 155. M14 — settings đầy đủ/trợ năng | docs/MASTER_PROMPT.md M14 | PARTIAL | ui/pause/; Settings locale/volume; tests/unit/test_pause_settings.gd | Thiếu windowmode/resolution/vsync/quality/rebind/fontsize/colorblind; lưu musicvolume chưa có trình phát nhạc. |
| 156. M15 —400 ngày/fuzz/autoplay/perf/export/readme/credits/v1 | docs/MASTER_PROMPT.md M15 | PARTIAL | FullGUT583/583; golden1–12; docs/CREDITS.md | Chưa400 ngày toànworld/randomautoplay/leaksoak/perf/exportpreset/creditscreen/READMErelease/version1.0. |

### Mục tiêu riêng của master/prompt

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 157. DESIGN-1 — gỡ Player/WASD/Shift/player_config/creation/Character | Prompt audit; D50-manager; D62 | NOT_STARTED | scenes/world/gray_box_world.tscn; scripts/player/player.gd; data/player_2d_config.tres; ui/character/character_flow.gd; test_player_restoration.gd PASS | Trong cây runtime hiện tại việc gỡ này chưa được áp dụng; D62 đã phục hồi toàn bộ. Target audit mới được dùng làm chuẩn đối chiếu; cần kế hoạch chuyển tương tác và bảo toàn save trước khi viết mã. |
| 158. DESIGN-2 — camera quản lý độc lập/kéo-touch/pinch/clamp/cursor | PROGRESS DESIGN-2; prompt audit | PARTIAL | CameraRig.set_target(Player); test_camera_rig.gd; test_d72_camera_input.gd | Có dragRMB/MMB/wheel/bounds; chưa independentcamera/touch/pinch/threshold/cursorpivot-zoom; max1.25 khác đề xuấtmanager1.0. |
| 159. DESIGN-3 — Ctrl+M exact/debugonly không kích M | PROGRESS DESIGN-3; prompt audit | PARTIAL | project.godot toggle_debug_menu Ctrl+M; scripts/view/main.gd:93; ui_coordinator.gd:223; test_player_restoration.gd | Chưa truyền exact_match=true; nhánh chuyển modal thiếu OS.is_debug_build; chưa có test release hoặc Ctrl+M đối chiếu open_map. Điều khiển debug +1000 xu/cấp nhà1–3 của đề xuất chưa có. |
| 160. DESIGN-STAMINA — giữ thể lực nhưng có owner/data/UI/save thật | Prompt audit; D50-manager vs D10,D34,D62 | BLOCKED | Census không có StaminaState, Resource hay key stamina; HUD không có meterstamina | Không có hệ cũ để giữ. Yêu cầu giữ stamina đã rõ; cần dữ liệu sức chứa/chi phí/hồi qua ăn-ngủ và hợp đồng save trước khi triển khai. |
| 161. ASSET-DECOR — dùng tuft/flower/pebble trên cỏ | Prompt tổng hợpC1/C2; ISO12–14 | PARTIAL | assets/decor/18 PNG có; không tìm runtime consumer; WorldPresentation chỉ resolve rocks/grass_clumps | Mới nhập file; chưa rải9variantdecor theohash/chỉtrêncỏ/lớpDecor. |
| 162. ASSET-OBJECTS — tree_fruit/bush thật | Prompt tổng hợpC1; ISO12 | PARTIAL | assets/objects/4 PNG có; không có reference runtime; PlaceholderWorld2D vẽ tree | Mới nhập; chưa bind sprite thay cây/bụi placeholder. |
| 163. ISO12-IMPORT — phạm vi duyệt: nhập nguồn, atlas128×64, nền không viền | PROGRESS ISO-12 ALLOW_LIST/acceptance; D50-ground | DONE | assets/tiles/tileset/ground_tileset_128x64.tres; scripts/view/gray_box_world.gd; tests/unit/test_isometric_migration.gd; commit d1bc16a | Hoàn thành phần import/ground được duyệt; mục tiêu nhiều layer/đủ decor của roadmap/prompt rộng hơn vẫn PARTIAL ở ISO-12 và ASSET-DECOR/OBJECTS. |
| 164. ASSET-D72-PNG —5 PNG sinh mới dùng trong runtime | D72 đầu; D73/CREDITS làm rõ draft | PARTIAL | assets/buildings/*_2x.png; assets/characters/farmer_sheet_2x.png; assets/ui/frame_wood_9slice.png; test_d72_visual_review.gd | Có file/generator/validator, chưa runtimebindings; D73 đã nói rõ draft nên không kết luận DOC_ONLY do đoạnD72cũ. |
| 165. CROP-STAGES —4giai đoạn chia đều theo dữ liệu | D49; promptC3; ROADMAP ISO15[x] | PARTIAL | CropPresentation.get_stage_id dùngfloor(ratio*3); FarmGridState.advance_day dùngceil(target/4) | Care vàvisual chia stage khác nhau; không có test boundary1/4,1/2,3/4 đối chiếu; không phải test đang fail. |
| 166. CROP-PERENNIAL-STAGE3 — sau thu còn cây vềstage3 | D49; promptC3; ROADMAP ISO15[x] | DOC_ONLY | CropCycleRules.begin_repeat đặt growth_days=0; FarmView chuyển ratio0; CropPresentation renderstage1; test_crop_regrow.gd chỉ đảm bảoregrow logic | Không tìm branchregrowing/perennial đưa artstage3; thiếu test cho5 cây lâu năm sau thu. Quy tắc được tài liệu rộng đánh dấu xong nhưng không có implementation tương ứng. |
| 167. CROP-CARE — héo tại stage/tưới-mưa cứu/2 ngày chết/xẻng | D56; promptC3 | DONE_UNCOMMITTED | FarmGridState.water_cell/advance_day/clear_withered; ToolAction shovel; tests/unit/test_crop_care.gd, test_crop_care_ui.gd | Chưa commit; stage threshold cần đồng bộ CROP-STAGES trước khi khẳng định đúng toàn bảng stage. |
| 168. CROP-ICONS —16 icon nông sản thật | PromptC3 ghi chưa cóicon | BLOCKED | Supplied crop produce ItemData.icon_path rỗng; UiIcons/LifeInventoryIcon fallback | Cần người dùng cung cấp bộicon hoặc chọn tạo bằng công cụ; placeholder hiện được cho phép, không bịa sốgameplay. |
| 169. UI-OWNERS — EconomyService/InventoryService như D54/55 tuyên bố | D54,D55; PROJECT_RULES§2 | DOC_ONLY | Census không có2 class; SeedShopPanel.try_buy_item trực tiếp WalletState/InventoryState | Giao dịch thật có test và rollback; tên/ownership service mà tài liệu khẳng định đã giữ không tồn tại. Cần sửa hợp đồng hoặc di chuyển authority ở scope riêng. |
| 170. LOG-UTILITY — ARCH mô tả staticLog sẵn có | ARCHITECTURE.md:244; ROADMAP0.6 | DOC_ONLY | Census không Log/log.gd; code dùng push_warning/push_error trực tiếp | Không có utility/context test; debug overlay là implementation khác, nên0.6 chỉPARTIAL. |
| 171. MASTER-SEASONALWEATHER — probability theo mùa/forecastkhóaM2.4 | MasterS12/D17/M2.4 | PARTIAL | WeatherProfile1bảng55/25/15/5; WeatherRoller theo seed/day; tests/unit/test_weather_rolls.gd | Chưa seasonalweights hay unlockforecast; HUDhiệnforecasttừđầugame. Khác targetstory, không vi phạm scope7.1b đã duyệt. |
| 172. MASTER-PRODUCTIONCHAIN — wheat→flour→bread→order→coin | MasterA10/verticalslice/S22 | PARTIAL | data/recipes/mill_wheat_flour.tres dùngautumn_wheat→temp_wheat_flour; oven_corn_bread.tres dùngcorn | Chưa có flour→bread/đơn An; tempoutput sell0 và chưa nâng nhà2. Chưa có recipe dùng trứng từ chuồng như S22; chuỗi sữa/bơ/hoa/mứt là nội dung tương lai. |
| 173. MASTER-JOBCANCEL — hủy job hoàn nguyên liệu theo policy | MasterS10 | NOT_STARTED | MachineState có start/advance_day/take_output, không có cancel | Chưa có lệnh/chính sách/hoàn trả/test; cất máy đang bận hiện bị chặn đúng. |
| 174. MASTER-GENERICBUILDINGS —uid/BuildingData/hàngrào/rương/decor/refund | MasterS11/A9 | PARTIAL | MachinePlacementState cócell/id/rotation; coopfixedsite; tests/unit/test_machine_placement.gd | Không có genericBuildingData/uid/buildmenu hayrefundconfig, nội thất/nhà kính. |
| 175. MASTER-7REGIONS —farm/làng/rừng/hồ/đồngcỏ/đồi/thunglũngxa | MasterA8; verticalslice3.2 | PARTIAL | OneGrayBoxWorld, home/shop/NPCmarkers/watersources; test_water_source_world.gd | Cóprototype farm, anchor và ao/suối; chưa6 vùng còn lại với bản đồ, mở khóa, nội thất và hoạt động; map39×39 không đồngnghĩa7vùngđãlàm. |
| 176. MASTER-M2.1 — sửa kênh/mở tưới tự động | Master4.3 | NOT_STARTED | Không có quest/cờ sửa kênh hay dữ liệu vòi phun | Bình tưới thủ công không phải phục hồi kênh. |
| 177. MASTER-M2.2 — khôi phục cối/chuỗi bánh/đơn hàng | Master4.3 | NOT_STARTED | Có MachineData mill, nhưng không repairmilestone/quest/cờ unlock | Mua máy không thay mốc truyện sửa cối. |
| 178. MASTER-M2.3 — sửa cầu/mởMinh/khuđông/hạt | Master4.3 | NOT_STARTED | Minh được lên lịch ngay từNpcsWorld; không bridgequest/flag | Lôfirst_east không có cầu hay điều kiện truyện. |
| 179. MASTER-M2.4 — sửa trạm/Cỗ máy Mùa/Director/forecastunlock | Master4.3 | NOT_STARTED | Không có station/Director/MomentData; forecast hiện sẵn | Thiếu toàn bộ mốc WOW và chuyển hệ thống. |
| 180. MASTER-M2.5 — nhật ký bà/mở sổ sinh thái | Master4.3 | NOT_STARTED | QuestBook chỉ onboarding/Minh; không EcologyState/campaignflag | Không có sổ/chương/điều kiện mở khóa. |
| 181. MASTER-WOW-W1–W6 —MomentData theo điều kiện | Master4.5/W1…W6 | NOT_STARTED | Không có MomentData/MomentService/data/moments; weather/world cosmetickhôngquerymilestone | Thiếu W1 bướm khi mưa/hoa; W2 trăng sau sửa hồ; W3 quảng trường; W4 trạm; W5 hội thu hoạch; W6 bạn ghé. |
| 182. MASTER-SAVE-RECOVERY — backup được phục hồi khi slot hỏng | MasterS16/F5 | PARTIAL | SaveService._rotate_backups/MAX_BACKUPS=3; load_game chỉ_open(_save_path(slot)); test_save_service.gd | Có backupwrite/migrate/codec; không đọc .bak dự phòng hay UI chọn phục hồi. |
| 183. MASTER-SOAK —5000 ngày/khôngrò/NaN/âm | Master16.4 | NOT_STARTED | Weather1000 ngày và economy112 ngày có; không tìm harness simulate_days5000 harness | Chưa có soak toàn world/resources/memory; full suite pass không thay soak. |
| 184. MASTER-COMPATIBILITY —DPI/ultrawide/2560/GPUyếu/layoutkey | Master16.8 | PARTIAL | UItestsvi/en1152×648,1280×720,1920×1080; auditrenderForward+ | Chưa có kết quả2560/ultrawide/DPI/bố cục bàn phím/PC sạch; không suy hiệu năng GPU tích hợp từ máy hiện tại. |
| 185. MASTER-S28 — telemetry tùy chọn, chỉ khi đồng ý | MasterS28 | NOT_STARTED | Không thấy telemetry/analytics runtime owner/call | Chủ động chưa triển khai; chỉ xem xét sau1.0/khi có đồng ý, không tự thêm trong phạm vi hiện tại. |

### Đối chiếu15mockup đầy đủ

| Mục tiêu | Nguồn (ISO/Phase/file) | Trạng thái | Bằng chứng | Còn thiếu |
|---|---|---|---|---|
| 186. UI-01 — Menu chính | docs/ui_reference/01-menu-chinh.png; ISO8a | PARTIAL | ui/title/title_screen.tscn; tests/unit/test_title_layout.gd; ảnhiso8a_vi_latest_1152.png; commitbase a683feb | Có hành động/latestname-day-coins thật; thiếu card chân dung/playtime/cấp nhà và artwork/spacing đúng ảnh. |
| 187. UI-02 — Tạo nhân vật | docs/ui_reference/02-tao-nhan-vat.png; ISO8b | PARTIAL | ui/title/profile_form.tscn; tests/unit/test_profile_preview.gd; ảnhiso8b_vi_choice0_1152.png; commitbase57008ab | Có form6 lựa chọn, preview và submit; preview procedural khác tranh/chó. Màn hiện vẫn được giữ sau D62, trong khi target audit mới yêu cầu gỡ. |
| 188. UI-03 — HUD ban ngày | docs/ui_reference/03-trong-game-ban-ngay.png; ISO3 | PARTIAL | ui/hud/; test_isometric_hud.gd, test_d72_toolbar_selection.gd; ảnhd72_c1_vi_1152_zoom1.png | Có nhiệm vụ/clock/coins/8 ô/toast; thiếu stamina/event/K/M, một số iconplaceholder;4shortcut B/J/H/Esc thay5nút ảnh. |
| 189. UI-04 — HUD đêm/mưa | docs/ui_reference/04-trong-game-dem-mua.png; ISO1/3 | PARTIAL | WorldTint/WeatherFx; test_day_night.gd, test_weather.gd; ảnhd72_c1_vi_night_rain.png | Có tối/mưa/cửa sổtheo state; HUDthiếu nhưUI03; chưa art đêm và âm thanh mưa đồng nhất ảnh. |
| 190. UI-05 — Bản tin sáng | docs/ui_reference/05-ban-tin-sang.png; ISO9 | PARTIAL | ui/morning/; test_morning_layout.gd; ảnhiso9_vi_complete_1152.png; commitbaseec3c6d3 | Hiển thị3 forecast/garden/prices/onboarding thật; ảnh5 forecast/events/birthdays/xu hướng giá còn thiếu. |
| 191. UI-06 — Túi đồ | docs/ui_reference/06-tui-do.png; ISO5/6.5g/h3 | PARTIAL | ui/inventory/; test_inventory_screen.gd; ảnhiso5_vi_partial_1152.png; commitbase67c63a2 | Có lưới40/52 ô, lọc, chi tiết, F chọn stack, sắp xếp và vứt; còn thiếu Ăn/chất lượng/energy/markettrend. Hai nút nâng mới chưa commit. |
| 192. UI-07 — Nhân vật | docs/ui_reference/07-nhan-vat.png; ISO10 | PARTIAL | ui/character/; test_character_layout.gd; ảnhiso10_vi_mixed_1152.png; commitbaseb44c5d5 | Có profile, portrait và quan hệ Minh/Linh thật;5 hàng kỹ năng ghi chưa khả dụng, thiếu XP/bonus/sinh nhật/NPC thứ3. Target audit mới yêu cầu gỡ màn này; hiện chưa gỡ. |
| 193. UI-08 — Sổ nhiệm vụ | docs/ui_reference/08-so-nhiem-vu.png; ISO11 | PARTIAL | ui/quests/; test_quest_book_layout.gd; ảnhiso11_vi_active_1152.png; commitbase962bba9 | Có7 bước/1questMinh/currentpossession/rewardthật; Hằng ngày/Ghim T/Bản đồ/XP chưa có, không dựng số giả. |
| 194. UI-09 — Lịch & Sự kiện | docs/ui_reference/09-lich-su-kien.png | NOT_STARTED | LifeInventoryTabs vô hiệu hóa  calendar; không có calendarscreen/controller/dataevents/test | Clock28 ngày/7 ngày là nền, không phải mànlịch28 ô, sinh nhật, sự kiện và dự báo tuần. |
| 195. UI-10 — Cửa hàng theo ảnh | docs/ui_reference/10-cua-hang.png;6.5c | PARTIAL | ui/machine/; SeedShopPanel; test_machine_screen.gd; ảnhphase65c_vi_1152_shop.png | Máy có mua và trạng thái thật nhưngheader quá lớn, vùng nội dung bị ép; Sell/Buybackdisabled; cửa hàng hạt giống cũ; thiếuCô Hoa, giỏ số lượng, phân bón, khóa cấp nhà và chân dung. |
| 196. UI-11 — Nâng cấp nhà | docs/ui_reference/11-nang-cap-nha.png | NOT_STARTED | Không có HouseState/houseupgradescreen/config/flowtest trong census | Houselevel UI máy bị cố định1; chưa3 cấp nhà, chi phí vật liệu, lợi ích và xác nhận thật. |
| 197. UI-12 — Hội thoại | docs/ui_reference/12-hoi-thoai.png | PARTIAL | scripts/view/npc_panel.gd; npc_system.gd; test_npc_ui.gd; ảnhnpc_dialogue_vi_1152x648.png | Có hội thoại, lựa chọn, giao dịch và điểm quan hệ thật; còn là panel chung, chưa bố cục chân dung lớn/thanh dưới/phím1–3 theo ảnh. Ảnh audit bị log GUT che bên phải; phần bị che không xác định được bằng ảnh này. |
| 198. UI-13 — Kết thúc ngày | docs/ui_reference/13-ket-thuc-ngay.png; ISO4 | PARTIAL | ui/day_end/; test_day_end_layout.gd; ảnhiso4_vi_manual_1152.png; commitbasec8b94f9 | Bố cục2 cột/ledger/forecast/warning/nút thật; thiếu XP/hồi thể lực, thẻ sự kiện và minh họa như ảnh. |
| 199. UI-14 — Tạm dừng/Cài đặt | docs/ui_reference/14-tam-dung-cai-dat.png; ISO7 | PARTIAL | ui/pause/; test_pause_layout.gd; ảnhiso7_vi_tab1_1152.png; commitbase4ccc8de | Save/load/locale/volume và4 tab có; fullscreen/fontsize/keyrebind/rain/shake/autosavetoggle cònunavailable, không phải settingsđầyđủ. |
| 200. UI-15 — Bộ UI kit | docs/ui_reference/15-bo-ui-kit.png; ISO2/13 | PARTIAL | ui/components/; ui/theme/the_life_theme.tres; test_ui_gallery.gd; ảnhui_gallery_vi_1152_top.png; commitbasebf8ed55 | Có nút native, trạng thái, ô đồ, tim, token màu, font và gallery; còn thiếu bộ24 icon PNG32px theo nét mẫu, khung9-slice texture margin28 và component Label_Plate dùng chung; PNG khung nháp chưa được dùng. |

## 4. Tài liệu nói xong nhưng thực tế chưa — DOC_ONLY

Ba hàng DOC_ONLY trong sổ đối chiếu là các tuyên bố hẹp sau; không phủ nhận toàn bộ hệ thống đang chạy:

1. **Static `Log` utility:** ARCHITECTURE.md:244 nói “Logging is a static `Log` utility class”. Không có `class_name Log`/`log.gd` trong source project và không có test utility này. Mã dùng `push_warning`/`push_error` trực tiếp. DebugMenu có thật nên roadmap0.6 chỉ PARTIAL, không phải toàn bộ DOC_ONLY.
2. **Quyền sở hữu giao dịch của `EconomyService`/`InventoryService`:** D54/D55 mô tả ISO-16/17 đã giữ hai service đó. Không có hai class này. `SeedShopPanel.try_buy_item()` trực tiếp gọi WalletState/InventoryState và tự rollback. Có giao dịch và test nguyên tử thật; phần “hai service tồn tại/đã giữ ownership” mới là DOC_ONLY. Bảng WorldState ghi rõ “target” không bị tính DOC_ONLY.
3. **Cây lâu năm sau thu về stage3:** D49/promptC3 yêu cầu, còn roadmap ISO-15 rộng đánh dấu[x]. `CropCycleRules.begin_repeat()` đặt `growth_days=0`; `FarmView._render_cell()` truyền ratio0; `CropPresentation` chọn hình stage1. Không thấy nhánh perennial/regrowing để giữ stage3. Test regrow hiện kiểm chu kỳ/yield/care/save, không kiểm5 loại lâu năm vềstage3 sau thu. Đây là phát hiện từ đọc mã, **không phải một test hiện đang fail**.

Các chỗ ghi sai/lạc hậu khác được phân biệt rõ:

- ARCHITECTURE§6 còn câu “Actual format is v8” và đoạn cuối còn v4; API_INDEX có các dòng “Current save format v5/v6/v7” nằm trong lịch sử các ISO. Runtime thật `SaveService.CURRENT_VERSION=12`; golden1–12 và test migration hiện pass. Đây là tài liệu nhiều thời điểm, không phải runtime đang dùng3schema cùng lúc.
- D50 bị dùng lại cho manager-removal và imported-ground. ISO-17,6.4,6.5 cũng bị trùng ID. Nên gắn tên phân biệt trước khi mở scope tiếp theo.
- Roadmap ISO-15[x] mô tả cả16 cây/care/perennial, trong khi PROGRESS/D53 và commit25a1ff2 chỉ duyệt visual-only cho crop cũ. ISO-18 đã bổ sung data16 cây nhưng chưa commit và chưa sửa visual stage3. Không dùng tick rộng làm bằng chứng toàn bộ xong.
- D50-manager ghi no-player/exactdebug nhưng đã bị D62 khôi phục Player thay thế. Theo target audit mới, việc gỡ chưa hoàn tất trong runtime hiện tại. Không gọi đoạn lịch sử đã superseded là DOC_ONLY.
- D72 từng mô tả “generatedPNG visuals”; D73/API/CREDITS đã nói rõ5 PNG là draft/offline, renderer procedural vẫn active. Không tính sự làm rõ này là thiếu bằng chứng có chủ ý.
- D33/AGENTS tóm tắt64×32 là lịch sử. D49/ISO-12 và Resource runtime dùng128×64/zoom0.5. Master3D/Jolt/yaw đã bị D33 thay; kho nguồn3D phải được giữ theo chủ trương migration, không tự xóa.
- D42/ISO-6a nói cây héo terminal, nhưng D56 đã duyệt tưới/mưa cứu và chết sau2 ngày héo. Target master “ngoài mùa ngủ đông/không chết” là luật cũ chưa được hòa giải toàn bộ trong văn bản.

## 5. Chưa commit và phạm vi Git

Baseline Git trước khi chạy test: **95 dòng ` M`,1 dòng ` D`,1.314 dòng `??` =1.410 thay đổi**; không có file staged. HEAD `e713660` là commit tài liệu ghi ISO-11, không phải commit Phase7.1b.

| Nhóm đường dẫn pending | Số file theo git status |
|---|---:|
| assets | 945 |
| scripts | 149 |
| tests | 150 |
| ui | 90 |
| data | 39 |
| docs | 25 |
| tools | 7 |
| localization | 2 |
| project.godot | 1 |
| the_life_prompt.md (deleted) | 1 |
| the_life_master_prompt.md (untracked) | 1 |

**Các phần đã commit trên tổ tiên HEAD:**

| Phạm vi | Commit bằng chứng |
|---|---|
| Core farming/tools/harvest/clock/save/locale/economy nền | 98677d8,a7ed5ac,9bba112,3f5583d,645c400,5b5bb4c,03e88d4,3e2e221,233a7de,e7b6f8c,c459ba7,5c4f5a5 |
| Weather/daynight/seasons nền | 59292c1,655077b,a3b6f56 |
| NPC/merchant/quests/social/save4 | 88dee11,f4a4a8b,186bc59,cafc3ee,5da2d1a,8a30283 |
| C0–C4 lịch sử | 8654a50,18f1715,879d689,59d002b,dfd481c |
| ISO-1/2/3/4/5/6a/6b1 | 818a7de,bf8ed55,8706dfb,c8b94f9,67c63a2,7f7a429,4b3ca62 |
| ISO-7/8a/8b/9/10/11 | 4ccc8de,a683feb,57008ab,ec3c6d3,b44c5d5,962bba9 |
| ISO-12 ground / ISO-14 scenery / ISO-15 visual-only |d1bc16a,ceb17bd,25a1ff2 |
| Xác nhận tài liệu ISO-13/16/17 |ISO-13 dùng code có sẵn; bba2d1c và4eed9a0 chỉ là commit chấp nhận tài liệu, không thêm domain16 cây/máy |

**Chưa có commit implementation trên HEAD cho:** ISO-18 data/care, machine6.1–6.5f, land6.4a/b, bag6.5g, water6.5h1/h2a/h2b/h3, coop6.6a–d, recipe6.7, weather7.1a/b, D62 restore, D72/C1/C2/C3/C4. Có file/test thật và full gate pass không thay điều kiện commit. Các ref “Agent host session” từ `git log --all` là checkpoint; báo cáo chỉ dùng commit tổ tiên HEAD làm bằng chứng “đã commit phase”.

**File đặc biệt/ngoài scope mới nhất:**

- `the_life_prompt.md` đang ` D` từ trước audit; không khôi phục/xóa thêm. `the_life_master_prompt.md` đang `??`, đã đọc làm nguồn nhưng chưa tracked.
- `ui/ui_gallery.gd`, `.gd.uid`, `.tscn` đều tracked và clean ở baseline; ví dụ xóa gallery chỉ là sự cố lịch sử ISO-12 đã được khôi phục.
- `project.godot` đang sửa từ trước. Không quy thay đổi InputMap hiện tại cho lượt audit.
- ALLOW_LIST Phase7.1b hiện tại có đúng57 path, cả57đều pending. **1.353 path pending khác nằm ngoài57 path này.** Chúng chứa nhiều phần đã được chủ dự án duyệt ở các scope cũ; “ngoài latest scope” không đủ kết luận “không được phép sửa”. Không xác định được phê duyệt từng file kế thừa chỉ bằng Git, vì lịch sử commit/task bị dồn và không có baseline duyệt duy nhất cho toàn bộ1.410 path. PROGRESS có nhiều ALLOW_LIST và các backup giao việc riêng; cần giữ bằng chứng đó khi tách commit về sau.
- Có945assetpending, trong đó848 file nguồn lồng `assets/the_life_assets/`,85 file máy,5PNGdraft và các import đi kèm. Không gộp việc thêm file source với bằng chứng nó đã dùng trong gameplay.

Danh sách **toàn bộ1.410dòng Git baseline** nằm ở Phụ lụcA; danh sách57 path latest scope ở Phụ lụcB. Lượt kiểm toán không stage/commit hay làm sạch các thay đổi này.

## 6. Asset: có trong project và có đường tham chiếu thực tế

Quét các đường `res://assets/...` trong `.gd/.tscn/.tres` và kiểm thêm đường tạo động bằng manifest, prefix vàDataRegistry. Không dùng grep literal đơn lẻ để kết luận sprite nạp động là mồ côi. “Không thấy runtime consumer” dưới đây có nghĩa không tìm thấy trong những đường active đã truy, không khẳng định tool/archive không bao giờ đọc file đó.

| Root | PNG | File tổng kể cả import/data | Đường nạp/hiển thị thực tế | Phần chưa dùng |
|---|---:|---:|---|---|
| assets/tiles | 34 | 70 | GrayBoxWorld preload ground_tileset_128x64.tres, gánGround/Farmland; TileSet dùng ground_atlas_128x64.png | Atlas64×32 cũ và32 ảnh layer chủ yếu là source/legacy; chưa dùng đủ path/water/sand trong TileMap riêng |
| assets/decor | 18 | 36 | Không tìm consumer runtime cho9ảnh2x hay9bản1x | Đã nhập nhưng chưa rải tuft/flower/pebble |
| assets/objects | 4 | 8 | Không tìm consumer runtime cho tree_fruit/bush | 2ảnh2x+2bản1x; cây hiện procedural |
| assets/rocks | 18 | 36 | WorldPresentation dựng động rock_{small,medium,large}_{1..3}.png theo hash | 9bản1x giữ làm source; chỉlarge có collision |
| assets/grass_clumps | 18 | 36 | WorldPresentation dựng động grass_clump_{small,medium,large}_{1..3}.png | 9bản1x source; không collision |
| assets/crops | 288 | 578 | CropPresentation16×8 stage/wilt; DataRegistry16seedicon từ manifest | 144ảnh1x source; produceicon16 cây chưa có |
| assets/machines | 42 | 85 | MachineData.sprite_dir→MachinePresentation/LifeMachinePresenter;21idle/work_a/work_b | 21ảnh1x source; sprite xoay4hướng chưa có |
| assets/the_life_assets | 422 | 848 | Không có consumer runtime tới prefix nguồn lồng | Toàn bộ422 PNG có bản canonical tương ứng và SHA256 trùng **422/422**; giữ source không có nghĩa đã tích hợp |

Có16candidate PNG không tìm thấy consumer runtime, liệt kê đầy đủ ở Phụ lụcC:9decor2x,2objects2x,3buildingdraft,1farmersheetdraft,1woodframedraft. Nhiều bản1x/atlasinput/sourcebundle cũng không nạp trực tiếp nhưng có mục đích lưu nguồn, được tách riêng; không đề nghị xóa tự động.

`assets/ui/title_valley.png` có consumer `scripts/view/title_backdrop.gd`. Các tool icon nạp bằng `assets/generated/icons/tool_%s.png` và item sticker theo `ItemData.icon_path` vẫn có consumer2D; không được gán mồ côi chỉ vì model3D cùng bộ đã thành archive. Tổng `assets/generated/` có162 file:99scene,22 PNG,22import,5material,5 shader,5 UID,4JSON; model3D và reviewtest là di sản được chủ động giữ, icon2D vẫn dùng.

**Metadata trùng:**380 UID import bị dùng lặp ở760 file `.import`, điển hình cùng ảnh ở canonical vàsourcebundle. Điều này là kết quả quét UID, không phải lỗi load đã tái hiện trong lượt audit. Parse/Main hiện không cảnh báo; vẫn là nợ import/editor và cần xử lý bằng scope riêng nếu đổi cách giữ nguồn. Không tự sửa UID/asset trong kiểm toán.

### 6.1. 16 cây: kiểm kê data/art và các thiếu sót dùng chung

Mỗi dòng trỏ subresource trong `data/crops/supplied_crop_catalog.tres` và thư mục art riêng. Test `tests/unit/test_farm_view.gd::test_manifest_covers_all_supplied_crop_visual_sets_and_registered_crop_data` kiểm tất cả16entry; `test_supplied_crop_visuals_use_manifest_pivots_and_wilted_stage_assets` kiểm texture/pivot. Đây là bằng chứng đăng ký/file/visual, **không phải16 test lifecycle đầy đủ**. Registry giữ9IDcũ và thêm16IDmới; không rename save ID.

| Crop | Loại manifest / vật phẩm trồng | Growth / regrow (ngày, Resource) | Giá trồng / bán produce | PNG canonical / pivot | Bằng chứng |
|---|---|---|---|---|---|
| `strawberry` | annual / seed | 6 /0 | 40 /70 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_strawberry`; `assets/crops/strawberry/` |
| `eggplant` | annual / seed | 6 /0 | 40 /65 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_eggplant`; `assets/crops/eggplant/` |
| `chili` | annual / seed | 5 /0 | 30 /50 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_chili`; `assets/crops/chili/` |
| `cabbage` | annual / seed | 5 /0 | 30 /55 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_cabbage`; `assets/crops/cabbage/` |
| `rice` | annual / seed | 6 /0 | 30 /55 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_rice`; `assets/crops/rice/` |
| `sunflower` | annual / seed | 7 /0 | 45 /80 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_sunflower`; `assets/crops/sunflower/` |
| `coffee` | perennial / seed | 14 /4 | 120 /90 | 9/9; (80, 148) | `data/crops/supplied_crop_catalog.tres#Crop_coffee`; `assets/crops/coffee/` |
| `pepper` | perennial / cutting | 12 /3 | 150 /70 | 9/9; (80, 148) | `data/crops/supplied_crop_catalog.tres#Crop_pepper`; `assets/crops/pepper/` |
| `orange` | perennial / sapling | 16 /4 | 250 /60 | 9/9; (80, 148) | `data/crops/supplied_crop_catalog.tres#Crop_orange`; `assets/crops/orange/` |
| `apple` | perennial / sapling | 14 /4 | 220 /55 | 9/9; (80, 148) | `data/crops/supplied_crop_catalog.tres#Crop_apple`; `assets/crops/apple/` |
| `banana` | perennial / sucker | 12 /3 | 180 /45 | 9/9; (80, 148) | `data/crops/supplied_crop_catalog.tres#Crop_banana`; `assets/crops/banana/` |
| `carrot` | annual / seed | 3 /0 | 20 /35 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_carrot`; `assets/crops/carrot/` |
| `tomato` | annual / seed | 5 /2 | 35 /60 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_tomato`; `assets/crops/tomato/` |
| `radish` | annual / seed | 4 /0 | 25 /45 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_radish`; `assets/crops/radish/` |
| `corn` | annual / seed | 7 /0 | 60 /120 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_corn`; `assets/crops/corn/` |
| `pumpkin` | annual / seed | 8 /0 | 50 /90 | 9/9; (64, 100) | `data/crops/supplied_crop_catalog.tres#Crop_pumpkin`; `assets/crops/pumpkin/` |

Đủ64normalstage+64wiltedstage+16plantingicon. Cây một vụ128×128/pivot64,100; cây lâu năm160×176/pivot80,148; seed64×64. Việc kiểm header PNG của tất cả stage phù hợp manifest; không chỉ kiểm tên file. Loại planting theo manifest: seed cho11annual vàcoffee; cutting chopepper; sapling choorange/apple; sucker chobanana. `CropData.stage_textures/wilted_textures/pivot` có khai báo nhưng mảng Resource hiện rỗng; consumer thật resolve manifest ở VIEW. Vì vậy không kết luận mất ảnh chỉ do mảng rỗng; hợp đồng datafield và cách nạp thực tế cần viết thống nhất.

Thiếu/khác cụ thể:

- Stagevisual hiện `floor(ratio*3)` và stage4 chỉ khi mature; D49 yêu cầu4giai đoạn chia đều. Care lại dùng `ceil(target/4)`. Ví dụ target4 ngày, ở growth1/4 visual vẫnstage1; không cùng cách chia stage của care. Đây là khoảng thiếu kiểm tra boundary, không phải một test đang đỏ.
- Coffee/pepper/orange/apple/banana giữ plot khi `regrow_days>0`, nhưng sau thu ratio0 làm art vềstage1 thaystage3. Không có test riêng giữ thân trưởng thành của5 loại này. Tomato manifest annual nhưng Resource dùng `perennial=true` để tái sinh; cần tách nghĩa “cây lâu năm” và “thu nhiều lần” trong hợp đồng, không tự sửa trong audit.
- `turnip`, `spring_pea`, `autumn_wheat` không có basename trong manifest mới, còn placeholder và warning một lần. Không coi3crop cũ này là3 ảnh supplied bị thất lạc.
- Nông sản của16crop chưa có bộicon cùng phong cách. Có item thật/tên/giá nhưng icon generic hoặc SVG cũ; không phải16PNGproduce đã được tích hợp.
- Hai bộ ID cùng tồn tại, ví dụ `tomato` so với `summer_tomato`, `carrot` so với `spring_carrot`. Giá tomato60 trong catalog mới khác legacy summer_tomato72 theo D42; yield1 mới khác yield2 của9startercũ. Không kết luận code dùng giá giả; đây là dữ liệu2 bộ thực và cần cân bằng/quy hoạch migration nếu muốn hợp nhất. Không tự rename ID.

### 6.2. 7 máy: data và3 trạng thái thật

`tests/unit/test_machine_presentation.gd::test_machine_manifest_contains_supplied_visual_contract` kiểm7ID×3 file; `test_d72_animation.gd` kiểm chuyển frame, pause và completed→idle. MachineData gắn `sprite_dir`; MachinePresentation đọc manifest và thật sự `load()` texture idle/work_a/work_b, đặt offset theo pivot64,120. Animation0.4s là cosmetic; job vẫn theo ngày, không theo delta.

| Máy | Giá / cấp nhà | RecipeResource | Sprite_dir;3 file canonical | Runtime/giới hạn |
|---|---|---|---|---|
| `barrel` | 500 /2 |"barrel_pickled_cabbage" | `assets/machines/barrel/`; `barrel_idle.png`, `barrel_work_a.png`, `barrel_work_b.png` | Data/visual có; UI bị khóa vì chưa có hệ nâng nhà |
| `dryer` | 700 /2 |"dryer_dried_chili" | `assets/machines/dryer/`; `dryer_idle.png`, `dryer_work_a.png`, `dryer_work_b.png` | Data/visual có; UI bị khóa vì chưa có hệ nâng nhà |
| `mill` | 350 /1 |"mill_wheat_flour" | `assets/machines/mill/`; `mill_idle.png`, `mill_work_a.png`, `mill_work_b.png` | UI cấp1 hiện mua/khởi chạy được khi đủ điều kiện |
| `oven` | 600 /2 |"oven_corn_bread" | `assets/machines/oven/`; `oven_idle.png`, `oven_work_a.png`, `oven_work_b.png` | Data/visual có; UI bị khóa vì chưa có hệ nâng nhà |
| `press` | 450 /2 |"press_orange_juice" | `assets/machines/press/`; `press_idle.png`, `press_work_a.png`, `press_work_b.png` | Data/visual có; UI bị khóa vì chưa có hệ nâng nhà |
| `roaster` | 900 /3 |"roaster_coffee" | `assets/machines/roaster/`; `roaster_idle.png`, `roaster_work_a.png`, `roaster_work_b.png` | Data/visual có; UI bị khóa vì chưa có hệ nâng nhà |
| `stove` | 250 /1 |"stove_carrot_meal" | `assets/machines/stove/`; `stove_idle.png`, `stove_work_a.png`, `stove_work_b.png` | UI cấp1 hiện mua/khởi chạy được khi đủ điều kiện |

Có MachineInventory tách túi vật phẩm, MachinePlacementState/OccupancyMap, MachineShopService mua nguyên tử, MachineOperationService, preview/move/return và output buffer có test thật. Bảy thành phẩm được đăng ký tại `data/items/temp_*.tres`, giá mua/bán0theo duyệt; chúng không biến thành coin bằng cân bằng cuối đã hoàn chỉnh.

Hạn chế: `MachineState` chỉ lưu `days_remaining`, không `finish_at_total_minutes` như roadmap gốc; không có cancel/refundinput. `ui/machine/machine_controller.gd` truyền houselevel1 khi mua/start, snapshot khóa mọi cấp>1. Không có HouseState, nên không thể khẳng định7 máy đều mở được bằng tiến trình chơi bình thường. Rotation0/90/180/270 là logic/occupancy/save; supplied art chỉ có một hướng cho3 trạng thái, không có4hướng hình.

## 7. InputMap: có phím không đồng nghĩa có chức năng

| Phím mục tiêu | InputMap thực tế | Luồng hiện tại | Kết luận đối chiếu |
|---|---|---|---|
| B | open_inventory; thêm I/Tab | Túi thật qua InventoryPanel/UiCoordinator | Có; không còn dùng B để build |
| J | open_journal | Sổ nhiệm vụ thật | Có |
| K | Không có action/binding calendar | Calendar tab bị disabled | Chưa có |
| M | open_map=M | Không tìm handler open_map trong scripts/ui runtime | Mới khai báo phím, chưa có màn bản đồ |
| H | open_help=H | Mở TutorialPanel/help | Có; HUD dùng H thay vị trí calendar/map còn thiếu |
| Esc | cancel và pause | Đóng modal trên cùng hoặc pause theo coordinator | Có, có test native/modal |
| 1–8 | hotbar_1…hotbar_8 | 4công cụ +4 stack trên trang hiện tại | Có; khác ghi chú3 tool/5item cũ |
| 9 | hotbar_9 | Chọn legacy inventory index8 | Có, D72-C3 giữ danh tính vật phẩm |
| E | interact; inventory_tab_next | Tương tác gần Player; trong tab shell chuyển tab | Có, context/source/coop/modal có test |
| Q/E | inventory_tab_prev/next | Túi–Nhân vật–Nhiệm vụ;2 tab còn lại disabled | Có cho3 tab đã hỗ trợ |
| F | inventory_quick_select | Chọn stack thật lên thanh công cụ | Có; ngữ nghĩa hiện tại là quick-select lên thanh công cụ theo D40 |
| Z | inventory_sort | Sắp xếp túi thật | Có |
| T | Không có pin action/binding | Nút Ghim unavailable | Chưa có |
| Ctrl+M | toggle_debug_menu, ctrl_pressed=true, key M | Main mở shop máy trong debug; modal coordinator cũng chuyển sang shop | Chưa đạt exact/debug-only hoàn chỉnh như target |
| WASD/arrows/Shift | move_* / sprint | Player vẫn di chuyển/chạy thật | Còn nguyên; trái target gỡ Player mới |
| R/Q | rotate_cw / rotate_ccw | Xoay preview máy | Có theo InputMap hiện tại; Q được GUI ưu tiên khi đổi tab |
| Wheel/RMB/MMB | Không phải event InputMap cố định; xử lý native mouse | Wheel map zoom; Shift/hover toolbar cycle; RMB/MMB drag; double-right reset | Có, test_d72_camera_input.gd; không có touch/pinch |
| = / - | camera_zoom_in/out | Zoom5mức Resource | Có; tài liệu Numpad +/- chưa khớp binding thực tế |

`open_build`, `tool_next`, `tool_prev` tồn tại nhưng event list rỗng. Wheel hoạt động nhờ adapter native, nên event list rỗng không chứng minh wheel hỏng. `toggle_debug` có binding legacy mã4194329 nhưng không tìm consumer của action này trong mã game; không coi đó là lối mở DebugMenu cũ đã được xác nhận.

**Ctrl+M và exact_match:** tại `scripts/view/main.gd:93`, `scripts/view/debug_menu.gd:29`, `scripts/view/ui_coordinator.gd:223` gọi `event.is_action_pressed("toggle_debug_menu")` mà không truyền `exact_match=true`. `project.godot` có Ctrl+M và M riêng nhưng đây chưa phải bằng chứng exact routing. Test `test_player_restoration.gd` chứng minh plainM không mở shop và Ctrl+M mở shop; chưa kiểm Ctrl+M đối với action open_map hoặc modifier phụ. Vì M hiện không có màn/handler, chưa quan sát được trường hợp hai màn mở cùng lúc; báo cáo **không khẳng định lỗi kép đó đã tái hiện**.

Main có `OS.is_debug_build()`; nhánh thay modal trong UiCoordinator không có guard đó. Chưa có export/release test để chứng minh đường Ctrl+M hoàn toàn bị chặn trong release. Shop bằng E là luồng gameplay được D62/6.5c giữ, khác đường phím debug. Tài liệu/API dùng chữ “Exact Ctrl+M” hiện mạnh hơn bằng chứng mã/test.

## 8. Tham chiếu còn sót, placeholder, số liệu và ranh giới kiến trúc

### 8.1. Player/character/3D/viền ô

| Đối tượng cần tìm | Bằng chứng hiện tại | Đánh giá |
|---|---|---|
| Player active | scenes/world/gray_box_world.tscn instance scenes/player/player.tscn dưới WorldCanvas/Objects | Chưa gỡ; không phải file mồ côi |
| player_config | scripts/player/player_config.gd; data/player_2d_config.tres được scene và Player fallback preload | Vẫn có consumer thật |
| WASD/Shift | project.godot physical_keycode W/A/S/D, arrows, Shift; Player.gd:26–27 đọc move/sprint | Vẫn điều khiển nhân vật |
| Tạo nhân vật | ui/title/profile_form.tscn; LifeTitlePresenter submit; tests/unit/test_profile_creation.gd | Vẫn có luồng New Game dùng form |
| CharacterScreen | ui/character/character_flow.gd:11 đặt tên panel; Main.character_flow | Vẫn có modal thật; test_player_restoration yêu cầu giữ |
| Camera phụ thuộc Player | CameraRig.set_target(Player), _target.camera; clamp center + pan; movement_enabled gate | Kéo/zoom có, chưa manager độc lập |
| Node3D trong gameplay | test_isometric_migration kiểm cây Main active là2D và pass | Không tìm active gameplay3D |
| Nguồn3D còn trong repo | ChibiAvatar, CharacterFace, EmotionBubble, WorldArtFactory, WorldSeasonFx;99scene generated và review tools | Di sản có chủ ý;25match3D trong census source, không tự xóa |
| Đường viền ô cũ | GrayBoxWorld dùng atlas; test_ground_uses_imported_atlas_variants_without_grid_lines pass | Không tìm overlay vẽ lưới cũ đang active |
| Line2D/diamond còn lại | SoilFurrow_*, Highlight, machine preview; line/polyline nhà/tóc/mưa | Là luống đất, điểm chọn/preview và nét vẽ đồ vật; không quy mọi draw_line thành lưới cũ |

`ground_line_color` còn trong Resource/config là trường lịch sử; không tìm nơi dùng nó để vẽ lưới active. Độ khít texture ở mọi zoom không được chứng minh chỉ bằng test chọn ô; ảnh zoom xa có đường ranh texture/soil rõ, cần người dùng duyệt bằng mắt nếu yêu cầu “không lộ đường nối” tuyệt đối.

### 8.2. Chuỗi tiếng Việt hardcode và số liệu giả

Quét literal có ký tự tiếng Việt trong `scripts/**/*.gd`, `ui/**/*.gd` (bỏ comment), kiểm lại các match: không tìm thấy câu tiếng Việt có dấu hardcode bên ngoài cơ chế dịch. Hai match rộng Unicode còn lại chỉ là ký hiệu `×`, không phải câu tiếng Việt.

Có **2default text literal trong scene** `scenes/main/main.tscn`: dòng71 `D1  06:00`, dòng89 `100 Xu`. Chúng là giá trị ban đầu/legacy Label được presenter cập nhật từ state; không dùng làm bằng chứng tiền/giờ đang là số giả. Dù vậy chúng chưa tuân thủ tuyệt đối yêu cầu không hardcode text trong scene. Quét accent cũng không chứng minh mọi literal tiếng Anh/định dạng đều đã qua tr(); chưa có lint AST localization đầy đủ.

Các màn đang hoạt động đọc chủ sở hữu thật: title lấy save; HUD lấy clock/wallet/inventory/onboarding; bản tin lấy WeatherState/FarmGridState/ItemData; profile lấy profile/NpcSocialState; quest lấy QuestManager/current possession/reward Resource; máy lấy placement/job/buffer; tổng kết lấy DayLedger. Test/capture dùng fixture để dựng trạng thái không có nghĩa production hiển thị số giả.

Không tìm màn active dựng XP, stamina, birthday/event, kỹ năng hoặc biến động giá bằng số giả. Những phần này bị ẩn/disabled/ghi chưa khả dụng. Gallery dùng số minh họa và có dòng chú thích rõ “Mẫu thành phần — số liệu minh họa, không phải dữ liệu trò chơi”. Các hàng kỹ năng ở Character chỉ là khung unavailable; Calendar/Map không có màn rỗng hoạt động, chỉ tab disabled.

### 8.3. Số gameplay còn hardcode — phát hiện có bằng chứng

| Nơi | Giá trị/chính sách trong script | Tác động |
|---|---|---|
| scripts/view/main.gd:135,160,405 | WalletState.new(100), starterseed10 | Tiền/đồ khởi đầu chưa nằm trong Resource khởi tạo |
| scripts/domain/economy/wallet_state.gd:16,18 | 100 xu mặc định; reason có default rỗng ở add/remove | Chưa đạt single EconomyService/reason bắt buộc |
| scripts/core/game_clock.gd:19,30 | DEFAULT_DAY_REAL_SECONDS=720.0 làm mặc định autoload | Thời lượng ngày vẫn định ở script, không Resource riêng như luật dữ liệu yêu cầu |
| scripts/core/data_registry.gd:142–152 | max_stack99, giá bán planting=max(1,buy/2) | Stack/rate/giá tối thiểu là chính sách cân bằng trong Registry |
| scripts/domain/farm_grid_state.gd:141 | withered_days>=2 | Ngưỡng chết2 ngày vẫn là literal domain dù đã được người dùng duyệt; chưa data-owned |
| ui/machine/machine_controller.gd:91,102 và machine_snapshot.gd | Truyền cấp nhà1, so khóa>1 | Chưa có owner tiến trình cấp nhà; máy cấp2/3 không mở qua gameplay |

Đây là danh sách phát hiện chắc chắn từ source, không tuyên bố phân loại ngữ nghĩa mọi literal số trong tất cả script. Các giá đất500, chuồng700, thức ăn20, trứng30, nâng túi300, nâng bình200, weatherweights và cap công thức hiện có Resource thật. Không nhầm giới hạn JSON/int64, chỉ số mảng, số phút trong một ngày, kích thước UI, tần số animation cosmetic hay debug grant500 với giá cân bằng production.

### 8.4. Nợ kiến trúc

- Có phân chia DATA/RefCounted/VIEW và codec state rõ ở các hệ mới. Tuy nhiên FarmGridState/InventoryState/quest/service cũ còn gọi DataRegistry/GameClock/Events autoload trực tiếp; domain không hoàn toàn độc lập SceneTree/autoload theo mục tiêu “pure”. Chạy headless vẫn là chạy engine có autoload, không chứng minh pure library không Node.
- PROJECT_RULES giới hạn6 autoload. project.godot có7: `_mcp_game_helper`, Events, Settings, DataRegistry, SaveService, GameClock, Localization; Net chưa có. Helper là plugin dev, nhưng chưa có ngoại lệ được diễn đạt trong bảng luật. Không tự xóa helper hay đổi autoload order.
- Không có WorldState/ClockState tổng hợp độc lập; Main giữ nhiều owner và adapter. ARCH bảng composition ghi target nên không gọi toàn bộ bảng là DOC_ONLY.
-8 script vượt mục tiêu250dòng: DataValidator569, SaveService288, Main600, NpcSystem278, SeedShop359, ShippingBin293, ToolActionController298, ChibiAvatar390 (archive). Không refactor ngoài scope audit.
- Có serialize/deserialize trên các owner state mới; transient flow/service/stateless/derived occupancy không phải cứ có biến thành viên là bắt buộc thêm save. Không thấy crop/machine tăng trưởng bằng delta; delta của machine/avatar là animation, không tạo tiến trình hay sản lượng.

## 9. Việc còn lại theo thứ tự đề xuất

Bảng sau là đề xuất công việc sau kiểm toán, **không phải đã được triển khai hoặc tự cho phép sửa code/commit**. Mỗi phạm vi mới cần ALLOW_LIST/acceptance theo quy trình dự án.

| Ưu tiên | Công việc | Cần quyết định/đầu vào trước? | Câu hỏi cụ thể / tiêu chí hoàn tất |
|---|---|---|---|
| 1 | Đồng bộ target mới và hợp đồng migration manager | Có, phần chi tiết migration/stamina | Target bỏ Player/creation/Character đã được yêu cầu rõ trong audit. Sau khi bỏ form, New Game lấy tên nông trại từ đâu; có giữ profile tên cũ khi load không? Giữ payload player cũ để round-trip hay bỏ khi save mới? |
| 1 | Đặc tả stamina thật để thực hiện yêu cầu “giữ” | Có | Sức chứa mặc định, chi phí từng hành động, cách hồi qua ngủ/ăn, ảnh hưởng khi hết và trường save là gì? Không có hệ stamina cũ để chỉ giữ nguyên. |
| 2 | Sửa khớp4 stage và hình lâu năm sau thu | Luật stage3 đã có; không cần hỏi lại có muốn stage3 hay không | Cùng một quy tắc stage từ data; test boundary và sau thu cho coffee/pepper/orange/apple/banana; giữ save/care/regrow hiện có. Chốt riêng có áp dụng cùng visual rule cho tomato thu nhiều lần không. |
| 2 | Khóa exact/debug routing Ctrl+M và kiểm release | Không cần đổi target đã rõ | Exact modifiers tại tất cả route, không kích actionM, release không mở đường phím debug; test native có/không modal, modifier phụ và release/export khi có. |
| 2 | Sửa UI shop máy bị header ép nội dung | Không cần thay gameplay/giá | So ảnh10 ở1152/1280/1920 vi/en; header/footer vừa nội dung, vùng danh sách/chi tiết có chiều cao hữu ích; bổ sung assertion bắt đúng lỗi nhìn thấy. |
| 3 | Review/tách các phạm vi pending đã hoàn tất | Cần lệnh commit mới khi muốn commit | Giữ backup/manifest1.410 path, cô lập đồ họa/data/máy/land/water/coop/weather, chứng minh không mang file ngoài scope vào commit. Hiện audit cấm commit nên không thực hiện. |
| 4 | Hoàn thiện nền/Path/Decor/objects/Label_Plate và art còn thiếu | Cần chọn dùng art hiện có hay cung cấp bộ mới cho phần thiếu | Bind đúng runtime, kiểm đường nối/pivot/y-sort/scale; sourcebundle/UID phải có chính sách rõ.5PNGdraft chỉ dùng khi thực sự được tích hợp và giữ customization. |
| 4 | Icon produce/UI và khung cuối | Có đầu vào art nếu muốn bỏ placeholder | Dùng PNG gốc do người dùng cung cấp hay duyệt tạo bộ mới? Cần đủ16produceicon, bộicon mockup/khung9-slice; không tự coi filedraft là art cuối. |
| 5 | Hoàn thiện kinh tế/nhà để7 máy có tiến trình chơi được | Có | Chốt3 cấp nhà, giá/vật liệu/mở khóa/perk; giá mua/bán7thành phẩm và chuỗi flour→bread; giữ capvalidator và chạy multi-strategy sim. |
| 5 | Phân bón và upgrade tier sau | Có | Phân bón giá15 có giảm1 ngày hay cơ chế khác, dùng lúc nào? Bình40→80 giá nào trong600/1800, tier/túi tiếp theo ra sao? |
| 6 | Chốt UI thực sự giữ sau manager rồi hoàn thiện mockup | Có cho nội dung mới, không hỏi lại mục tiêu bỏ02/07 | Màn09calendar/events,11house,12dialogue,shop10 đầy đủ; bổ sung K/M/T khi có owner thật. Không cần mở lại02/07 nếu target mới đã loại chúng. |
| 7 | Phase7.2 phần thiếu: âm thanh/môi trường | Cần nguồn/định hướng audio và scope riêng | Giữ daynight/rain hiện có; thêm bus/music/ambient theo vùng/giờ/weather, không thay simulation. |
| 8 | 7.3–7.6/8.5–8.6: ecology/director/dog/story | Theo dữ liệu thiết kế và GateA | Làm từng milestone, giữ one-day path, codec/golden/telegraph-counter; không gọi cosmetic thành ecology. |
| 9 | M0 automation còn thiếu, balance/soak/perf/export và GateA/B | Cần người dùng chơi thử/cung cấp phần cứng/art rights | Có số đo thật, build cleanPC và biên bản3–5người. Phase10 chỉ sau GateB; không làm social trước. |

**Milestone tiếp theo nên làm:** một phạm vi ổn định hóa presentation/target hiện tại, ưu tiên4 stage/perennial, Ctrl+M và shop layout; song song chỉ lập đặc tả manager/stamina/migration để duyệt. Chưa nên tự chuyển sang Phase7.2 hoặc hệ sinh thái chỉ vì roadmap vừa giao xong7.1b: các thiếu sót đã xác định trong phạm vi cũ và hướng sản phẩm phải được giải quyết trước. Nếu người dùng chọn tiếp roadmap tuần tự sau khi đã chấp nhận các khoản hoãn,7.2 chỉ còn phần ambience/audio đáng kể vì daynight/rain đã có.

## 10. Rủi ro và giới hạn kiểm toán

1. **Khối pending lớn:**1.410 file trải nhiều mốc, chưa có ranh giới commit cho các hệ mới. Rủi ro mất lịch sử/phạm vi, không phải bằng chứng dữ liệu đã mất. Không xóa/reset/restore bất kỳ file nào trong audit.
2. **Tài liệu nhiều tầng thời gian:** ID trùng, saveversion cũ và checkbox được giữ làm lịch sử; có chỗ thiếu đánh dấu target/current rõ. Phải đọc mốc mới nhất và code thật. Không sửa toàn bộ tài liệu trong ngoại lệ audit1 file.
3. **Test pass chưa phủ đủ mục tiêu sản phẩm:**583 case gồm cả art3D archive. Chưa có test perennialstage3/chia quý stage, releaseCtrl+M, touch/pinch, toàn15UIđầyđủ,5000 ngày toàn world, sim nhiều chiến lược hoặc build sạch. Không báo các yêu cầu chưa test là đã pass.
4. **Bằng chứng ảnh/harness:** ảnh shop hiện chỉ ra lỗi diện tích hữu ích mà assertion encloses/scroll vẫn pass. Ảnh dialogue từ full launcher bị GUT panel che bên phải; không dùng phần bị che để kết luận giống mockup. Các ảnh trong TEMP có mtime thật của lượt audit18/11/2026, khoảng00:14–00:18; không dùng ảnh cũ làm ảnh mới. Không pixel-diff hoặc chấm điểm giống ảnh tự động.
5. **Timing/concurrency:** C2 đã tránh monolithic timeout trong lượt này, mỗi nhóm còn180s. Helper dùng chung `%TEMP%/the_life_test_appdata` và prefixlog cố định;2launcher chạy đồng thời có thể tranh save/log/GPU. Không chạy song song. Hôm nay không có F5 nhưng Editor còn mở; kết quả không là benchmark máy yếu.
6. **Pin engine:** binary thực tế/version đã được xác minh đúng. Launcher cho `%GODOT%` override và check_parse không assert chuỗi version bằng giá trị khóa, nên đây chưa là cơ chế chặn mọi engine sai phiên bản. Không thay runner trong audit.
7. **Asset source/UID/placeholder:**422PNGsource duplicate;380UIDimport duplicate;16candidate art chưa có consumer. CREDITS thiếu thông tin pack supplied. Đây là nợ cần scope/đầu vào riêng; không phải lỗi import đã xuất hiện trong log audit.
8. **Kiến trúc/data policy:** missing service authority/Log, numbers hardcode và Main600dòng có rủi ro tiếp tục tích hợp. Chưa làm lint AST/static analyzer đầy đủ; không tuyên bố source không còn vấn đề khác. Get-Command không tìm gdlint/gdformat trên PATH, không xác định được có bản cài ở chỗ khác hay không; không cài package.
9. **Save/rollback:** codec/golden1–12 có pass; backup3 file có, tự khôi phục backup chưa có. Chưa test mất điện/rename fail/ổ đĩa đầy trên máy người dùng. Không lấy các giới hạn chưa thử này làm lý do sửa file hoặc kết luận có lỗi mất save đã xảy ra.
10. **Giới hạn bằng chứng ngoài repo:** không xác định được các playtest/export/store/legal approval đã làm ở nơi khác; cần link/artifact/biên bản. Runner cô lập APPDATA khỏi save thật; audit không lập baseline SHA riêng cho20save thật như một số bàn giao cũ, nên không mượn tuyên bố20save-hash từ Phase7.1b làm đo đạc mới.

## 11. Kết luận và xác nhận phạm vi chỉ đọc

**42/200 mục DONE (21,0%)** theo định nghĩa phải có commit; **38 mục DONE_UNCOMMITTED**,70 PARTIAL,38 NOT_STARTED,3 DOC_ONLY,9 BLOCKED. Toàn bộ launcher/parse/data/Main hiện pass,583/583GUT. Game đã có nền2D và nhiều hệ chơi thật, nhưng mục tiêu manager mới, đủ15mockup, art/decor hoàn chỉnh, perennialvisual và phần lớn nội dung sinh thái/truyện/release chưa hoàn tất.

Không có bước editor/Inspector/Project Settings bắt buộc để “áp dụng” báo cáo; đây là tài liệu kiểm toán. Các checkbox F5/GateA/B vẫn cần người dùng ghi kết quả thật. Không commit trong nhiệm vụ này; không đưa commit đề xuất thành hành động được thực hiện.

Đã hash lại toàn bộ **4.541 đường dẫn tracked/untracked không bị ignore** so với baseline: **0 file có trước bị đổi**. Sau khi tạo báo cáo, sai khác duy nhất là **thêm `docs/AUDIT_REPORT.md`**; tổng danh mục4.542 path. File `the_life_prompt.md` vẫn deleted như ban đầu; toàn bộ pending cũ được giữ. HEAD không đổi `e7136608199a5d758433f7c599c8f89f31515cea`; SHA256 `.git/index` vẫn `b5afef352da0d76f085ded0c47067c537b566dd7f0fca05f2b7ccd2a651470f9`. Godot có thể cập nhật cache bị ignore trong `.godot/`; cache không được xem là code/scene/asset nguồn và không được đưa vào commit. Bằng chứng hash trước-sau ở TEMP `pre-report-read-only-proof.json` và `final-read-only-proof.json`.


## Phụ lục A — toàn bộ Git status tại baseline

Mã ` M` = thay đổi working tree chưa stage; ` D` = xóa chưa stage; `??` = chưa theo dõi. Đây là nguyên danh sách có trước kiểm toán, chưa gồm `docs/AUDIT_REPORT.md`. Tên file không phải sự cho phép sửa.

```text
 M data/isometric_world_config.tres
 M data/npcs/phase8_world.tres
 M data/weather_profile.tres
 M docs/API_INDEX.md
 M docs/ARCHITECTURE.md
 M docs/CREDITS.md
 M docs/DATA_SCHEMA.md
 M docs/DECISIONS.md
 M docs/INPUT_MAP.md
 M docs/PROGRESS.md
 M docs/ROADMAP.md
 M docs/SCENE_CONTRACTS/character_creation.md
 M docs/SCENE_CONTRACTS/day_end.md
 M docs/SCENE_CONTRACTS/gray_box_world.md
 M docs/SCENE_CONTRACTS/hud.md
 M docs/SCENE_CONTRACTS/inventory.md
 M docs/SCENE_CONTRACTS/morning_bulletin.md
 M docs/SCENE_CONTRACTS/player.md
 M localization/strings_en.csv
 M localization/strings_vi.csv
 M project.godot
 M scripts/core/data_registry.gd
 M scripts/core/data_validator.gd
 M scripts/core/save_service.gd
 M scripts/data/crop_data.gd
 M scripts/data/isometric_world_config.gd
 M scripts/data/weather_profile.gd
 M scripts/data/world_locations.gd
 M scripts/domain/day_simulator.gd
 M scripts/domain/economy/crop_economy_rules.gd
 M scripts/domain/economy/day_ledger_state.gd
 M scripts/domain/farm_grid_state.gd
 M scripts/domain/farm_save_codec.gd
 M scripts/domain/inventory_state.gd
 M scripts/domain/quests/det_random.gd
 M scripts/domain/quests/npc_schedule.gd
 M scripts/domain/quests/npc_social_state.gd
 M scripts/domain/tool_action.gd
 M scripts/domain/weather_state.gd
 M scripts/view/avatar_hair_2d.gd
 M scripts/view/camera_rig.gd
 M scripts/view/debug_menu.gd
 M scripts/view/farm_view.gd
 M scripts/view/gray_box_world.gd
 M scripts/view/hotbar_panel.gd
 M scripts/view/main.gd
 M scripts/view/npc_system.gd
 M scripts/view/placeholder_avatar_2d.gd
 M scripts/view/placeholder_world_2d.gd
 M scripts/view/tool_action_controller.gd
 M scripts/view/tool_drag_stroke.gd
 M scripts/view/tutorial_panel.gd
 M scripts/view/ui_coordinator.gd
 M scripts/view/ui_icons.gd
 M scripts/view/ui_layout.gd
 M scripts/view/world_presentation.gd
 M tests/unit/test_character_screen.gd
 M tests/unit/test_crop_care.gd
 M tests/unit/test_crop_care_save.gd
 M tests/unit/test_crop_care_ui.gd
 M tests/unit/test_crop_economy_data.gd
 M tests/unit/test_crop_inspector.gd
 M tests/unit/test_crop_regrow.gd
 M tests/unit/test_crop_regrow_save.gd
 M tests/unit/test_day_end_flow.gd
 M tests/unit/test_day_end_save.gd
 M tests/unit/test_day_simulator.gd
 M tests/unit/test_farm_view.gd
 M tests/unit/test_full_year_economy_simulation.gd
 M tests/unit/test_inventory_actions.gd
 M tests/unit/test_inventory_screen.gd
 M tests/unit/test_isometric_hud.gd
 M tests/unit/test_morning_flow.gd
 M tests/unit/test_npc_social_save.gd
 M tests/unit/test_pause_settings.gd
 M tests/unit/test_profile_creation.gd
 M tests/unit/test_quest_book.gd
 M tests/unit/test_save_service.gd
 M tests/unit/test_title_flow.gd
 M tests/unit/test_tutorial_quest_and_debug.gd
 M tests/unit/test_ui_layout.gd
 M tests/unit/test_ui_mouse.gd
 M tests/unit/test_weather.gd
 M tests/unit/test_world_presentation.gd
 D the_life_prompt.md
 M tools/run_tests.bat
 M tools/validate_data.gd
 M ui/components/panel_wood.gd
 M ui/day_end/day_end_flow.gd
 M ui/day_end/day_end_presenter.gd
 M ui/hud/hud_frame.gd
 M ui/hud/hud_presenter.gd
 M ui/hud/toast_stack.gd
 M ui/hud/toolbar.gd
 M ui/inventory/capacity_footer.gd
 M ui/inventory/inventory_controller.gd
?? assets/buildings/cottage_2x.png
?? assets/buildings/cottage_2x.png.import
?? assets/buildings/market_2x.png
?? assets/buildings/market_2x.png.import
?? assets/buildings/shipping_bin_2x.png
?? assets/buildings/shipping_bin_2x.png.import
?? assets/characters/farmer_sheet_2x.png
?? assets/characters/farmer_sheet_2x.png.import
?? assets/icons/ui_shovel.svg
?? assets/icons/ui_shovel.svg.import
?? assets/machines/barrel/1x/barrel_idle.png
?? assets/machines/barrel/1x/barrel_idle.png.import
?? assets/machines/barrel/1x/barrel_work_a.png
?? assets/machines/barrel/1x/barrel_work_a.png.import
?? assets/machines/barrel/1x/barrel_work_b.png
?? assets/machines/barrel/1x/barrel_work_b.png.import
?? assets/machines/barrel/barrel_idle.png
?? assets/machines/barrel/barrel_idle.png.import
?? assets/machines/barrel/barrel_work_a.png
?? assets/machines/barrel/barrel_work_a.png.import
?? assets/machines/barrel/barrel_work_b.png
?? assets/machines/barrel/barrel_work_b.png.import
?? assets/machines/dryer/1x/dryer_idle.png
?? assets/machines/dryer/1x/dryer_idle.png.import
?? assets/machines/dryer/1x/dryer_work_a.png
?? assets/machines/dryer/1x/dryer_work_a.png.import
?? assets/machines/dryer/1x/dryer_work_b.png
?? assets/machines/dryer/1x/dryer_work_b.png.import
?? assets/machines/dryer/dryer_idle.png
?? assets/machines/dryer/dryer_idle.png.import
?? assets/machines/dryer/dryer_work_a.png
?? assets/machines/dryer/dryer_work_a.png.import
?? assets/machines/dryer/dryer_work_b.png
?? assets/machines/dryer/dryer_work_b.png.import
?? assets/machines/machines_manifest.json
?? assets/machines/mill/1x/mill_idle.png
?? assets/machines/mill/1x/mill_idle.png.import
?? assets/machines/mill/1x/mill_work_a.png
?? assets/machines/mill/1x/mill_work_a.png.import
?? assets/machines/mill/1x/mill_work_b.png
?? assets/machines/mill/1x/mill_work_b.png.import
?? assets/machines/mill/mill_idle.png
?? assets/machines/mill/mill_idle.png.import
?? assets/machines/mill/mill_work_a.png
?? assets/machines/mill/mill_work_a.png.import
?? assets/machines/mill/mill_work_b.png
?? assets/machines/mill/mill_work_b.png.import
?? assets/machines/oven/1x/oven_idle.png
?? assets/machines/oven/1x/oven_idle.png.import
?? assets/machines/oven/1x/oven_work_a.png
?? assets/machines/oven/1x/oven_work_a.png.import
?? assets/machines/oven/1x/oven_work_b.png
?? assets/machines/oven/1x/oven_work_b.png.import
?? assets/machines/oven/oven_idle.png
?? assets/machines/oven/oven_idle.png.import
?? assets/machines/oven/oven_work_a.png
?? assets/machines/oven/oven_work_a.png.import
?? assets/machines/oven/oven_work_b.png
?? assets/machines/oven/oven_work_b.png.import
?? assets/machines/press/1x/press_idle.png
?? assets/machines/press/1x/press_idle.png.import
?? assets/machines/press/1x/press_work_a.png
?? assets/machines/press/1x/press_work_a.png.import
?? assets/machines/press/1x/press_work_b.png
?? assets/machines/press/1x/press_work_b.png.import
?? assets/machines/press/press_idle.png
?? assets/machines/press/press_idle.png.import
?? assets/machines/press/press_work_a.png
?? assets/machines/press/press_work_a.png.import
?? assets/machines/press/press_work_b.png
?? assets/machines/press/press_work_b.png.import
?? assets/machines/roaster/1x/roaster_idle.png
?? assets/machines/roaster/1x/roaster_idle.png.import
?? assets/machines/roaster/1x/roaster_work_a.png
?? assets/machines/roaster/1x/roaster_work_a.png.import
?? assets/machines/roaster/1x/roaster_work_b.png
?? assets/machines/roaster/1x/roaster_work_b.png.import
?? assets/machines/roaster/roaster_idle.png
?? assets/machines/roaster/roaster_idle.png.import
?? assets/machines/roaster/roaster_work_a.png
?? assets/machines/roaster/roaster_work_a.png.import
?? assets/machines/roaster/roaster_work_b.png
?? assets/machines/roaster/roaster_work_b.png.import
?? assets/machines/stove/1x/stove_idle.png
?? assets/machines/stove/1x/stove_idle.png.import
?? assets/machines/stove/1x/stove_work_a.png
?? assets/machines/stove/1x/stove_work_a.png.import
?? assets/machines/stove/1x/stove_work_b.png
?? assets/machines/stove/1x/stove_work_b.png.import
?? assets/machines/stove/stove_idle.png
?? assets/machines/stove/stove_idle.png.import
?? assets/machines/stove/stove_work_a.png
?? assets/machines/stove/stove_work_a.png.import
?? assets/machines/stove/stove_work_b.png
?? assets/machines/stove/stove_work_b.png.import
?? assets/the_life_assets/crops/apple/1x/apple_seed.png
?? assets/the_life_assets/crops/apple/1x/apple_seed.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage1.png
?? assets/the_life_assets/crops/apple/1x/apple_stage1.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage1_wilted.png
?? assets/the_life_assets/crops/apple/1x/apple_stage1_wilted.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage2.png
?? assets/the_life_assets/crops/apple/1x/apple_stage2.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage2_wilted.png
?? assets/the_life_assets/crops/apple/1x/apple_stage2_wilted.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage3.png
?? assets/the_life_assets/crops/apple/1x/apple_stage3.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage3_wilted.png
?? assets/the_life_assets/crops/apple/1x/apple_stage3_wilted.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage4.png
?? assets/the_life_assets/crops/apple/1x/apple_stage4.png.import
?? assets/the_life_assets/crops/apple/1x/apple_stage4_wilted.png
?? assets/the_life_assets/crops/apple/1x/apple_stage4_wilted.png.import
?? assets/the_life_assets/crops/apple/apple_seed.png
?? assets/the_life_assets/crops/apple/apple_seed.png.import
?? assets/the_life_assets/crops/apple/apple_stage1.png
?? assets/the_life_assets/crops/apple/apple_stage1.png.import
?? assets/the_life_assets/crops/apple/apple_stage1_wilted.png
?? assets/the_life_assets/crops/apple/apple_stage1_wilted.png.import
?? assets/the_life_assets/crops/apple/apple_stage2.png
?? assets/the_life_assets/crops/apple/apple_stage2.png.import
?? assets/the_life_assets/crops/apple/apple_stage2_wilted.png
?? assets/the_life_assets/crops/apple/apple_stage2_wilted.png.import
?? assets/the_life_assets/crops/apple/apple_stage3.png
?? assets/the_life_assets/crops/apple/apple_stage3.png.import
?? assets/the_life_assets/crops/apple/apple_stage3_wilted.png
?? assets/the_life_assets/crops/apple/apple_stage3_wilted.png.import
?? assets/the_life_assets/crops/apple/apple_stage4.png
?? assets/the_life_assets/crops/apple/apple_stage4.png.import
?? assets/the_life_assets/crops/apple/apple_stage4_wilted.png
?? assets/the_life_assets/crops/apple/apple_stage4_wilted.png.import
?? assets/the_life_assets/crops/banana/1x/banana_seed.png
?? assets/the_life_assets/crops/banana/1x/banana_seed.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage1.png
?? assets/the_life_assets/crops/banana/1x/banana_stage1.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage1_wilted.png
?? assets/the_life_assets/crops/banana/1x/banana_stage1_wilted.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage2.png
?? assets/the_life_assets/crops/banana/1x/banana_stage2.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage2_wilted.png
?? assets/the_life_assets/crops/banana/1x/banana_stage2_wilted.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage3.png
?? assets/the_life_assets/crops/banana/1x/banana_stage3.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage3_wilted.png
?? assets/the_life_assets/crops/banana/1x/banana_stage3_wilted.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage4.png
?? assets/the_life_assets/crops/banana/1x/banana_stage4.png.import
?? assets/the_life_assets/crops/banana/1x/banana_stage4_wilted.png
?? assets/the_life_assets/crops/banana/1x/banana_stage4_wilted.png.import
?? assets/the_life_assets/crops/banana/banana_seed.png
?? assets/the_life_assets/crops/banana/banana_seed.png.import
?? assets/the_life_assets/crops/banana/banana_stage1.png
?? assets/the_life_assets/crops/banana/banana_stage1.png.import
?? assets/the_life_assets/crops/banana/banana_stage1_wilted.png
?? assets/the_life_assets/crops/banana/banana_stage1_wilted.png.import
?? assets/the_life_assets/crops/banana/banana_stage2.png
?? assets/the_life_assets/crops/banana/banana_stage2.png.import
?? assets/the_life_assets/crops/banana/banana_stage2_wilted.png
?? assets/the_life_assets/crops/banana/banana_stage2_wilted.png.import
?? assets/the_life_assets/crops/banana/banana_stage3.png
?? assets/the_life_assets/crops/banana/banana_stage3.png.import
?? assets/the_life_assets/crops/banana/banana_stage3_wilted.png
?? assets/the_life_assets/crops/banana/banana_stage3_wilted.png.import
?? assets/the_life_assets/crops/banana/banana_stage4.png
?? assets/the_life_assets/crops/banana/banana_stage4.png.import
?? assets/the_life_assets/crops/banana/banana_stage4_wilted.png
?? assets/the_life_assets/crops/banana/banana_stage4_wilted.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_seed.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_seed.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage1.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage1.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage1_wilted.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage1_wilted.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage2.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage2.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage2_wilted.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage2_wilted.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage3.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage3.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage3_wilted.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage3_wilted.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage4.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage4.png.import
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage4_wilted.png
?? assets/the_life_assets/crops/cabbage/1x/cabbage_stage4_wilted.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_seed.png
?? assets/the_life_assets/crops/cabbage/cabbage_seed.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage1.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage1.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage1_wilted.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage1_wilted.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage2.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage2.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage2_wilted.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage2_wilted.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage3.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage3.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage3_wilted.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage3_wilted.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage4.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage4.png.import
?? assets/the_life_assets/crops/cabbage/cabbage_stage4_wilted.png
?? assets/the_life_assets/crops/cabbage/cabbage_stage4_wilted.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_seed.png
?? assets/the_life_assets/crops/carrot/1x/carrot_seed.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage1.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage1.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage1_wilted.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage1_wilted.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage2.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage2.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage2_wilted.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage2_wilted.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage3.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage3.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage3_wilted.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage3_wilted.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage4.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage4.png.import
?? assets/the_life_assets/crops/carrot/1x/carrot_stage4_wilted.png
?? assets/the_life_assets/crops/carrot/1x/carrot_stage4_wilted.png.import
?? assets/the_life_assets/crops/carrot/carrot_seed.png
?? assets/the_life_assets/crops/carrot/carrot_seed.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage1.png
?? assets/the_life_assets/crops/carrot/carrot_stage1.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage1_wilted.png
?? assets/the_life_assets/crops/carrot/carrot_stage1_wilted.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage2.png
?? assets/the_life_assets/crops/carrot/carrot_stage2.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage2_wilted.png
?? assets/the_life_assets/crops/carrot/carrot_stage2_wilted.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage3.png
?? assets/the_life_assets/crops/carrot/carrot_stage3.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage3_wilted.png
?? assets/the_life_assets/crops/carrot/carrot_stage3_wilted.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage4.png
?? assets/the_life_assets/crops/carrot/carrot_stage4.png.import
?? assets/the_life_assets/crops/carrot/carrot_stage4_wilted.png
?? assets/the_life_assets/crops/carrot/carrot_stage4_wilted.png.import
?? assets/the_life_assets/crops/chili/1x/chili_seed.png
?? assets/the_life_assets/crops/chili/1x/chili_seed.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage1.png
?? assets/the_life_assets/crops/chili/1x/chili_stage1.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage1_wilted.png
?? assets/the_life_assets/crops/chili/1x/chili_stage1_wilted.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage2.png
?? assets/the_life_assets/crops/chili/1x/chili_stage2.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage2_wilted.png
?? assets/the_life_assets/crops/chili/1x/chili_stage2_wilted.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage3.png
?? assets/the_life_assets/crops/chili/1x/chili_stage3.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage3_wilted.png
?? assets/the_life_assets/crops/chili/1x/chili_stage3_wilted.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage4.png
?? assets/the_life_assets/crops/chili/1x/chili_stage4.png.import
?? assets/the_life_assets/crops/chili/1x/chili_stage4_wilted.png
?? assets/the_life_assets/crops/chili/1x/chili_stage4_wilted.png.import
?? assets/the_life_assets/crops/chili/chili_seed.png
?? assets/the_life_assets/crops/chili/chili_seed.png.import
?? assets/the_life_assets/crops/chili/chili_stage1.png
?? assets/the_life_assets/crops/chili/chili_stage1.png.import
?? assets/the_life_assets/crops/chili/chili_stage1_wilted.png
?? assets/the_life_assets/crops/chili/chili_stage1_wilted.png.import
?? assets/the_life_assets/crops/chili/chili_stage2.png
?? assets/the_life_assets/crops/chili/chili_stage2.png.import
?? assets/the_life_assets/crops/chili/chili_stage2_wilted.png
?? assets/the_life_assets/crops/chili/chili_stage2_wilted.png.import
?? assets/the_life_assets/crops/chili/chili_stage3.png
?? assets/the_life_assets/crops/chili/chili_stage3.png.import
?? assets/the_life_assets/crops/chili/chili_stage3_wilted.png
?? assets/the_life_assets/crops/chili/chili_stage3_wilted.png.import
?? assets/the_life_assets/crops/chili/chili_stage4.png
?? assets/the_life_assets/crops/chili/chili_stage4.png.import
?? assets/the_life_assets/crops/chili/chili_stage4_wilted.png
?? assets/the_life_assets/crops/chili/chili_stage4_wilted.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_seed.png
?? assets/the_life_assets/crops/coffee/1x/coffee_seed.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage1.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage1.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage1_wilted.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage1_wilted.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage2.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage2.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage2_wilted.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage2_wilted.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage3.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage3.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage3_wilted.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage3_wilted.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage4.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage4.png.import
?? assets/the_life_assets/crops/coffee/1x/coffee_stage4_wilted.png
?? assets/the_life_assets/crops/coffee/1x/coffee_stage4_wilted.png.import
?? assets/the_life_assets/crops/coffee/coffee_seed.png
?? assets/the_life_assets/crops/coffee/coffee_seed.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage1.png
?? assets/the_life_assets/crops/coffee/coffee_stage1.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage1_wilted.png
?? assets/the_life_assets/crops/coffee/coffee_stage1_wilted.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage2.png
?? assets/the_life_assets/crops/coffee/coffee_stage2.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage2_wilted.png
?? assets/the_life_assets/crops/coffee/coffee_stage2_wilted.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage3.png
?? assets/the_life_assets/crops/coffee/coffee_stage3.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage3_wilted.png
?? assets/the_life_assets/crops/coffee/coffee_stage3_wilted.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage4.png
?? assets/the_life_assets/crops/coffee/coffee_stage4.png.import
?? assets/the_life_assets/crops/coffee/coffee_stage4_wilted.png
?? assets/the_life_assets/crops/coffee/coffee_stage4_wilted.png.import
?? assets/the_life_assets/crops/corn/1x/corn_seed.png
?? assets/the_life_assets/crops/corn/1x/corn_seed.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage1.png
?? assets/the_life_assets/crops/corn/1x/corn_stage1.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage1_wilted.png
?? assets/the_life_assets/crops/corn/1x/corn_stage1_wilted.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage2.png
?? assets/the_life_assets/crops/corn/1x/corn_stage2.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage2_wilted.png
?? assets/the_life_assets/crops/corn/1x/corn_stage2_wilted.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage3.png
?? assets/the_life_assets/crops/corn/1x/corn_stage3.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage3_wilted.png
?? assets/the_life_assets/crops/corn/1x/corn_stage3_wilted.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage4.png
?? assets/the_life_assets/crops/corn/1x/corn_stage4.png.import
?? assets/the_life_assets/crops/corn/1x/corn_stage4_wilted.png
?? assets/the_life_assets/crops/corn/1x/corn_stage4_wilted.png.import
?? assets/the_life_assets/crops/corn/corn_seed.png
?? assets/the_life_assets/crops/corn/corn_seed.png.import
?? assets/the_life_assets/crops/corn/corn_stage1.png
?? assets/the_life_assets/crops/corn/corn_stage1.png.import
?? assets/the_life_assets/crops/corn/corn_stage1_wilted.png
?? assets/the_life_assets/crops/corn/corn_stage1_wilted.png.import
?? assets/the_life_assets/crops/corn/corn_stage2.png
?? assets/the_life_assets/crops/corn/corn_stage2.png.import
?? assets/the_life_assets/crops/corn/corn_stage2_wilted.png
?? assets/the_life_assets/crops/corn/corn_stage2_wilted.png.import
?? assets/the_life_assets/crops/corn/corn_stage3.png
?? assets/the_life_assets/crops/corn/corn_stage3.png.import
?? assets/the_life_assets/crops/corn/corn_stage3_wilted.png
?? assets/the_life_assets/crops/corn/corn_stage3_wilted.png.import
?? assets/the_life_assets/crops/corn/corn_stage4.png
?? assets/the_life_assets/crops/corn/corn_stage4.png.import
?? assets/the_life_assets/crops/corn/corn_stage4_wilted.png
?? assets/the_life_assets/crops/corn/corn_stage4_wilted.png.import
?? assets/the_life_assets/crops/crops_manifest.json
?? assets/the_life_assets/crops/eggplant/1x/eggplant_seed.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_seed.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage1.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage1.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage1_wilted.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage1_wilted.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage2.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage2.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage2_wilted.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage2_wilted.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage3.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage3.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage3_wilted.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage3_wilted.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage4.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage4.png.import
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage4_wilted.png
?? assets/the_life_assets/crops/eggplant/1x/eggplant_stage4_wilted.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_seed.png
?? assets/the_life_assets/crops/eggplant/eggplant_seed.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage1.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage1.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage1_wilted.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage1_wilted.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage2.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage2.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage2_wilted.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage2_wilted.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage3.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage3.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage3_wilted.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage3_wilted.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage4.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage4.png.import
?? assets/the_life_assets/crops/eggplant/eggplant_stage4_wilted.png
?? assets/the_life_assets/crops/eggplant/eggplant_stage4_wilted.png.import
?? assets/the_life_assets/crops/orange/1x/orange_seed.png
?? assets/the_life_assets/crops/orange/1x/orange_seed.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage1.png
?? assets/the_life_assets/crops/orange/1x/orange_stage1.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage1_wilted.png
?? assets/the_life_assets/crops/orange/1x/orange_stage1_wilted.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage2.png
?? assets/the_life_assets/crops/orange/1x/orange_stage2.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage2_wilted.png
?? assets/the_life_assets/crops/orange/1x/orange_stage2_wilted.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage3.png
?? assets/the_life_assets/crops/orange/1x/orange_stage3.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage3_wilted.png
?? assets/the_life_assets/crops/orange/1x/orange_stage3_wilted.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage4.png
?? assets/the_life_assets/crops/orange/1x/orange_stage4.png.import
?? assets/the_life_assets/crops/orange/1x/orange_stage4_wilted.png
?? assets/the_life_assets/crops/orange/1x/orange_stage4_wilted.png.import
?? assets/the_life_assets/crops/orange/orange_seed.png
?? assets/the_life_assets/crops/orange/orange_seed.png.import
?? assets/the_life_assets/crops/orange/orange_stage1.png
?? assets/the_life_assets/crops/orange/orange_stage1.png.import
?? assets/the_life_assets/crops/orange/orange_stage1_wilted.png
?? assets/the_life_assets/crops/orange/orange_stage1_wilted.png.import
?? assets/the_life_assets/crops/orange/orange_stage2.png
?? assets/the_life_assets/crops/orange/orange_stage2.png.import
?? assets/the_life_assets/crops/orange/orange_stage2_wilted.png
?? assets/the_life_assets/crops/orange/orange_stage2_wilted.png.import
?? assets/the_life_assets/crops/orange/orange_stage3.png
?? assets/the_life_assets/crops/orange/orange_stage3.png.import
?? assets/the_life_assets/crops/orange/orange_stage3_wilted.png
?? assets/the_life_assets/crops/orange/orange_stage3_wilted.png.import
?? assets/the_life_assets/crops/orange/orange_stage4.png
?? assets/the_life_assets/crops/orange/orange_stage4.png.import
?? assets/the_life_assets/crops/orange/orange_stage4_wilted.png
?? assets/the_life_assets/crops/orange/orange_stage4_wilted.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_seed.png
?? assets/the_life_assets/crops/pepper/1x/pepper_seed.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage1.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage1.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage1_wilted.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage1_wilted.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage2.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage2.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage2_wilted.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage2_wilted.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage3.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage3.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage3_wilted.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage3_wilted.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage4.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage4.png.import
?? assets/the_life_assets/crops/pepper/1x/pepper_stage4_wilted.png
?? assets/the_life_assets/crops/pepper/1x/pepper_stage4_wilted.png.import
?? assets/the_life_assets/crops/pepper/pepper_seed.png
?? assets/the_life_assets/crops/pepper/pepper_seed.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage1.png
?? assets/the_life_assets/crops/pepper/pepper_stage1.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage1_wilted.png
?? assets/the_life_assets/crops/pepper/pepper_stage1_wilted.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage2.png
?? assets/the_life_assets/crops/pepper/pepper_stage2.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage2_wilted.png
?? assets/the_life_assets/crops/pepper/pepper_stage2_wilted.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage3.png
?? assets/the_life_assets/crops/pepper/pepper_stage3.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage3_wilted.png
?? assets/the_life_assets/crops/pepper/pepper_stage3_wilted.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage4.png
?? assets/the_life_assets/crops/pepper/pepper_stage4.png.import
?? assets/the_life_assets/crops/pepper/pepper_stage4_wilted.png
?? assets/the_life_assets/crops/pepper/pepper_stage4_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_seed.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_seed.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage1.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage1.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage1_wilted.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage1_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage2.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage2.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage2_wilted.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage2_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage3.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage3.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage3_wilted.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage3_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage4.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage4.png.import
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage4_wilted.png
?? assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage4_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_seed.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_seed.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage1.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage1.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage1_wilted.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage1_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage2.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage2.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage2_wilted.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage2_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage3.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage3.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage3_wilted.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage3_wilted.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage4.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage4.png.import
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage4_wilted.png
?? assets/the_life_assets/crops/pumpkin/pumpkin_stage4_wilted.png.import
?? assets/the_life_assets/crops/radish/1x/radish_seed.png
?? assets/the_life_assets/crops/radish/1x/radish_seed.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage1.png
?? assets/the_life_assets/crops/radish/1x/radish_stage1.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage1_wilted.png
?? assets/the_life_assets/crops/radish/1x/radish_stage1_wilted.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage2.png
?? assets/the_life_assets/crops/radish/1x/radish_stage2.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage2_wilted.png
?? assets/the_life_assets/crops/radish/1x/radish_stage2_wilted.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage3.png
?? assets/the_life_assets/crops/radish/1x/radish_stage3.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage3_wilted.png
?? assets/the_life_assets/crops/radish/1x/radish_stage3_wilted.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage4.png
?? assets/the_life_assets/crops/radish/1x/radish_stage4.png.import
?? assets/the_life_assets/crops/radish/1x/radish_stage4_wilted.png
?? assets/the_life_assets/crops/radish/1x/radish_stage4_wilted.png.import
?? assets/the_life_assets/crops/radish/radish_seed.png
?? assets/the_life_assets/crops/radish/radish_seed.png.import
?? assets/the_life_assets/crops/radish/radish_stage1.png
?? assets/the_life_assets/crops/radish/radish_stage1.png.import
?? assets/the_life_assets/crops/radish/radish_stage1_wilted.png
?? assets/the_life_assets/crops/radish/radish_stage1_wilted.png.import
?? assets/the_life_assets/crops/radish/radish_stage2.png
?? assets/the_life_assets/crops/radish/radish_stage2.png.import
?? assets/the_life_assets/crops/radish/radish_stage2_wilted.png
?? assets/the_life_assets/crops/radish/radish_stage2_wilted.png.import
?? assets/the_life_assets/crops/radish/radish_stage3.png
?? assets/the_life_assets/crops/radish/radish_stage3.png.import
?? assets/the_life_assets/crops/radish/radish_stage3_wilted.png
?? assets/the_life_assets/crops/radish/radish_stage3_wilted.png.import
?? assets/the_life_assets/crops/radish/radish_stage4.png
?? assets/the_life_assets/crops/radish/radish_stage4.png.import
?? assets/the_life_assets/crops/radish/radish_stage4_wilted.png
?? assets/the_life_assets/crops/radish/radish_stage4_wilted.png.import
?? assets/the_life_assets/crops/rice/1x/rice_seed.png
?? assets/the_life_assets/crops/rice/1x/rice_seed.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage1.png
?? assets/the_life_assets/crops/rice/1x/rice_stage1.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage1_wilted.png
?? assets/the_life_assets/crops/rice/1x/rice_stage1_wilted.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage2.png
?? assets/the_life_assets/crops/rice/1x/rice_stage2.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage2_wilted.png
?? assets/the_life_assets/crops/rice/1x/rice_stage2_wilted.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage3.png
?? assets/the_life_assets/crops/rice/1x/rice_stage3.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage3_wilted.png
?? assets/the_life_assets/crops/rice/1x/rice_stage3_wilted.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage4.png
?? assets/the_life_assets/crops/rice/1x/rice_stage4.png.import
?? assets/the_life_assets/crops/rice/1x/rice_stage4_wilted.png
?? assets/the_life_assets/crops/rice/1x/rice_stage4_wilted.png.import
?? assets/the_life_assets/crops/rice/rice_seed.png
?? assets/the_life_assets/crops/rice/rice_seed.png.import
?? assets/the_life_assets/crops/rice/rice_stage1.png
?? assets/the_life_assets/crops/rice/rice_stage1.png.import
?? assets/the_life_assets/crops/rice/rice_stage1_wilted.png
?? assets/the_life_assets/crops/rice/rice_stage1_wilted.png.import
?? assets/the_life_assets/crops/rice/rice_stage2.png
?? assets/the_life_assets/crops/rice/rice_stage2.png.import
?? assets/the_life_assets/crops/rice/rice_stage2_wilted.png
?? assets/the_life_assets/crops/rice/rice_stage2_wilted.png.import
?? assets/the_life_assets/crops/rice/rice_stage3.png
?? assets/the_life_assets/crops/rice/rice_stage3.png.import
?? assets/the_life_assets/crops/rice/rice_stage3_wilted.png
?? assets/the_life_assets/crops/rice/rice_stage3_wilted.png.import
?? assets/the_life_assets/crops/rice/rice_stage4.png
?? assets/the_life_assets/crops/rice/rice_stage4.png.import
?? assets/the_life_assets/crops/rice/rice_stage4_wilted.png
?? assets/the_life_assets/crops/rice/rice_stage4_wilted.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_seed.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_seed.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage1.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage1.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage1_wilted.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage1_wilted.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage2.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage2.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage2_wilted.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage2_wilted.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage3.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage3.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage3_wilted.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage3_wilted.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage4.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage4.png.import
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage4_wilted.png
?? assets/the_life_assets/crops/strawberry/1x/strawberry_stage4_wilted.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_seed.png
?? assets/the_life_assets/crops/strawberry/strawberry_seed.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage1.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage1.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage1_wilted.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage1_wilted.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage2.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage2.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage2_wilted.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage2_wilted.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage3.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage3.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage3_wilted.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage3_wilted.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage4.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage4.png.import
?? assets/the_life_assets/crops/strawberry/strawberry_stage4_wilted.png
?? assets/the_life_assets/crops/strawberry/strawberry_stage4_wilted.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_seed.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_seed.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage1.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage1.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage1_wilted.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage1_wilted.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage2.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage2.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage2_wilted.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage2_wilted.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage3.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage3.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage3_wilted.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage3_wilted.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage4.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage4.png.import
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage4_wilted.png
?? assets/the_life_assets/crops/sunflower/1x/sunflower_stage4_wilted.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_seed.png
?? assets/the_life_assets/crops/sunflower/sunflower_seed.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage1.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage1.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage1_wilted.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage1_wilted.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage2.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage2.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage2_wilted.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage2_wilted.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage3.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage3.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage3_wilted.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage3_wilted.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage4.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage4.png.import
?? assets/the_life_assets/crops/sunflower/sunflower_stage4_wilted.png
?? assets/the_life_assets/crops/sunflower/sunflower_stage4_wilted.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_seed.png
?? assets/the_life_assets/crops/tomato/1x/tomato_seed.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage1.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage1.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage1_wilted.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage1_wilted.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage2.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage2.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage2_wilted.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage2_wilted.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage3.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage3.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage3_wilted.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage3_wilted.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage4.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage4.png.import
?? assets/the_life_assets/crops/tomato/1x/tomato_stage4_wilted.png
?? assets/the_life_assets/crops/tomato/1x/tomato_stage4_wilted.png.import
?? assets/the_life_assets/crops/tomato/tomato_seed.png
?? assets/the_life_assets/crops/tomato/tomato_seed.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage1.png
?? assets/the_life_assets/crops/tomato/tomato_stage1.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage1_wilted.png
?? assets/the_life_assets/crops/tomato/tomato_stage1_wilted.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage2.png
?? assets/the_life_assets/crops/tomato/tomato_stage2.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage2_wilted.png
?? assets/the_life_assets/crops/tomato/tomato_stage2_wilted.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage3.png
?? assets/the_life_assets/crops/tomato/tomato_stage3.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage3_wilted.png
?? assets/the_life_assets/crops/tomato/tomato_stage3_wilted.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage4.png
?? assets/the_life_assets/crops/tomato/tomato_stage4.png.import
?? assets/the_life_assets/crops/tomato/tomato_stage4_wilted.png
?? assets/the_life_assets/crops/tomato/tomato_stage4_wilted.png.import
?? assets/the_life_assets/decor/flower_0.png
?? assets/the_life_assets/decor/flower_0.png.import
?? assets/the_life_assets/decor/flower_0_1x.png
?? assets/the_life_assets/decor/flower_0_1x.png.import
?? assets/the_life_assets/decor/flower_1.png
?? assets/the_life_assets/decor/flower_1.png.import
?? assets/the_life_assets/decor/flower_1_1x.png
?? assets/the_life_assets/decor/flower_1_1x.png.import
?? assets/the_life_assets/decor/flower_2.png
?? assets/the_life_assets/decor/flower_2.png.import
?? assets/the_life_assets/decor/flower_2_1x.png
?? assets/the_life_assets/decor/flower_2_1x.png.import
?? assets/the_life_assets/decor/flower_3.png
?? assets/the_life_assets/decor/flower_3.png.import
?? assets/the_life_assets/decor/flower_3_1x.png
?? assets/the_life_assets/decor/flower_3_1x.png.import
?? assets/the_life_assets/decor/pebble_0.png
?? assets/the_life_assets/decor/pebble_0.png.import
?? assets/the_life_assets/decor/pebble_0_1x.png
?? assets/the_life_assets/decor/pebble_0_1x.png.import
?? assets/the_life_assets/decor/pebble_1.png
?? assets/the_life_assets/decor/pebble_1.png.import
?? assets/the_life_assets/decor/pebble_1_1x.png
?? assets/the_life_assets/decor/pebble_1_1x.png.import
?? assets/the_life_assets/decor/tuft_0.png
?? assets/the_life_assets/decor/tuft_0.png.import
?? assets/the_life_assets/decor/tuft_0_1x.png
?? assets/the_life_assets/decor/tuft_0_1x.png.import
?? assets/the_life_assets/decor/tuft_1.png
?? assets/the_life_assets/decor/tuft_1.png.import
?? assets/the_life_assets/decor/tuft_1_1x.png
?? assets/the_life_assets/decor/tuft_1_1x.png.import
?? assets/the_life_assets/decor/tuft_2.png
?? assets/the_life_assets/decor/tuft_2.png.import
?? assets/the_life_assets/decor/tuft_2_1x.png
?? assets/the_life_assets/decor/tuft_2_1x.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_large_1.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_large_1.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_large_2.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_large_2.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_large_3.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_large_3.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_medium_1.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_medium_1.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_medium_2.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_medium_2.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_medium_3.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_medium_3.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_small_1.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_small_1.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_small_2.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_small_2.png.import
?? assets/the_life_assets/grass_clumps/1x/grass_clump_small_3.png
?? assets/the_life_assets/grass_clumps/1x/grass_clump_small_3.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_large_1.png
?? assets/the_life_assets/grass_clumps/grass_clump_large_1.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_large_2.png
?? assets/the_life_assets/grass_clumps/grass_clump_large_2.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_large_3.png
?? assets/the_life_assets/grass_clumps/grass_clump_large_3.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_medium_1.png
?? assets/the_life_assets/grass_clumps/grass_clump_medium_1.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_medium_2.png
?? assets/the_life_assets/grass_clumps/grass_clump_medium_2.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_medium_3.png
?? assets/the_life_assets/grass_clumps/grass_clump_medium_3.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_small_1.png
?? assets/the_life_assets/grass_clumps/grass_clump_small_1.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_small_2.png
?? assets/the_life_assets/grass_clumps/grass_clump_small_2.png.import
?? assets/the_life_assets/grass_clumps/grass_clump_small_3.png
?? assets/the_life_assets/grass_clumps/grass_clump_small_3.png.import
?? assets/the_life_assets/machines/barrel/1x/barrel_idle.png
?? assets/the_life_assets/machines/barrel/1x/barrel_idle.png.import
?? assets/the_life_assets/machines/barrel/1x/barrel_work_a.png
?? assets/the_life_assets/machines/barrel/1x/barrel_work_a.png.import
?? assets/the_life_assets/machines/barrel/1x/barrel_work_b.png
?? assets/the_life_assets/machines/barrel/1x/barrel_work_b.png.import
?? assets/the_life_assets/machines/barrel/barrel_idle.png
?? assets/the_life_assets/machines/barrel/barrel_idle.png.import
?? assets/the_life_assets/machines/barrel/barrel_work_a.png
?? assets/the_life_assets/machines/barrel/barrel_work_a.png.import
?? assets/the_life_assets/machines/barrel/barrel_work_b.png
?? assets/the_life_assets/machines/barrel/barrel_work_b.png.import
?? assets/the_life_assets/machines/dryer/1x/dryer_idle.png
?? assets/the_life_assets/machines/dryer/1x/dryer_idle.png.import
?? assets/the_life_assets/machines/dryer/1x/dryer_work_a.png
?? assets/the_life_assets/machines/dryer/1x/dryer_work_a.png.import
?? assets/the_life_assets/machines/dryer/1x/dryer_work_b.png
?? assets/the_life_assets/machines/dryer/1x/dryer_work_b.png.import
?? assets/the_life_assets/machines/dryer/dryer_idle.png
?? assets/the_life_assets/machines/dryer/dryer_idle.png.import
?? assets/the_life_assets/machines/dryer/dryer_work_a.png
?? assets/the_life_assets/machines/dryer/dryer_work_a.png.import
?? assets/the_life_assets/machines/dryer/dryer_work_b.png
?? assets/the_life_assets/machines/dryer/dryer_work_b.png.import
?? assets/the_life_assets/machines/machines_manifest.json
?? assets/the_life_assets/machines/mill/1x/mill_idle.png
?? assets/the_life_assets/machines/mill/1x/mill_idle.png.import
?? assets/the_life_assets/machines/mill/1x/mill_work_a.png
?? assets/the_life_assets/machines/mill/1x/mill_work_a.png.import
?? assets/the_life_assets/machines/mill/1x/mill_work_b.png
?? assets/the_life_assets/machines/mill/1x/mill_work_b.png.import
?? assets/the_life_assets/machines/mill/mill_idle.png
?? assets/the_life_assets/machines/mill/mill_idle.png.import
?? assets/the_life_assets/machines/mill/mill_work_a.png
?? assets/the_life_assets/machines/mill/mill_work_a.png.import
?? assets/the_life_assets/machines/mill/mill_work_b.png
?? assets/the_life_assets/machines/mill/mill_work_b.png.import
?? assets/the_life_assets/machines/oven/1x/oven_idle.png
?? assets/the_life_assets/machines/oven/1x/oven_idle.png.import
?? assets/the_life_assets/machines/oven/1x/oven_work_a.png
?? assets/the_life_assets/machines/oven/1x/oven_work_a.png.import
?? assets/the_life_assets/machines/oven/1x/oven_work_b.png
?? assets/the_life_assets/machines/oven/1x/oven_work_b.png.import
?? assets/the_life_assets/machines/oven/oven_idle.png
?? assets/the_life_assets/machines/oven/oven_idle.png.import
?? assets/the_life_assets/machines/oven/oven_work_a.png
?? assets/the_life_assets/machines/oven/oven_work_a.png.import
?? assets/the_life_assets/machines/oven/oven_work_b.png
?? assets/the_life_assets/machines/oven/oven_work_b.png.import
?? assets/the_life_assets/machines/press/1x/press_idle.png
?? assets/the_life_assets/machines/press/1x/press_idle.png.import
?? assets/the_life_assets/machines/press/1x/press_work_a.png
?? assets/the_life_assets/machines/press/1x/press_work_a.png.import
?? assets/the_life_assets/machines/press/1x/press_work_b.png
?? assets/the_life_assets/machines/press/1x/press_work_b.png.import
?? assets/the_life_assets/machines/press/press_idle.png
?? assets/the_life_assets/machines/press/press_idle.png.import
?? assets/the_life_assets/machines/press/press_work_a.png
?? assets/the_life_assets/machines/press/press_work_a.png.import
?? assets/the_life_assets/machines/press/press_work_b.png
?? assets/the_life_assets/machines/press/press_work_b.png.import
?? assets/the_life_assets/machines/roaster/1x/roaster_idle.png
?? assets/the_life_assets/machines/roaster/1x/roaster_idle.png.import
?? assets/the_life_assets/machines/roaster/1x/roaster_work_a.png
?? assets/the_life_assets/machines/roaster/1x/roaster_work_a.png.import
?? assets/the_life_assets/machines/roaster/1x/roaster_work_b.png
?? assets/the_life_assets/machines/roaster/1x/roaster_work_b.png.import
?? assets/the_life_assets/machines/roaster/roaster_idle.png
?? assets/the_life_assets/machines/roaster/roaster_idle.png.import
?? assets/the_life_assets/machines/roaster/roaster_work_a.png
?? assets/the_life_assets/machines/roaster/roaster_work_a.png.import
?? assets/the_life_assets/machines/roaster/roaster_work_b.png
?? assets/the_life_assets/machines/roaster/roaster_work_b.png.import
?? assets/the_life_assets/machines/stove/1x/stove_idle.png
?? assets/the_life_assets/machines/stove/1x/stove_idle.png.import
?? assets/the_life_assets/machines/stove/1x/stove_work_a.png
?? assets/the_life_assets/machines/stove/1x/stove_work_a.png.import
?? assets/the_life_assets/machines/stove/1x/stove_work_b.png
?? assets/the_life_assets/machines/stove/1x/stove_work_b.png.import
?? assets/the_life_assets/machines/stove/stove_idle.png
?? assets/the_life_assets/machines/stove/stove_idle.png.import
?? assets/the_life_assets/machines/stove/stove_work_a.png
?? assets/the_life_assets/machines/stove/stove_work_a.png.import
?? assets/the_life_assets/machines/stove/stove_work_b.png
?? assets/the_life_assets/machines/stove/stove_work_b.png.import
?? assets/the_life_assets/objects/bush.png
?? assets/the_life_assets/objects/bush.png.import
?? assets/the_life_assets/objects/bush_1x.png
?? assets/the_life_assets/objects/bush_1x.png.import
?? assets/the_life_assets/objects/tree_fruit.png
?? assets/the_life_assets/objects/tree_fruit.png.import
?? assets/the_life_assets/objects/tree_fruit_1x.png
?? assets/the_life_assets/objects/tree_fruit_1x.png.import
?? assets/the_life_assets/rocks/1x/rock_large_1.png
?? assets/the_life_assets/rocks/1x/rock_large_1.png.import
?? assets/the_life_assets/rocks/1x/rock_large_2.png
?? assets/the_life_assets/rocks/1x/rock_large_2.png.import
?? assets/the_life_assets/rocks/1x/rock_large_3.png
?? assets/the_life_assets/rocks/1x/rock_large_3.png.import
?? assets/the_life_assets/rocks/1x/rock_medium_1.png
?? assets/the_life_assets/rocks/1x/rock_medium_1.png.import
?? assets/the_life_assets/rocks/1x/rock_medium_2.png
?? assets/the_life_assets/rocks/1x/rock_medium_2.png.import
?? assets/the_life_assets/rocks/1x/rock_medium_3.png
?? assets/the_life_assets/rocks/1x/rock_medium_3.png.import
?? assets/the_life_assets/rocks/1x/rock_small_1.png
?? assets/the_life_assets/rocks/1x/rock_small_1.png.import
?? assets/the_life_assets/rocks/1x/rock_small_2.png
?? assets/the_life_assets/rocks/1x/rock_small_2.png.import
?? assets/the_life_assets/rocks/1x/rock_small_3.png
?? assets/the_life_assets/rocks/1x/rock_small_3.png.import
?? assets/the_life_assets/rocks/rock_large_1.png
?? assets/the_life_assets/rocks/rock_large_1.png.import
?? assets/the_life_assets/rocks/rock_large_2.png
?? assets/the_life_assets/rocks/rock_large_2.png.import
?? assets/the_life_assets/rocks/rock_large_3.png
?? assets/the_life_assets/rocks/rock_large_3.png.import
?? assets/the_life_assets/rocks/rock_medium_1.png
?? assets/the_life_assets/rocks/rock_medium_1.png.import
?? assets/the_life_assets/rocks/rock_medium_2.png
?? assets/the_life_assets/rocks/rock_medium_2.png.import
?? assets/the_life_assets/rocks/rock_medium_3.png
?? assets/the_life_assets/rocks/rock_medium_3.png.import
?? assets/the_life_assets/rocks/rock_small_1.png
?? assets/the_life_assets/rocks/rock_small_1.png.import
?? assets/the_life_assets/rocks/rock_small_2.png
?? assets/the_life_assets/rocks/rock_small_2.png.import
?? assets/the_life_assets/rocks/rock_small_3.png
?? assets/the_life_assets/rocks/rock_small_3.png.import
?? assets/the_life_assets/tiles/layers/dirt_0.png
?? assets/the_life_assets/tiles/layers/dirt_0.png.import
?? assets/the_life_assets/tiles/layers/dirt_1.png
?? assets/the_life_assets/tiles/layers/dirt_1.png.import
?? assets/the_life_assets/tiles/layers/dirt_2.png
?? assets/the_life_assets/tiles/layers/dirt_2.png.import
?? assets/the_life_assets/tiles/layers/dirt_3.png
?? assets/the_life_assets/tiles/layers/dirt_3.png.import
?? assets/the_life_assets/tiles/layers/grass_0.png
?? assets/the_life_assets/tiles/layers/grass_0.png.import
?? assets/the_life_assets/tiles/layers/grass_1.png
?? assets/the_life_assets/tiles/layers/grass_1.png.import
?? assets/the_life_assets/tiles/layers/grass_2.png
?? assets/the_life_assets/tiles/layers/grass_2.png.import
?? assets/the_life_assets/tiles/layers/grass_3.png
?? assets/the_life_assets/tiles/layers/grass_3.png.import
?? assets/the_life_assets/tiles/layers/grass_4.png
?? assets/the_life_assets/tiles/layers/grass_4.png.import
?? assets/the_life_assets/tiles/layers/grass_5.png
?? assets/the_life_assets/tiles/layers/grass_5.png.import
?? assets/the_life_assets/tiles/layers/grass_flower_pink.png
?? assets/the_life_assets/tiles/layers/grass_flower_pink.png.import
?? assets/the_life_assets/tiles/layers/grass_flower_white.png
?? assets/the_life_assets/tiles/layers/grass_flower_white.png.import
?? assets/the_life_assets/tiles/layers/path_0.png
?? assets/the_life_assets/tiles/layers/path_0.png.import
?? assets/the_life_assets/tiles/layers/path_1.png
?? assets/the_life_assets/tiles/layers/path_1.png.import
?? assets/the_life_assets/tiles/layers/path_2.png
?? assets/the_life_assets/tiles/layers/path_2.png.import
?? assets/the_life_assets/tiles/layers/path_3.png
?? assets/the_life_assets/tiles/layers/path_3.png.import
?? assets/the_life_assets/tiles/layers/sand_0.png
?? assets/the_life_assets/tiles/layers/sand_0.png.import
?? assets/the_life_assets/tiles/layers/sand_1.png
?? assets/the_life_assets/tiles/layers/sand_1.png.import
?? assets/the_life_assets/tiles/layers/sand_2.png
?? assets/the_life_assets/tiles/layers/sand_2.png.import
?? assets/the_life_assets/tiles/layers/sand_3.png
?? assets/the_life_assets/tiles/layers/sand_3.png.import
?? assets/the_life_assets/tiles/layers/tilled_dry_0.png
?? assets/the_life_assets/tiles/layers/tilled_dry_0.png.import
?? assets/the_life_assets/tiles/layers/tilled_dry_1.png
?? assets/the_life_assets/tiles/layers/tilled_dry_1.png.import
?? assets/the_life_assets/tiles/layers/tilled_dry_2.png
?? assets/the_life_assets/tiles/layers/tilled_dry_2.png.import
?? assets/the_life_assets/tiles/layers/tilled_dry_3.png
?? assets/the_life_assets/tiles/layers/tilled_dry_3.png.import
?? assets/the_life_assets/tiles/layers/tilled_wet_0.png
?? assets/the_life_assets/tiles/layers/tilled_wet_0.png.import
?? assets/the_life_assets/tiles/layers/tilled_wet_1.png
?? assets/the_life_assets/tiles/layers/tilled_wet_1.png.import
?? assets/the_life_assets/tiles/layers/tilled_wet_2.png
?? assets/the_life_assets/tiles/layers/tilled_wet_2.png.import
?? assets/the_life_assets/tiles/layers/tilled_wet_3.png
?? assets/the_life_assets/tiles/layers/tilled_wet_3.png.import
?? assets/the_life_assets/tiles/layers/water_0.png
?? assets/the_life_assets/tiles/layers/water_0.png.import
?? assets/the_life_assets/tiles/layers/water_1.png
?? assets/the_life_assets/tiles/layers/water_1.png.import
?? assets/the_life_assets/tiles/layers/water_2.png
?? assets/the_life_assets/tiles/layers/water_2.png.import
?? assets/the_life_assets/tiles/layers/water_3.png
?? assets/the_life_assets/tiles/layers/water_3.png.import
?? assets/the_life_assets/tiles/tileset/ground_atlas_128x64.png
?? assets/the_life_assets/tiles/tileset/ground_atlas_128x64.png.import
?? assets/the_life_assets/tiles/tileset/ground_atlas_64x32.png
?? assets/the_life_assets/tiles/tileset/ground_atlas_64x32.png.import
?? assets/the_life_assets/tiles/tileset/ground_tileset_128x64.tres
?? assets/the_life_assets/tiles/tileset/ground_tileset_64x32.tres
?? assets/ui/frame_wood_9slice.png
?? assets/ui/frame_wood_9slice.png.import
?? data/bag_upgrade_config.tres
?? data/chicken_coop_config.tres
?? data/chicken_coop_site.tres
?? data/crops/supplied_crop_catalog.tres
?? data/items/chicken_feed.tres
?? data/items/egg.tres
?? data/items/temp_carrot_meal.tres
?? data/items/temp_corn_bread.tres
?? data/items/temp_dried_chili.tres
?? data/items/temp_orange_juice.tres
?? data/items/temp_pickled_cabbage.tres
?? data/items/temp_roasted_coffee.tres
?? data/items/temp_wheat_flour.tres
?? data/land_expansion/first_east.tres
?? data/land_expansion_config.tres
?? data/land_parcels.tres
?? data/machine_build_config.tres
?? data/machine_shop.tres
?? data/machines/barrel.tres
?? data/machines/dryer.tres
?? data/machines/mill.tres
?? data/machines/oven.tres
?? data/machines/press.tres
?? data/machines/roaster.tres
?? data/machines/stove.tres
?? data/recipe_economy_config.tres
?? data/recipes/barrel_pickled_cabbage.tres
?? data/recipes/dryer_dried_chili.tres
?? data/recipes/mill_wheat_flour.tres
?? data/recipes/oven_corn_bread.tres
?? data/recipes/press_orange_juice.tres
?? data/recipes/roaster_coffee.tres
?? data/recipes/stove_carrot_meal.tres
?? data/tools/shovel.tres
?? data/water_sources.tres
?? data/watering_can_config.tres
?? docs/SCENE_CONTRACTS/bag_upgrade.md
?? docs/SCENE_CONTRACTS/chicken_coop.md
?? docs/SCENE_CONTRACTS/isometric_visuals.md
?? docs/SCENE_CONTRACTS/land_expansion.md
?? docs/SCENE_CONTRACTS/machine_build.md
?? docs/SCENE_CONTRACTS/machine_shop.md
?? docs/SCENE_CONTRACTS/npc_navigation.md
?? docs/SCENE_CONTRACTS/water_sources.md
?? docs/SCENE_CONTRACTS/watering.md
?? docs/SCENE_CONTRACTS/watering_upgrade.md
?? scripts/data/bag_upgrade_config.gd
?? scripts/data/bag_upgrade_config.gd.uid
?? scripts/data/chicken_coop_config.gd
?? scripts/data/chicken_coop_config.gd.uid
?? scripts/data/chicken_coop_site_config.gd
?? scripts/data/chicken_coop_site_config.gd.uid
?? scripts/data/crop_catalog_data.gd
?? scripts/data/crop_catalog_data.gd.uid
?? scripts/data/expansion_parcel_data.gd
?? scripts/data/expansion_parcel_data.gd.uid
?? scripts/data/land_expansion_config.gd
?? scripts/data/land_expansion_config.gd.uid
?? scripts/data/land_parcel_data.gd
?? scripts/data/land_parcel_data.gd.uid
?? scripts/data/machine_build_config.gd
?? scripts/data/machine_build_config.gd.uid
?? scripts/data/machine_data.gd
?? scripts/data/machine_data.gd.uid
?? scripts/data/machine_shop_data.gd
?? scripts/data/machine_shop_data.gd.uid
?? scripts/data/recipe_data.gd
?? scripts/data/recipe_data.gd.uid
?? scripts/data/recipe_economy_config.gd
?? scripts/data/recipe_economy_config.gd.uid
?? scripts/data/water_source_config.gd
?? scripts/data/water_source_config.gd.uid
?? scripts/data/water_source_data.gd
?? scripts/data/water_source_data.gd.uid
?? scripts/data/watering_can_config.gd
?? scripts/data/watering_can_config.gd.uid
?? scripts/domain/building/land_expansion_rules.gd
?? scripts/domain/building/land_expansion_rules.gd.uid
?? scripts/domain/building/land_expansion_service.gd
?? scripts/domain/building/land_expansion_service.gd.uid
?? scripts/domain/building/land_ownership_state.gd
?? scripts/domain/building/land_ownership_state.gd.uid
?? scripts/domain/building/machine_build_service.gd
?? scripts/domain/building/machine_build_service.gd.uid
?? scripts/domain/building/machine_placement_request.gd
?? scripts/domain/building/machine_placement_request.gd.uid
?? scripts/domain/building/occupancy_map.gd
?? scripts/domain/building/occupancy_map.gd.uid
?? scripts/domain/chicken_coop_collection_service.gd
?? scripts/domain/chicken_coop_collection_service.gd.uid
?? scripts/domain/chicken_coop_feeding_service.gd
?? scripts/domain/chicken_coop_feeding_service.gd.uid
?? scripts/domain/chicken_coop_holding_state.gd
?? scripts/domain/chicken_coop_holding_state.gd.uid
?? scripts/domain/chicken_coop_purchase_rules.gd
?? scripts/domain/chicken_coop_purchase_rules.gd.uid
?? scripts/domain/chicken_coop_save_codec.gd
?? scripts/domain/chicken_coop_save_codec.gd.uid
?? scripts/domain/chicken_coop_shop_service.gd
?? scripts/domain/chicken_coop_shop_service.gd.uid
?? scripts/domain/chicken_coop_state.gd
?? scripts/domain/chicken_coop_state.gd.uid
?? scripts/domain/economy/recipe_catalog_rules.gd
?? scripts/domain/economy/recipe_catalog_rules.gd.uid
?? scripts/domain/economy/recipe_economy_rules.gd
?? scripts/domain/economy/recipe_economy_rules.gd.uid
?? scripts/domain/inventory_upgrade_service.gd
?? scripts/domain/inventory_upgrade_service.gd.uid
?? scripts/domain/production/machine_inventory.gd
?? scripts/domain/production/machine_inventory.gd.uid
?? scripts/domain/production/machine_operation_service.gd
?? scripts/domain/production/machine_operation_service.gd.uid
?? scripts/domain/production/machine_placement_state.gd
?? scripts/domain/production/machine_placement_state.gd.uid
?? scripts/domain/production/machine_shop_service.gd
?? scripts/domain/production/machine_shop_service.gd.uid
?? scripts/domain/production/machine_state.gd
?? scripts/domain/production/machine_state.gd.uid
?? scripts/domain/water_refill_service.gd
?? scripts/domain/water_refill_service.gd.uid
?? scripts/domain/water_source_rules.gd
?? scripts/domain/water_source_rules.gd.uid
?? scripts/domain/watering_can_state.gd
?? scripts/domain/watering_can_state.gd.uid
?? scripts/domain/watering_can_upgrade_service.gd
?? scripts/domain/watering_can_upgrade_service.gd.uid
?? scripts/domain/watering_service.gd
?? scripts/domain/watering_service.gd.uid
?? scripts/domain/weather_roller.gd
?? scripts/domain/weather_roller.gd.uid
?? scripts/domain/weather_save_codec.gd
?? scripts/domain/weather_save_codec.gd.uid
?? scripts/domain/weather_snapshot_codec.gd
?? scripts/domain/weather_snapshot_codec.gd.uid
?? scripts/view/bag_upgrade_flow.gd
?? scripts/view/bag_upgrade_flow.gd.uid
?? scripts/view/chicken_coop_flow.gd
?? scripts/view/chicken_coop_flow.gd.uid
?? scripts/view/chicken_coop_runtime.gd
?? scripts/view/chicken_coop_runtime.gd.uid
?? scripts/view/chicken_coop_site_view.gd
?? scripts/view/chicken_coop_site_view.gd.uid
?? scripts/view/land_runtime.gd
?? scripts/view/land_runtime.gd.uid
?? scripts/view/machine_interaction_controller.gd
?? scripts/view/machine_interaction_controller.gd.uid
?? scripts/view/machine_placement_flow.gd
?? scripts/view/machine_placement_flow.gd.uid
?? scripts/view/machine_placement_preview.gd
?? scripts/view/machine_placement_preview.gd.uid
?? scripts/view/machine_presentation.gd
?? scripts/view/machine_presentation.gd.uid
?? scripts/view/machine_shop_panel.gd
?? scripts/view/machine_shop_panel.gd.uid
?? scripts/view/water_source_view.gd
?? scripts/view/water_source_view.gd.uid
?? scripts/view/watering_runtime.gd
?? scripts/view/watering_runtime.gd.uid
?? scripts/view/watering_upgrade_flow.gd
?? scripts/view/watering_upgrade_flow.gd.uid
?? tests/fixtures/weather_rng_v12.json
?? tests/fixtures/weather_snapshot_v11.json
?? tests/golden_saves/save_v10.json
?? tests/golden_saves/save_v11.json
?? tests/golden_saves/save_v12.json
?? tests/golden_saves/save_v9.json
?? tests/helpers/chicken_coop_fixture.gd
?? tests/helpers/chicken_coop_fixture.gd.uid
?? tests/unit/test_bag_upgrade.gd
?? tests/unit/test_bag_upgrade.gd.uid
?? tests/unit/test_bag_upgrade_flow.gd
?? tests/unit/test_bag_upgrade_flow.gd.uid
?? tests/unit/test_bag_upgrade_screen.gd
?? tests/unit/test_bag_upgrade_screen.gd.uid
?? tests/unit/test_camera_rig.gd
?? tests/unit/test_camera_rig.gd.uid
?? tests/unit/test_chicken_coop_callback_lifecycle.gd
?? tests/unit/test_chicken_coop_callback_lifecycle.gd.uid
?? tests/unit/test_chicken_coop_collection.gd
?? tests/unit/test_chicken_coop_collection.gd.uid
?? tests/unit/test_chicken_coop_collection_callbacks.gd
?? tests/unit/test_chicken_coop_collection_callbacks.gd.uid
?? tests/unit/test_chicken_coop_feeding.gd
?? tests/unit/test_chicken_coop_feeding.gd.uid
?? tests/unit/test_chicken_coop_feeding_callbacks.gd
?? tests/unit/test_chicken_coop_feeding_callbacks.gd.uid
?? tests/unit/test_chicken_coop_purchase.gd
?? tests/unit/test_chicken_coop_purchase.gd.uid
?? tests/unit/test_chicken_coop_runtime.gd
?? tests/unit/test_chicken_coop_runtime.gd.uid
?? tests/unit/test_chicken_coop_runtime_save.gd
?? tests/unit/test_chicken_coop_runtime_save.gd.uid
?? tests/unit/test_chicken_coop_screen.gd
?? tests/unit/test_chicken_coop_screen.gd.uid
?? tests/unit/test_chicken_coop_state.gd
?? tests/unit/test_chicken_coop_state.gd.uid
?? tests/unit/test_d72_animation.gd
?? tests/unit/test_d72_animation.gd.uid
?? tests/unit/test_d72_camera_input.gd
?? tests/unit/test_d72_camera_input.gd.uid
?? tests/unit/test_d72_locale_refresh.gd
?? tests/unit/test_d72_locale_refresh.gd.uid
?? tests/unit/test_d72_toolbar_selection.gd
?? tests/unit/test_d72_toolbar_selection.gd.uid
?? tests/unit/test_d72_visual_review.gd
?? tests/unit/test_d72_visual_review.gd.uid
?? tests/unit/test_land_expansion.gd
?? tests/unit/test_land_expansion.gd.uid
?? tests/unit/test_land_runtime.gd
?? tests/unit/test_land_runtime.gd.uid
?? tests/unit/test_land_save.gd
?? tests/unit/test_land_save.gd.uid
?? tests/unit/test_land_screen.gd
?? tests/unit/test_land_screen.gd.uid
?? tests/unit/test_machine_build_lifecycle.gd
?? tests/unit/test_machine_build_lifecycle.gd.uid
?? tests/unit/test_machine_collection.gd
?? tests/unit/test_machine_collection.gd.uid
?? tests/unit/test_machine_move_request.gd
?? tests/unit/test_machine_move_request.gd.uid
?? tests/unit/test_machine_move_ui.gd
?? tests/unit/test_machine_move_ui.gd.uid
?? tests/unit/test_machine_operation.gd
?? tests/unit/test_machine_operation.gd.uid
?? tests/unit/test_machine_placement.gd
?? tests/unit/test_machine_placement.gd.uid
?? tests/unit/test_machine_placement_request.gd
?? tests/unit/test_machine_placement_request.gd.uid
?? tests/unit/test_machine_placement_ui.gd
?? tests/unit/test_machine_placement_ui.gd.uid
?? tests/unit/test_machine_presentation.gd
?? tests/unit/test_machine_presentation.gd.uid
?? tests/unit/test_machine_screen.gd
?? tests/unit/test_machine_screen.gd.uid
?? tests/unit/test_machine_shop.gd
?? tests/unit/test_machine_shop.gd.uid
?? tests/unit/test_machine_state.gd
?? tests/unit/test_machine_state.gd.uid
?? tests/unit/test_player_restoration.gd
?? tests/unit/test_player_restoration.gd.uid
?? tests/unit/test_recipe_catalog_validation.gd
?? tests/unit/test_recipe_catalog_validation.gd.uid
?? tests/unit/test_recipe_economy.gd
?? tests/unit/test_recipe_economy.gd.uid
?? tests/unit/test_recipe_validator_cli.gd
?? tests/unit/test_recipe_validator_cli.gd.uid
?? tests/unit/test_water_source_config.gd
?? tests/unit/test_water_source_config.gd.uid
?? tests/unit/test_water_source_world.gd
?? tests/unit/test_water_source_world.gd.uid
?? tests/unit/test_watering_can_state.gd
?? tests/unit/test_watering_can_state.gd.uid
?? tests/unit/test_watering_can_upgrade.gd
?? tests/unit/test_watering_can_upgrade.gd.uid
?? tests/unit/test_watering_hud.gd
?? tests/unit/test_watering_hud.gd.uid
?? tests/unit/test_watering_refill.gd
?? tests/unit/test_watering_refill.gd.uid
?? tests/unit/test_watering_runtime.gd
?? tests/unit/test_watering_runtime.gd.uid
?? tests/unit/test_watering_runtime_save.gd
?? tests/unit/test_watering_runtime_save.gd.uid
?? tests/unit/test_watering_service.gd
?? tests/unit/test_watering_service.gd.uid
?? tests/unit/test_watering_upgrade_flow.gd
?? tests/unit/test_watering_upgrade_flow.gd.uid
?? tests/unit/test_watering_upgrade_ledger.gd
?? tests/unit/test_watering_upgrade_ledger.gd.uid
?? tests/unit/test_watering_upgrade_screen.gd
?? tests/unit/test_watering_upgrade_screen.gd.uid
?? tests/unit/test_weather_daily_state.gd
?? tests/unit/test_weather_daily_state.gd.uid
?? tests/unit/test_weather_profile_validation.gd
?? tests/unit/test_weather_profile_validation.gd.uid
?? tests/unit/test_weather_rollover_guard.gd
?? tests/unit/test_weather_rollover_guard.gd.uid
?? tests/unit/test_weather_rolls.gd
?? tests/unit/test_weather_rolls.gd.uid
?? tests/unit/test_weather_runtime_save.gd
?? tests/unit/test_weather_runtime_save.gd.uid
?? tests/unit/test_weather_snapshot_codec.gd
?? tests/unit/test_weather_snapshot_codec.gd.uid
?? the_life_master_prompt.md
?? tools/build_isometric_2d_assets.gd
?? tools/build_isometric_2d_assets.gd.uid
?? tools/run_graphics_tests.ps1
?? tools/validate_recipe_economy.gd
?? tools/validate_recipe_economy.gd.uid
?? ui/bag_upgrade/bag_upgrade_footer.gd
?? ui/bag_upgrade/bag_upgrade_footer.gd.uid
?? ui/bag_upgrade/bag_upgrade_footer.tscn
?? ui/bag_upgrade/bag_upgrade_presenter.gd
?? ui/bag_upgrade/bag_upgrade_presenter.gd.uid
?? ui/bag_upgrade/bag_upgrade_screen.gd
?? ui/bag_upgrade/bag_upgrade_screen.gd.uid
?? ui/bag_upgrade/bag_upgrade_screen.tscn
?? ui/bag_upgrade/bag_upgrade_snapshot.gd
?? ui/bag_upgrade/bag_upgrade_snapshot.gd.uid
?? ui/bag_upgrade/bag_upgrade_summary.gd
?? ui/bag_upgrade/bag_upgrade_summary.gd.uid
?? ui/bag_upgrade/bag_upgrade_summary.tscn
?? ui/chicken_coop/chicken_coop_controls.gd
?? ui/chicken_coop/chicken_coop_controls.gd.uid
?? ui/chicken_coop/chicken_coop_controls.tscn
?? ui/chicken_coop/chicken_coop_presenter.gd
?? ui/chicken_coop/chicken_coop_presenter.gd.uid
?? ui/chicken_coop/chicken_coop_screen.gd
?? ui/chicken_coop/chicken_coop_screen.gd.uid
?? ui/chicken_coop/chicken_coop_screen.tscn
?? ui/chicken_coop/chicken_coop_snapshot.gd
?? ui/chicken_coop/chicken_coop_snapshot.gd.uid
?? ui/chicken_coop/chicken_coop_summary.gd
?? ui/chicken_coop/chicken_coop_summary.gd.uid
?? ui/chicken_coop/chicken_coop_summary.tscn
?? ui/hud/water_meter.gd
?? ui/hud/water_meter.gd.uid
?? ui/land/land_footer.gd
?? ui/land/land_footer.gd.uid
?? ui/land/land_footer.tscn
?? ui/land/land_presenter.gd
?? ui/land/land_presenter.gd.uid
?? ui/land/land_screen.gd
?? ui/land/land_screen.gd.uid
?? ui/land/land_screen.tscn
?? ui/land/land_snapshot.gd
?? ui/land/land_snapshot.gd.uid
?? ui/land/land_summary.gd
?? ui/land/land_summary.gd.uid
?? ui/land/land_summary.tscn
?? ui/machine/build_overlay.gd
?? ui/machine/build_overlay.gd.uid
?? ui/machine/build_overlay.tscn
?? ui/machine/build_status.gd
?? ui/machine/build_status.gd.uid
?? ui/machine/build_status.tscn
?? ui/machine/machine_card.gd
?? ui/machine/machine_card.gd.uid
?? ui/machine/machine_card.tscn
?? ui/machine/machine_catalog.gd
?? ui/machine/machine_catalog.gd.uid
?? ui/machine/machine_catalog.tscn
?? ui/machine/machine_controller.gd
?? ui/machine/machine_controller.gd.uid
?? ui/machine/machine_details.gd
?? ui/machine/machine_details.gd.uid
?? ui/machine/machine_details.tscn
?? ui/machine/machine_footer.gd
?? ui/machine/machine_footer.gd.uid
?? ui/machine/machine_footer.tscn
?? ui/machine/machine_presenter.gd
?? ui/machine/machine_presenter.gd.uid
?? ui/machine/machine_screen.gd
?? ui/machine/machine_screen.gd.uid
?? ui/machine/machine_screen.tscn
?? ui/machine/machine_snapshot.gd
?? ui/machine/machine_snapshot.gd.uid
?? ui/watering_upgrade/watering_upgrade_footer.gd
?? ui/watering_upgrade/watering_upgrade_footer.gd.uid
?? ui/watering_upgrade/watering_upgrade_footer.tscn
?? ui/watering_upgrade/watering_upgrade_presenter.gd
?? ui/watering_upgrade/watering_upgrade_presenter.gd.uid
?? ui/watering_upgrade/watering_upgrade_screen.gd
?? ui/watering_upgrade/watering_upgrade_screen.gd.uid
?? ui/watering_upgrade/watering_upgrade_screen.tscn
?? ui/watering_upgrade/watering_upgrade_snapshot.gd
?? ui/watering_upgrade/watering_upgrade_snapshot.gd.uid
?? ui/watering_upgrade/watering_upgrade_summary.gd
?? ui/watering_upgrade/watering_upgrade_summary.gd.uid
?? ui/watering_upgrade/watering_upgrade_summary.tscn
```

## Phụ lục B —57 path ALLOW_LIST mới nhất Phase7.1b

Đọc từ plan56 path và bổ sung `test_day_simulator.gd` đã được người dùng duyệt. Không dùng danh sách này để kết luận mọi thay đổi cũ khác là trái phép.

```text
docs/PROGRESS.md
docs/API_INDEX.md
docs/ARCHITECTURE.md
docs/DATA_SCHEMA.md
docs/DECISIONS.md
docs/ROADMAP.md
docs/SCENE_CONTRACTS/gray_box_world.md
docs/SCENE_CONTRACTS/day_end.md
docs/SCENE_CONTRACTS/morning_bulletin.md
scripts/data/weather_profile.gd
data/weather_profile.tres
scripts/domain/weather_state.gd
scripts/domain/weather_snapshot_codec.gd
scripts/domain/quests/det_random.gd
scripts/core/save_service.gd
scripts/view/main.gd
tests/unit/test_bag_upgrade_flow.gd
tests/unit/test_character_screen.gd
tests/unit/test_chicken_coop_collection.gd
tests/unit/test_chicken_coop_feeding.gd
tests/unit/test_chicken_coop_runtime_save.gd
tests/unit/test_crop_care_save.gd
tests/unit/test_crop_regrow_save.gd
tests/unit/test_day_end_flow.gd
tests/unit/test_day_end_save.gd
tests/unit/test_inventory_actions.gd
tests/unit/test_land_save.gd
tests/unit/test_machine_build_lifecycle.gd
tests/unit/test_machine_collection.gd
tests/unit/test_morning_flow.gd
tests/unit/test_npc_social_save.gd
tests/unit/test_pause_settings.gd
tests/unit/test_profile_creation.gd
tests/unit/test_quest_book.gd
tests/unit/test_recipe_economy.gd
tests/unit/test_save_service.gd
tests/unit/test_title_flow.gd
tests/unit/test_water_source_world.gd
tests/unit/test_watering_runtime_save.gd
tests/unit/test_watering_upgrade_flow.gd
tests/unit/test_weather.gd
tests/unit/test_weather_snapshot_codec.gd
scripts/domain/weather_roller.gd
scripts/domain/weather_roller.gd.uid
scripts/domain/weather_save_codec.gd
scripts/domain/weather_save_codec.gd.uid
tests/unit/test_weather_rolls.gd
tests/unit/test_weather_rolls.gd.uid
tests/unit/test_weather_daily_state.gd
tests/unit/test_weather_daily_state.gd.uid
tests/unit/test_weather_runtime_save.gd
tests/unit/test_weather_runtime_save.gd.uid
tests/unit/test_weather_rollover_guard.gd
tests/unit/test_weather_rollover_guard.gd.uid
tests/golden_saves/save_v12.json
tests/fixtures/weather_rng_v12.json
tests/unit/test_day_simulator.gd
```

## Phụ lục C — PNG chưa có consumer runtime và nguồn lưu giữ

### C1.16candidate chưa tìm thấy đường nạp active

Các file có thật; đây là ứng viên chưa tích hợp, không phải lệnh xóa.

| File | Kích thước | Phân loại |
|---|---:|---|
| `assets/buildings/cottage_2x.png` | 160×140 |PNG draft/offline D72, chưa bind |
| `assets/buildings/market_2x.png` | 140×128 |PNG draft/offline D72, chưa bind |
| `assets/buildings/shipping_bin_2x.png` | 96×88 |PNG draft/offline D72, chưa bind |
| `assets/characters/farmer_sheet_2x.png` | 256×64 |PNG draft/offline D72, chưa bind |
| `assets/decor/flower_0.png` | 32×40 |Asset supplied đã nhập, chưa render |
| `assets/decor/flower_1.png` | 32×40 |Asset supplied đã nhập, chưa render |
| `assets/decor/flower_2.png` | 32×40 |Asset supplied đã nhập, chưa render |
| `assets/decor/flower_3.png` | 32×40 |Asset supplied đã nhập, chưa render |
| `assets/decor/pebble_0.png` | 32×32 |Asset supplied đã nhập, chưa render |
| `assets/decor/pebble_1.png` | 32×32 |Asset supplied đã nhập, chưa render |
| `assets/decor/tuft_0.png` | 32×32 |Asset supplied đã nhập, chưa render |
| `assets/decor/tuft_1.png` | 32×32 |Asset supplied đã nhập, chưa render |
| `assets/decor/tuft_2.png` | 32×32 |Asset supplied đã nhập, chưa render |
| `assets/objects/bush.png` | 96×80 |Asset supplied đã nhập, chưa render |
| `assets/objects/tree_fruit.png` | 128×176 |Asset supplied đã nhập, chưa render |
| `assets/ui/frame_wood_9slice.png` | 96×96 |PNG draft/offline D72, chưa bind |

### C2.227 PNG canonical giữ nguồn/legacy, không nạp trực tiếp

Gồm194 bản thấp phân giải,32 ảnh input atlas và1atlas64×32 cũ. Phân biệt với16candidate bỏ sót tích hợp ởC1. Danh sách đầy đủ để kiểm tra, không coi đây là rác cần xóa:

```text
assets/crops/apple/1x/apple_seed.png
assets/crops/apple/1x/apple_stage1.png
assets/crops/apple/1x/apple_stage1_wilted.png
assets/crops/apple/1x/apple_stage2.png
assets/crops/apple/1x/apple_stage2_wilted.png
assets/crops/apple/1x/apple_stage3.png
assets/crops/apple/1x/apple_stage3_wilted.png
assets/crops/apple/1x/apple_stage4.png
assets/crops/apple/1x/apple_stage4_wilted.png
assets/crops/banana/1x/banana_seed.png
assets/crops/banana/1x/banana_stage1.png
assets/crops/banana/1x/banana_stage1_wilted.png
assets/crops/banana/1x/banana_stage2.png
assets/crops/banana/1x/banana_stage2_wilted.png
assets/crops/banana/1x/banana_stage3.png
assets/crops/banana/1x/banana_stage3_wilted.png
assets/crops/banana/1x/banana_stage4.png
assets/crops/banana/1x/banana_stage4_wilted.png
assets/crops/cabbage/1x/cabbage_seed.png
assets/crops/cabbage/1x/cabbage_stage1.png
assets/crops/cabbage/1x/cabbage_stage1_wilted.png
assets/crops/cabbage/1x/cabbage_stage2.png
assets/crops/cabbage/1x/cabbage_stage2_wilted.png
assets/crops/cabbage/1x/cabbage_stage3.png
assets/crops/cabbage/1x/cabbage_stage3_wilted.png
assets/crops/cabbage/1x/cabbage_stage4.png
assets/crops/cabbage/1x/cabbage_stage4_wilted.png
assets/crops/carrot/1x/carrot_seed.png
assets/crops/carrot/1x/carrot_stage1.png
assets/crops/carrot/1x/carrot_stage1_wilted.png
assets/crops/carrot/1x/carrot_stage2.png
assets/crops/carrot/1x/carrot_stage2_wilted.png
assets/crops/carrot/1x/carrot_stage3.png
assets/crops/carrot/1x/carrot_stage3_wilted.png
assets/crops/carrot/1x/carrot_stage4.png
assets/crops/carrot/1x/carrot_stage4_wilted.png
assets/crops/chili/1x/chili_seed.png
assets/crops/chili/1x/chili_stage1.png
assets/crops/chili/1x/chili_stage1_wilted.png
assets/crops/chili/1x/chili_stage2.png
assets/crops/chili/1x/chili_stage2_wilted.png
assets/crops/chili/1x/chili_stage3.png
assets/crops/chili/1x/chili_stage3_wilted.png
assets/crops/chili/1x/chili_stage4.png
assets/crops/chili/1x/chili_stage4_wilted.png
assets/crops/coffee/1x/coffee_seed.png
assets/crops/coffee/1x/coffee_stage1.png
assets/crops/coffee/1x/coffee_stage1_wilted.png
assets/crops/coffee/1x/coffee_stage2.png
assets/crops/coffee/1x/coffee_stage2_wilted.png
assets/crops/coffee/1x/coffee_stage3.png
assets/crops/coffee/1x/coffee_stage3_wilted.png
assets/crops/coffee/1x/coffee_stage4.png
assets/crops/coffee/1x/coffee_stage4_wilted.png
assets/crops/corn/1x/corn_seed.png
assets/crops/corn/1x/corn_stage1.png
assets/crops/corn/1x/corn_stage1_wilted.png
assets/crops/corn/1x/corn_stage2.png
assets/crops/corn/1x/corn_stage2_wilted.png
assets/crops/corn/1x/corn_stage3.png
assets/crops/corn/1x/corn_stage3_wilted.png
assets/crops/corn/1x/corn_stage4.png
assets/crops/corn/1x/corn_stage4_wilted.png
assets/crops/eggplant/1x/eggplant_seed.png
assets/crops/eggplant/1x/eggplant_stage1.png
assets/crops/eggplant/1x/eggplant_stage1_wilted.png
assets/crops/eggplant/1x/eggplant_stage2.png
assets/crops/eggplant/1x/eggplant_stage2_wilted.png
assets/crops/eggplant/1x/eggplant_stage3.png
assets/crops/eggplant/1x/eggplant_stage3_wilted.png
assets/crops/eggplant/1x/eggplant_stage4.png
assets/crops/eggplant/1x/eggplant_stage4_wilted.png
assets/crops/orange/1x/orange_seed.png
assets/crops/orange/1x/orange_stage1.png
assets/crops/orange/1x/orange_stage1_wilted.png
assets/crops/orange/1x/orange_stage2.png
assets/crops/orange/1x/orange_stage2_wilted.png
assets/crops/orange/1x/orange_stage3.png
assets/crops/orange/1x/orange_stage3_wilted.png
assets/crops/orange/1x/orange_stage4.png
assets/crops/orange/1x/orange_stage4_wilted.png
assets/crops/pepper/1x/pepper_seed.png
assets/crops/pepper/1x/pepper_stage1.png
assets/crops/pepper/1x/pepper_stage1_wilted.png
assets/crops/pepper/1x/pepper_stage2.png
assets/crops/pepper/1x/pepper_stage2_wilted.png
assets/crops/pepper/1x/pepper_stage3.png
assets/crops/pepper/1x/pepper_stage3_wilted.png
assets/crops/pepper/1x/pepper_stage4.png
assets/crops/pepper/1x/pepper_stage4_wilted.png
assets/crops/pumpkin/1x/pumpkin_seed.png
assets/crops/pumpkin/1x/pumpkin_stage1.png
assets/crops/pumpkin/1x/pumpkin_stage1_wilted.png
assets/crops/pumpkin/1x/pumpkin_stage2.png
assets/crops/pumpkin/1x/pumpkin_stage2_wilted.png
assets/crops/pumpkin/1x/pumpkin_stage3.png
assets/crops/pumpkin/1x/pumpkin_stage3_wilted.png
assets/crops/pumpkin/1x/pumpkin_stage4.png
assets/crops/pumpkin/1x/pumpkin_stage4_wilted.png
assets/crops/radish/1x/radish_seed.png
assets/crops/radish/1x/radish_stage1.png
assets/crops/radish/1x/radish_stage1_wilted.png
assets/crops/radish/1x/radish_stage2.png
assets/crops/radish/1x/radish_stage2_wilted.png
assets/crops/radish/1x/radish_stage3.png
assets/crops/radish/1x/radish_stage3_wilted.png
assets/crops/radish/1x/radish_stage4.png
assets/crops/radish/1x/radish_stage4_wilted.png
assets/crops/rice/1x/rice_seed.png
assets/crops/rice/1x/rice_stage1.png
assets/crops/rice/1x/rice_stage1_wilted.png
assets/crops/rice/1x/rice_stage2.png
assets/crops/rice/1x/rice_stage2_wilted.png
assets/crops/rice/1x/rice_stage3.png
assets/crops/rice/1x/rice_stage3_wilted.png
assets/crops/rice/1x/rice_stage4.png
assets/crops/rice/1x/rice_stage4_wilted.png
assets/crops/strawberry/1x/strawberry_seed.png
assets/crops/strawberry/1x/strawberry_stage1.png
assets/crops/strawberry/1x/strawberry_stage1_wilted.png
assets/crops/strawberry/1x/strawberry_stage2.png
assets/crops/strawberry/1x/strawberry_stage2_wilted.png
assets/crops/strawberry/1x/strawberry_stage3.png
assets/crops/strawberry/1x/strawberry_stage3_wilted.png
assets/crops/strawberry/1x/strawberry_stage4.png
assets/crops/strawberry/1x/strawberry_stage4_wilted.png
assets/crops/sunflower/1x/sunflower_seed.png
assets/crops/sunflower/1x/sunflower_stage1.png
assets/crops/sunflower/1x/sunflower_stage1_wilted.png
assets/crops/sunflower/1x/sunflower_stage2.png
assets/crops/sunflower/1x/sunflower_stage2_wilted.png
assets/crops/sunflower/1x/sunflower_stage3.png
assets/crops/sunflower/1x/sunflower_stage3_wilted.png
assets/crops/sunflower/1x/sunflower_stage4.png
assets/crops/sunflower/1x/sunflower_stage4_wilted.png
assets/crops/tomato/1x/tomato_seed.png
assets/crops/tomato/1x/tomato_stage1.png
assets/crops/tomato/1x/tomato_stage1_wilted.png
assets/crops/tomato/1x/tomato_stage2.png
assets/crops/tomato/1x/tomato_stage2_wilted.png
assets/crops/tomato/1x/tomato_stage3.png
assets/crops/tomato/1x/tomato_stage3_wilted.png
assets/crops/tomato/1x/tomato_stage4.png
assets/crops/tomato/1x/tomato_stage4_wilted.png
assets/decor/flower_0_1x.png
assets/decor/flower_1_1x.png
assets/decor/flower_2_1x.png
assets/decor/flower_3_1x.png
assets/decor/pebble_0_1x.png
assets/decor/pebble_1_1x.png
assets/decor/tuft_0_1x.png
assets/decor/tuft_1_1x.png
assets/decor/tuft_2_1x.png
assets/grass_clumps/1x/grass_clump_large_1.png
assets/grass_clumps/1x/grass_clump_large_2.png
assets/grass_clumps/1x/grass_clump_large_3.png
assets/grass_clumps/1x/grass_clump_medium_1.png
assets/grass_clumps/1x/grass_clump_medium_2.png
assets/grass_clumps/1x/grass_clump_medium_3.png
assets/grass_clumps/1x/grass_clump_small_1.png
assets/grass_clumps/1x/grass_clump_small_2.png
assets/grass_clumps/1x/grass_clump_small_3.png
assets/machines/barrel/1x/barrel_idle.png
assets/machines/barrel/1x/barrel_work_a.png
assets/machines/barrel/1x/barrel_work_b.png
assets/machines/dryer/1x/dryer_idle.png
assets/machines/dryer/1x/dryer_work_a.png
assets/machines/dryer/1x/dryer_work_b.png
assets/machines/mill/1x/mill_idle.png
assets/machines/mill/1x/mill_work_a.png
assets/machines/mill/1x/mill_work_b.png
assets/machines/oven/1x/oven_idle.png
assets/machines/oven/1x/oven_work_a.png
assets/machines/oven/1x/oven_work_b.png
assets/machines/press/1x/press_idle.png
assets/machines/press/1x/press_work_a.png
assets/machines/press/1x/press_work_b.png
assets/machines/roaster/1x/roaster_idle.png
assets/machines/roaster/1x/roaster_work_a.png
assets/machines/roaster/1x/roaster_work_b.png
assets/machines/stove/1x/stove_idle.png
assets/machines/stove/1x/stove_work_a.png
assets/machines/stove/1x/stove_work_b.png
assets/objects/bush_1x.png
assets/objects/tree_fruit_1x.png
assets/rocks/1x/rock_large_1.png
assets/rocks/1x/rock_large_2.png
assets/rocks/1x/rock_large_3.png
assets/rocks/1x/rock_medium_1.png
assets/rocks/1x/rock_medium_2.png
assets/rocks/1x/rock_medium_3.png
assets/rocks/1x/rock_small_1.png
assets/rocks/1x/rock_small_2.png
assets/rocks/1x/rock_small_3.png
assets/tiles/layers/dirt_0.png
assets/tiles/layers/dirt_1.png
assets/tiles/layers/dirt_2.png
assets/tiles/layers/dirt_3.png
assets/tiles/layers/grass_0.png
assets/tiles/layers/grass_1.png
assets/tiles/layers/grass_2.png
assets/tiles/layers/grass_3.png
assets/tiles/layers/grass_4.png
assets/tiles/layers/grass_5.png
assets/tiles/layers/grass_flower_pink.png
assets/tiles/layers/grass_flower_white.png
assets/tiles/layers/path_0.png
assets/tiles/layers/path_1.png
assets/tiles/layers/path_2.png
assets/tiles/layers/path_3.png
assets/tiles/layers/sand_0.png
assets/tiles/layers/sand_1.png
assets/tiles/layers/sand_2.png
assets/tiles/layers/sand_3.png
assets/tiles/layers/tilled_dry_0.png
assets/tiles/layers/tilled_dry_1.png
assets/tiles/layers/tilled_dry_2.png
assets/tiles/layers/tilled_dry_3.png
assets/tiles/layers/tilled_wet_0.png
assets/tiles/layers/tilled_wet_1.png
assets/tiles/layers/tilled_wet_2.png
assets/tiles/layers/tilled_wet_3.png
assets/tiles/layers/water_0.png
assets/tiles/layers/water_1.png
assets/tiles/layers/water_2.png
assets/tiles/layers/water_3.png
assets/tiles/tileset/ground_atlas_64x32.png
```

### C3.422 PNG bản nguồn lồng

Mọi file dưới đây có ảnh canonical tương ứng ở `assets/<phần sau the_life_assets/>` và SHA256 giống hệt422/422. Không tìm prefix này trong runtime consumer. Liệt kê riêng nguồn lưu giữ để không nhầm với sprite nạp động đang dùng:

```text
assets/the_life_assets/crops/apple/1x/apple_seed.png
assets/the_life_assets/crops/apple/1x/apple_stage1.png
assets/the_life_assets/crops/apple/1x/apple_stage1_wilted.png
assets/the_life_assets/crops/apple/1x/apple_stage2.png
assets/the_life_assets/crops/apple/1x/apple_stage2_wilted.png
assets/the_life_assets/crops/apple/1x/apple_stage3.png
assets/the_life_assets/crops/apple/1x/apple_stage3_wilted.png
assets/the_life_assets/crops/apple/1x/apple_stage4.png
assets/the_life_assets/crops/apple/1x/apple_stage4_wilted.png
assets/the_life_assets/crops/apple/apple_seed.png
assets/the_life_assets/crops/apple/apple_stage1.png
assets/the_life_assets/crops/apple/apple_stage1_wilted.png
assets/the_life_assets/crops/apple/apple_stage2.png
assets/the_life_assets/crops/apple/apple_stage2_wilted.png
assets/the_life_assets/crops/apple/apple_stage3.png
assets/the_life_assets/crops/apple/apple_stage3_wilted.png
assets/the_life_assets/crops/apple/apple_stage4.png
assets/the_life_assets/crops/apple/apple_stage4_wilted.png
assets/the_life_assets/crops/banana/1x/banana_seed.png
assets/the_life_assets/crops/banana/1x/banana_stage1.png
assets/the_life_assets/crops/banana/1x/banana_stage1_wilted.png
assets/the_life_assets/crops/banana/1x/banana_stage2.png
assets/the_life_assets/crops/banana/1x/banana_stage2_wilted.png
assets/the_life_assets/crops/banana/1x/banana_stage3.png
assets/the_life_assets/crops/banana/1x/banana_stage3_wilted.png
assets/the_life_assets/crops/banana/1x/banana_stage4.png
assets/the_life_assets/crops/banana/1x/banana_stage4_wilted.png
assets/the_life_assets/crops/banana/banana_seed.png
assets/the_life_assets/crops/banana/banana_stage1.png
assets/the_life_assets/crops/banana/banana_stage1_wilted.png
assets/the_life_assets/crops/banana/banana_stage2.png
assets/the_life_assets/crops/banana/banana_stage2_wilted.png
assets/the_life_assets/crops/banana/banana_stage3.png
assets/the_life_assets/crops/banana/banana_stage3_wilted.png
assets/the_life_assets/crops/banana/banana_stage4.png
assets/the_life_assets/crops/banana/banana_stage4_wilted.png
assets/the_life_assets/crops/cabbage/1x/cabbage_seed.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage1.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage1_wilted.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage2.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage2_wilted.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage3.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage3_wilted.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage4.png
assets/the_life_assets/crops/cabbage/1x/cabbage_stage4_wilted.png
assets/the_life_assets/crops/cabbage/cabbage_seed.png
assets/the_life_assets/crops/cabbage/cabbage_stage1.png
assets/the_life_assets/crops/cabbage/cabbage_stage1_wilted.png
assets/the_life_assets/crops/cabbage/cabbage_stage2.png
assets/the_life_assets/crops/cabbage/cabbage_stage2_wilted.png
assets/the_life_assets/crops/cabbage/cabbage_stage3.png
assets/the_life_assets/crops/cabbage/cabbage_stage3_wilted.png
assets/the_life_assets/crops/cabbage/cabbage_stage4.png
assets/the_life_assets/crops/cabbage/cabbage_stage4_wilted.png
assets/the_life_assets/crops/carrot/1x/carrot_seed.png
assets/the_life_assets/crops/carrot/1x/carrot_stage1.png
assets/the_life_assets/crops/carrot/1x/carrot_stage1_wilted.png
assets/the_life_assets/crops/carrot/1x/carrot_stage2.png
assets/the_life_assets/crops/carrot/1x/carrot_stage2_wilted.png
assets/the_life_assets/crops/carrot/1x/carrot_stage3.png
assets/the_life_assets/crops/carrot/1x/carrot_stage3_wilted.png
assets/the_life_assets/crops/carrot/1x/carrot_stage4.png
assets/the_life_assets/crops/carrot/1x/carrot_stage4_wilted.png
assets/the_life_assets/crops/carrot/carrot_seed.png
assets/the_life_assets/crops/carrot/carrot_stage1.png
assets/the_life_assets/crops/carrot/carrot_stage1_wilted.png
assets/the_life_assets/crops/carrot/carrot_stage2.png
assets/the_life_assets/crops/carrot/carrot_stage2_wilted.png
assets/the_life_assets/crops/carrot/carrot_stage3.png
assets/the_life_assets/crops/carrot/carrot_stage3_wilted.png
assets/the_life_assets/crops/carrot/carrot_stage4.png
assets/the_life_assets/crops/carrot/carrot_stage4_wilted.png
assets/the_life_assets/crops/chili/1x/chili_seed.png
assets/the_life_assets/crops/chili/1x/chili_stage1.png
assets/the_life_assets/crops/chili/1x/chili_stage1_wilted.png
assets/the_life_assets/crops/chili/1x/chili_stage2.png
assets/the_life_assets/crops/chili/1x/chili_stage2_wilted.png
assets/the_life_assets/crops/chili/1x/chili_stage3.png
assets/the_life_assets/crops/chili/1x/chili_stage3_wilted.png
assets/the_life_assets/crops/chili/1x/chili_stage4.png
assets/the_life_assets/crops/chili/1x/chili_stage4_wilted.png
assets/the_life_assets/crops/chili/chili_seed.png
assets/the_life_assets/crops/chili/chili_stage1.png
assets/the_life_assets/crops/chili/chili_stage1_wilted.png
assets/the_life_assets/crops/chili/chili_stage2.png
assets/the_life_assets/crops/chili/chili_stage2_wilted.png
assets/the_life_assets/crops/chili/chili_stage3.png
assets/the_life_assets/crops/chili/chili_stage3_wilted.png
assets/the_life_assets/crops/chili/chili_stage4.png
assets/the_life_assets/crops/chili/chili_stage4_wilted.png
assets/the_life_assets/crops/coffee/1x/coffee_seed.png
assets/the_life_assets/crops/coffee/1x/coffee_stage1.png
assets/the_life_assets/crops/coffee/1x/coffee_stage1_wilted.png
assets/the_life_assets/crops/coffee/1x/coffee_stage2.png
assets/the_life_assets/crops/coffee/1x/coffee_stage2_wilted.png
assets/the_life_assets/crops/coffee/1x/coffee_stage3.png
assets/the_life_assets/crops/coffee/1x/coffee_stage3_wilted.png
assets/the_life_assets/crops/coffee/1x/coffee_stage4.png
assets/the_life_assets/crops/coffee/1x/coffee_stage4_wilted.png
assets/the_life_assets/crops/coffee/coffee_seed.png
assets/the_life_assets/crops/coffee/coffee_stage1.png
assets/the_life_assets/crops/coffee/coffee_stage1_wilted.png
assets/the_life_assets/crops/coffee/coffee_stage2.png
assets/the_life_assets/crops/coffee/coffee_stage2_wilted.png
assets/the_life_assets/crops/coffee/coffee_stage3.png
assets/the_life_assets/crops/coffee/coffee_stage3_wilted.png
assets/the_life_assets/crops/coffee/coffee_stage4.png
assets/the_life_assets/crops/coffee/coffee_stage4_wilted.png
assets/the_life_assets/crops/corn/1x/corn_seed.png
assets/the_life_assets/crops/corn/1x/corn_stage1.png
assets/the_life_assets/crops/corn/1x/corn_stage1_wilted.png
assets/the_life_assets/crops/corn/1x/corn_stage2.png
assets/the_life_assets/crops/corn/1x/corn_stage2_wilted.png
assets/the_life_assets/crops/corn/1x/corn_stage3.png
assets/the_life_assets/crops/corn/1x/corn_stage3_wilted.png
assets/the_life_assets/crops/corn/1x/corn_stage4.png
assets/the_life_assets/crops/corn/1x/corn_stage4_wilted.png
assets/the_life_assets/crops/corn/corn_seed.png
assets/the_life_assets/crops/corn/corn_stage1.png
assets/the_life_assets/crops/corn/corn_stage1_wilted.png
assets/the_life_assets/crops/corn/corn_stage2.png
assets/the_life_assets/crops/corn/corn_stage2_wilted.png
assets/the_life_assets/crops/corn/corn_stage3.png
assets/the_life_assets/crops/corn/corn_stage3_wilted.png
assets/the_life_assets/crops/corn/corn_stage4.png
assets/the_life_assets/crops/corn/corn_stage4_wilted.png
assets/the_life_assets/crops/eggplant/1x/eggplant_seed.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage1.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage1_wilted.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage2.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage2_wilted.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage3.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage3_wilted.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage4.png
assets/the_life_assets/crops/eggplant/1x/eggplant_stage4_wilted.png
assets/the_life_assets/crops/eggplant/eggplant_seed.png
assets/the_life_assets/crops/eggplant/eggplant_stage1.png
assets/the_life_assets/crops/eggplant/eggplant_stage1_wilted.png
assets/the_life_assets/crops/eggplant/eggplant_stage2.png
assets/the_life_assets/crops/eggplant/eggplant_stage2_wilted.png
assets/the_life_assets/crops/eggplant/eggplant_stage3.png
assets/the_life_assets/crops/eggplant/eggplant_stage3_wilted.png
assets/the_life_assets/crops/eggplant/eggplant_stage4.png
assets/the_life_assets/crops/eggplant/eggplant_stage4_wilted.png
assets/the_life_assets/crops/orange/1x/orange_seed.png
assets/the_life_assets/crops/orange/1x/orange_stage1.png
assets/the_life_assets/crops/orange/1x/orange_stage1_wilted.png
assets/the_life_assets/crops/orange/1x/orange_stage2.png
assets/the_life_assets/crops/orange/1x/orange_stage2_wilted.png
assets/the_life_assets/crops/orange/1x/orange_stage3.png
assets/the_life_assets/crops/orange/1x/orange_stage3_wilted.png
assets/the_life_assets/crops/orange/1x/orange_stage4.png
assets/the_life_assets/crops/orange/1x/orange_stage4_wilted.png
assets/the_life_assets/crops/orange/orange_seed.png
assets/the_life_assets/crops/orange/orange_stage1.png
assets/the_life_assets/crops/orange/orange_stage1_wilted.png
assets/the_life_assets/crops/orange/orange_stage2.png
assets/the_life_assets/crops/orange/orange_stage2_wilted.png
assets/the_life_assets/crops/orange/orange_stage3.png
assets/the_life_assets/crops/orange/orange_stage3_wilted.png
assets/the_life_assets/crops/orange/orange_stage4.png
assets/the_life_assets/crops/orange/orange_stage4_wilted.png
assets/the_life_assets/crops/pepper/1x/pepper_seed.png
assets/the_life_assets/crops/pepper/1x/pepper_stage1.png
assets/the_life_assets/crops/pepper/1x/pepper_stage1_wilted.png
assets/the_life_assets/crops/pepper/1x/pepper_stage2.png
assets/the_life_assets/crops/pepper/1x/pepper_stage2_wilted.png
assets/the_life_assets/crops/pepper/1x/pepper_stage3.png
assets/the_life_assets/crops/pepper/1x/pepper_stage3_wilted.png
assets/the_life_assets/crops/pepper/1x/pepper_stage4.png
assets/the_life_assets/crops/pepper/1x/pepper_stage4_wilted.png
assets/the_life_assets/crops/pepper/pepper_seed.png
assets/the_life_assets/crops/pepper/pepper_stage1.png
assets/the_life_assets/crops/pepper/pepper_stage1_wilted.png
assets/the_life_assets/crops/pepper/pepper_stage2.png
assets/the_life_assets/crops/pepper/pepper_stage2_wilted.png
assets/the_life_assets/crops/pepper/pepper_stage3.png
assets/the_life_assets/crops/pepper/pepper_stage3_wilted.png
assets/the_life_assets/crops/pepper/pepper_stage4.png
assets/the_life_assets/crops/pepper/pepper_stage4_wilted.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_seed.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage1.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage1_wilted.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage2.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage2_wilted.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage3.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage3_wilted.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage4.png
assets/the_life_assets/crops/pumpkin/1x/pumpkin_stage4_wilted.png
assets/the_life_assets/crops/pumpkin/pumpkin_seed.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage1.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage1_wilted.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage2.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage2_wilted.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage3.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage3_wilted.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage4.png
assets/the_life_assets/crops/pumpkin/pumpkin_stage4_wilted.png
assets/the_life_assets/crops/radish/1x/radish_seed.png
assets/the_life_assets/crops/radish/1x/radish_stage1.png
assets/the_life_assets/crops/radish/1x/radish_stage1_wilted.png
assets/the_life_assets/crops/radish/1x/radish_stage2.png
assets/the_life_assets/crops/radish/1x/radish_stage2_wilted.png
assets/the_life_assets/crops/radish/1x/radish_stage3.png
assets/the_life_assets/crops/radish/1x/radish_stage3_wilted.png
assets/the_life_assets/crops/radish/1x/radish_stage4.png
assets/the_life_assets/crops/radish/1x/radish_stage4_wilted.png
assets/the_life_assets/crops/radish/radish_seed.png
assets/the_life_assets/crops/radish/radish_stage1.png
assets/the_life_assets/crops/radish/radish_stage1_wilted.png
assets/the_life_assets/crops/radish/radish_stage2.png
assets/the_life_assets/crops/radish/radish_stage2_wilted.png
assets/the_life_assets/crops/radish/radish_stage3.png
assets/the_life_assets/crops/radish/radish_stage3_wilted.png
assets/the_life_assets/crops/radish/radish_stage4.png
assets/the_life_assets/crops/radish/radish_stage4_wilted.png
assets/the_life_assets/crops/rice/1x/rice_seed.png
assets/the_life_assets/crops/rice/1x/rice_stage1.png
assets/the_life_assets/crops/rice/1x/rice_stage1_wilted.png
assets/the_life_assets/crops/rice/1x/rice_stage2.png
assets/the_life_assets/crops/rice/1x/rice_stage2_wilted.png
assets/the_life_assets/crops/rice/1x/rice_stage3.png
assets/the_life_assets/crops/rice/1x/rice_stage3_wilted.png
assets/the_life_assets/crops/rice/1x/rice_stage4.png
assets/the_life_assets/crops/rice/1x/rice_stage4_wilted.png
assets/the_life_assets/crops/rice/rice_seed.png
assets/the_life_assets/crops/rice/rice_stage1.png
assets/the_life_assets/crops/rice/rice_stage1_wilted.png
assets/the_life_assets/crops/rice/rice_stage2.png
assets/the_life_assets/crops/rice/rice_stage2_wilted.png
assets/the_life_assets/crops/rice/rice_stage3.png
assets/the_life_assets/crops/rice/rice_stage3_wilted.png
assets/the_life_assets/crops/rice/rice_stage4.png
assets/the_life_assets/crops/rice/rice_stage4_wilted.png
assets/the_life_assets/crops/strawberry/1x/strawberry_seed.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage1.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage1_wilted.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage2.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage2_wilted.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage3.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage3_wilted.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage4.png
assets/the_life_assets/crops/strawberry/1x/strawberry_stage4_wilted.png
assets/the_life_assets/crops/strawberry/strawberry_seed.png
assets/the_life_assets/crops/strawberry/strawberry_stage1.png
assets/the_life_assets/crops/strawberry/strawberry_stage1_wilted.png
assets/the_life_assets/crops/strawberry/strawberry_stage2.png
assets/the_life_assets/crops/strawberry/strawberry_stage2_wilted.png
assets/the_life_assets/crops/strawberry/strawberry_stage3.png
assets/the_life_assets/crops/strawberry/strawberry_stage3_wilted.png
assets/the_life_assets/crops/strawberry/strawberry_stage4.png
assets/the_life_assets/crops/strawberry/strawberry_stage4_wilted.png
assets/the_life_assets/crops/sunflower/1x/sunflower_seed.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage1.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage1_wilted.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage2.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage2_wilted.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage3.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage3_wilted.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage4.png
assets/the_life_assets/crops/sunflower/1x/sunflower_stage4_wilted.png
assets/the_life_assets/crops/sunflower/sunflower_seed.png
assets/the_life_assets/crops/sunflower/sunflower_stage1.png
assets/the_life_assets/crops/sunflower/sunflower_stage1_wilted.png
assets/the_life_assets/crops/sunflower/sunflower_stage2.png
assets/the_life_assets/crops/sunflower/sunflower_stage2_wilted.png
assets/the_life_assets/crops/sunflower/sunflower_stage3.png
assets/the_life_assets/crops/sunflower/sunflower_stage3_wilted.png
assets/the_life_assets/crops/sunflower/sunflower_stage4.png
assets/the_life_assets/crops/sunflower/sunflower_stage4_wilted.png
assets/the_life_assets/crops/tomato/1x/tomato_seed.png
assets/the_life_assets/crops/tomato/1x/tomato_stage1.png
assets/the_life_assets/crops/tomato/1x/tomato_stage1_wilted.png
assets/the_life_assets/crops/tomato/1x/tomato_stage2.png
assets/the_life_assets/crops/tomato/1x/tomato_stage2_wilted.png
assets/the_life_assets/crops/tomato/1x/tomato_stage3.png
assets/the_life_assets/crops/tomato/1x/tomato_stage3_wilted.png
assets/the_life_assets/crops/tomato/1x/tomato_stage4.png
assets/the_life_assets/crops/tomato/1x/tomato_stage4_wilted.png
assets/the_life_assets/crops/tomato/tomato_seed.png
assets/the_life_assets/crops/tomato/tomato_stage1.png
assets/the_life_assets/crops/tomato/tomato_stage1_wilted.png
assets/the_life_assets/crops/tomato/tomato_stage2.png
assets/the_life_assets/crops/tomato/tomato_stage2_wilted.png
assets/the_life_assets/crops/tomato/tomato_stage3.png
assets/the_life_assets/crops/tomato/tomato_stage3_wilted.png
assets/the_life_assets/crops/tomato/tomato_stage4.png
assets/the_life_assets/crops/tomato/tomato_stage4_wilted.png
assets/the_life_assets/decor/flower_0.png
assets/the_life_assets/decor/flower_0_1x.png
assets/the_life_assets/decor/flower_1.png
assets/the_life_assets/decor/flower_1_1x.png
assets/the_life_assets/decor/flower_2.png
assets/the_life_assets/decor/flower_2_1x.png
assets/the_life_assets/decor/flower_3.png
assets/the_life_assets/decor/flower_3_1x.png
assets/the_life_assets/decor/pebble_0.png
assets/the_life_assets/decor/pebble_0_1x.png
assets/the_life_assets/decor/pebble_1.png
assets/the_life_assets/decor/pebble_1_1x.png
assets/the_life_assets/decor/tuft_0.png
assets/the_life_assets/decor/tuft_0_1x.png
assets/the_life_assets/decor/tuft_1.png
assets/the_life_assets/decor/tuft_1_1x.png
assets/the_life_assets/decor/tuft_2.png
assets/the_life_assets/decor/tuft_2_1x.png
assets/the_life_assets/grass_clumps/1x/grass_clump_large_1.png
assets/the_life_assets/grass_clumps/1x/grass_clump_large_2.png
assets/the_life_assets/grass_clumps/1x/grass_clump_large_3.png
assets/the_life_assets/grass_clumps/1x/grass_clump_medium_1.png
assets/the_life_assets/grass_clumps/1x/grass_clump_medium_2.png
assets/the_life_assets/grass_clumps/1x/grass_clump_medium_3.png
assets/the_life_assets/grass_clumps/1x/grass_clump_small_1.png
assets/the_life_assets/grass_clumps/1x/grass_clump_small_2.png
assets/the_life_assets/grass_clumps/1x/grass_clump_small_3.png
assets/the_life_assets/grass_clumps/grass_clump_large_1.png
assets/the_life_assets/grass_clumps/grass_clump_large_2.png
assets/the_life_assets/grass_clumps/grass_clump_large_3.png
assets/the_life_assets/grass_clumps/grass_clump_medium_1.png
assets/the_life_assets/grass_clumps/grass_clump_medium_2.png
assets/the_life_assets/grass_clumps/grass_clump_medium_3.png
assets/the_life_assets/grass_clumps/grass_clump_small_1.png
assets/the_life_assets/grass_clumps/grass_clump_small_2.png
assets/the_life_assets/grass_clumps/grass_clump_small_3.png
assets/the_life_assets/machines/barrel/1x/barrel_idle.png
assets/the_life_assets/machines/barrel/1x/barrel_work_a.png
assets/the_life_assets/machines/barrel/1x/barrel_work_b.png
assets/the_life_assets/machines/barrel/barrel_idle.png
assets/the_life_assets/machines/barrel/barrel_work_a.png
assets/the_life_assets/machines/barrel/barrel_work_b.png
assets/the_life_assets/machines/dryer/1x/dryer_idle.png
assets/the_life_assets/machines/dryer/1x/dryer_work_a.png
assets/the_life_assets/machines/dryer/1x/dryer_work_b.png
assets/the_life_assets/machines/dryer/dryer_idle.png
assets/the_life_assets/machines/dryer/dryer_work_a.png
assets/the_life_assets/machines/dryer/dryer_work_b.png
assets/the_life_assets/machines/mill/1x/mill_idle.png
assets/the_life_assets/machines/mill/1x/mill_work_a.png
assets/the_life_assets/machines/mill/1x/mill_work_b.png
assets/the_life_assets/machines/mill/mill_idle.png
assets/the_life_assets/machines/mill/mill_work_a.png
assets/the_life_assets/machines/mill/mill_work_b.png
assets/the_life_assets/machines/oven/1x/oven_idle.png
assets/the_life_assets/machines/oven/1x/oven_work_a.png
assets/the_life_assets/machines/oven/1x/oven_work_b.png
assets/the_life_assets/machines/oven/oven_idle.png
assets/the_life_assets/machines/oven/oven_work_a.png
assets/the_life_assets/machines/oven/oven_work_b.png
assets/the_life_assets/machines/press/1x/press_idle.png
assets/the_life_assets/machines/press/1x/press_work_a.png
assets/the_life_assets/machines/press/1x/press_work_b.png
assets/the_life_assets/machines/press/press_idle.png
assets/the_life_assets/machines/press/press_work_a.png
assets/the_life_assets/machines/press/press_work_b.png
assets/the_life_assets/machines/roaster/1x/roaster_idle.png
assets/the_life_assets/machines/roaster/1x/roaster_work_a.png
assets/the_life_assets/machines/roaster/1x/roaster_work_b.png
assets/the_life_assets/machines/roaster/roaster_idle.png
assets/the_life_assets/machines/roaster/roaster_work_a.png
assets/the_life_assets/machines/roaster/roaster_work_b.png
assets/the_life_assets/machines/stove/1x/stove_idle.png
assets/the_life_assets/machines/stove/1x/stove_work_a.png
assets/the_life_assets/machines/stove/1x/stove_work_b.png
assets/the_life_assets/machines/stove/stove_idle.png
assets/the_life_assets/machines/stove/stove_work_a.png
assets/the_life_assets/machines/stove/stove_work_b.png
assets/the_life_assets/objects/bush.png
assets/the_life_assets/objects/bush_1x.png
assets/the_life_assets/objects/tree_fruit.png
assets/the_life_assets/objects/tree_fruit_1x.png
assets/the_life_assets/rocks/1x/rock_large_1.png
assets/the_life_assets/rocks/1x/rock_large_2.png
assets/the_life_assets/rocks/1x/rock_large_3.png
assets/the_life_assets/rocks/1x/rock_medium_1.png
assets/the_life_assets/rocks/1x/rock_medium_2.png
assets/the_life_assets/rocks/1x/rock_medium_3.png
assets/the_life_assets/rocks/1x/rock_small_1.png
assets/the_life_assets/rocks/1x/rock_small_2.png
assets/the_life_assets/rocks/1x/rock_small_3.png
assets/the_life_assets/rocks/rock_large_1.png
assets/the_life_assets/rocks/rock_large_2.png
assets/the_life_assets/rocks/rock_large_3.png
assets/the_life_assets/rocks/rock_medium_1.png
assets/the_life_assets/rocks/rock_medium_2.png
assets/the_life_assets/rocks/rock_medium_3.png
assets/the_life_assets/rocks/rock_small_1.png
assets/the_life_assets/rocks/rock_small_2.png
assets/the_life_assets/rocks/rock_small_3.png
assets/the_life_assets/tiles/layers/dirt_0.png
assets/the_life_assets/tiles/layers/dirt_1.png
assets/the_life_assets/tiles/layers/dirt_2.png
assets/the_life_assets/tiles/layers/dirt_3.png
assets/the_life_assets/tiles/layers/grass_0.png
assets/the_life_assets/tiles/layers/grass_1.png
assets/the_life_assets/tiles/layers/grass_2.png
assets/the_life_assets/tiles/layers/grass_3.png
assets/the_life_assets/tiles/layers/grass_4.png
assets/the_life_assets/tiles/layers/grass_5.png
assets/the_life_assets/tiles/layers/grass_flower_pink.png
assets/the_life_assets/tiles/layers/grass_flower_white.png
assets/the_life_assets/tiles/layers/path_0.png
assets/the_life_assets/tiles/layers/path_1.png
assets/the_life_assets/tiles/layers/path_2.png
assets/the_life_assets/tiles/layers/path_3.png
assets/the_life_assets/tiles/layers/sand_0.png
assets/the_life_assets/tiles/layers/sand_1.png
assets/the_life_assets/tiles/layers/sand_2.png
assets/the_life_assets/tiles/layers/sand_3.png
assets/the_life_assets/tiles/layers/tilled_dry_0.png
assets/the_life_assets/tiles/layers/tilled_dry_1.png
assets/the_life_assets/tiles/layers/tilled_dry_2.png
assets/the_life_assets/tiles/layers/tilled_dry_3.png
assets/the_life_assets/tiles/layers/tilled_wet_0.png
assets/the_life_assets/tiles/layers/tilled_wet_1.png
assets/the_life_assets/tiles/layers/tilled_wet_2.png
assets/the_life_assets/tiles/layers/tilled_wet_3.png
assets/the_life_assets/tiles/layers/water_0.png
assets/the_life_assets/tiles/layers/water_1.png
assets/the_life_assets/tiles/layers/water_2.png
assets/the_life_assets/tiles/layers/water_3.png
assets/the_life_assets/tiles/tileset/ground_atlas_128x64.png
assets/the_life_assets/tiles/tileset/ground_atlas_64x32.png
```

Tổng kiểm kê872 PNG trong assets:207 file có đường nạp runtime đã truy được (bao gồm21state máy,144 ảnh cây/seed,18đá-cỏ,atlas128,22sticker/tool icon vàtitle);665 file còn lại =16candidate +227 nguồn/legacy +422 nguồn lồng. Có consumer không đồng nghĩa file đang xuất hiện trong mọi frame hoặc mọi crop/máy đều đã mở bằng progression. Các scene/model3D archive không nằm trong phép đếm PNG này.

## Phụ lục D — discovery và số case GUT đã pass

Mọi script dưới đây nằm trong manifest của lượt full583/583, không chỉ trong tài liệu kế hoạch. Số case lấy từ discovery và được runner đối chiếu với summary từng process.

| Script | Số case | Kết quả lượt audit |
|---|---:|---|
| `tests/unit/test_audio_assets.gd` | 1 |PASS |
| `tests/unit/test_bag_upgrade.gd` | 5 |PASS |
| `tests/unit/test_bag_upgrade_flow.gd` | 3 |PASS |
| `tests/unit/test_bag_upgrade_screen.gd` | 2 |PASS |
| `tests/unit/test_camera_rig.gd` | 4 |PASS |
| `tests/unit/test_character_layout.gd` | 3 |PASS |
| `tests/unit/test_character_review_layout.gd` | 2 |PASS |
| `tests/unit/test_character_screen.gd` | 5 |PASS |
| `tests/unit/test_chibi_art_foundation.gd` | 5 |PASS |
| `tests/unit/test_chibi_characters.gd` | 7 |PASS |
| `tests/unit/test_chibi_farming.gd` | 4 |PASS |
| `tests/unit/test_chibi_ui.gd` | 3 |PASS |
| `tests/unit/test_chibi_world.gd` | 2 |PASS |
| `tests/unit/test_chicken_coop_callback_lifecycle.gd` | 4 |PASS |
| `tests/unit/test_chicken_coop_collection.gd` | 6 |PASS |
| `tests/unit/test_chicken_coop_collection_callbacks.gd` | 7 |PASS |
| `tests/unit/test_chicken_coop_feeding.gd` | 6 |PASS |
| `tests/unit/test_chicken_coop_feeding_callbacks.gd` | 7 |PASS |
| `tests/unit/test_chicken_coop_purchase.gd` | 8 |PASS |
| `tests/unit/test_chicken_coop_runtime.gd` | 5 |PASS |
| `tests/unit/test_chicken_coop_runtime_save.gd` | 4 |PASS |
| `tests/unit/test_chicken_coop_screen.gd` | 3 |PASS |
| `tests/unit/test_chicken_coop_state.gd` | 9 |PASS |
| `tests/unit/test_crop_balance.gd` | 4 |PASS |
| `tests/unit/test_crop_care.gd` | 7 |PASS |
| `tests/unit/test_crop_care_save.gd` | 4 |PASS |
| `tests/unit/test_crop_care_ui.gd` | 5 |PASS |
| `tests/unit/test_crop_economy_data.gd` | 3 |PASS |
| `tests/unit/test_crop_inspector.gd` | 6 |PASS |
| `tests/unit/test_crop_regrow.gd` | 5 |PASS |
| `tests/unit/test_crop_regrow_save.gd` | 4 |PASS |
| `tests/unit/test_crop_regrow_ui.gd` | 4 |PASS |
| `tests/unit/test_d72_animation.gd` | 3 |PASS |
| `tests/unit/test_d72_camera_input.gd` | 3 |PASS |
| `tests/unit/test_d72_locale_refresh.gd` | 3 |PASS |
| `tests/unit/test_d72_toolbar_selection.gd` | 3 |PASS |
| `tests/unit/test_d72_visual_review.gd` | 1 |PASS |
| `tests/unit/test_data_validator.gd` | 5 |PASS |
| `tests/unit/test_day_end_flow.gd` | 6 |PASS |
| `tests/unit/test_day_end_layout.gd` | 1 |PASS |
| `tests/unit/test_day_end_rollover.gd` | 2 |PASS |
| `tests/unit/test_day_end_save.gd` | 3 |PASS |
| `tests/unit/test_day_ledger_state.gd` | 5 |PASS |
| `tests/unit/test_day_night.gd` | 2 |PASS |
| `tests/unit/test_day_simulator.gd` | 2 |PASS |
| `tests/unit/test_drag_farming.gd` | 1 |PASS |
| `tests/unit/test_farm_grid_state.gd` | 2 |PASS |
| `tests/unit/test_farm_layout.gd` | 1 |PASS |
| `tests/unit/test_farm_view.gd` | 4 |PASS |
| `tests/unit/test_farming_review_layout.gd` | 1 |PASS |
| `tests/unit/test_full_year_economy_simulation.gd` | 1 |PASS |
| `tests/unit/test_game_clock.gd` | 13 |PASS |
| `tests/unit/test_game_feel.gd` | 2 |PASS |
| `tests/unit/test_grid_math.gd` | 3 |PASS |
| `tests/unit/test_harvest.gd` | 2 |PASS |
| `tests/unit/test_hotbar_layout.gd` | 2 |PASS |
| `tests/unit/test_hotbar_panel.gd` | 2 |PASS |
| `tests/unit/test_interaction_range.gd` | 5 |PASS |
| `tests/unit/test_inventory_actions.gd` | 5 |PASS |
| `tests/unit/test_inventory_screen.gd` | 6 |PASS |
| `tests/unit/test_inventory_state.gd` | 6 |PASS |
| `tests/unit/test_inventory_ui.gd` | 2 |PASS |
| `tests/unit/test_isometric_hud.gd` | 5 |PASS |
| `tests/unit/test_isometric_migration.gd` | 8 |PASS |
| `tests/unit/test_land_expansion.gd` | 8 |PASS |
| `tests/unit/test_land_runtime.gd` | 3 |PASS |
| `tests/unit/test_land_save.gd` | 2 |PASS |
| `tests/unit/test_land_screen.gd` | 2 |PASS |
| `tests/unit/test_localization.gd` | 3 |PASS |
| `tests/unit/test_machine_build_lifecycle.gd` | 9 |PASS |
| `tests/unit/test_machine_collection.gd` | 9 |PASS |
| `tests/unit/test_machine_move_request.gd` | 7 |PASS |
| `tests/unit/test_machine_move_ui.gd` | 3 |PASS |
| `tests/unit/test_machine_operation.gd` | 3 |PASS |
| `tests/unit/test_machine_placement.gd` | 10 |PASS |
| `tests/unit/test_machine_placement_request.gd` | 5 |PASS |
| `tests/unit/test_machine_placement_ui.gd` | 3 |PASS |
| `tests/unit/test_machine_presentation.gd` | 2 |PASS |
| `tests/unit/test_machine_screen.gd` | 2 |PASS |
| `tests/unit/test_machine_shop.gd` | 8 |PASS |
| `tests/unit/test_machine_state.gd` | 7 |PASS |
| `tests/unit/test_merchant_service.gd` | 3 |PASS |
| `tests/unit/test_morning_flow.gd` | 6 |PASS |
| `tests/unit/test_morning_layout.gd` | 3 |PASS |
| `tests/unit/test_move_dir.gd` | 2 |PASS |
| `tests/unit/test_npc_data_validation.gd` | 1 |PASS |
| `tests/unit/test_npc_quest_delivery.gd` | 3 |PASS |
| `tests/unit/test_npc_schedule.gd` | 2 |PASS |
| `tests/unit/test_npc_social_save.gd` | 3 |PASS |
| `tests/unit/test_npc_ui.gd` | 4 |PASS |
| `tests/unit/test_onboarding.gd` | 2 |PASS |
| `tests/unit/test_pause_layout.gd` | 3 |PASS |
| `tests/unit/test_pause_menu.gd` | 4 |PASS |
| `tests/unit/test_pause_settings.gd` | 6 |PASS |
| `tests/unit/test_player_restoration.gd` | 4 |PASS |
| `tests/unit/test_profile_creation.gd` | 5 |PASS |
| `tests/unit/test_profile_preview.gd` | 3 |PASS |
| `tests/unit/test_project_config.gd` | 2 |PASS |
| `tests/unit/test_quest_book.gd` | 5 |PASS |
| `tests/unit/test_quest_book_layout.gd` | 3 |PASS |
| `tests/unit/test_recipe_catalog_validation.gd` | 8 |PASS |
| `tests/unit/test_recipe_economy.gd` | 8 |PASS |
| `tests/unit/test_recipe_validator_cli.gd` | 3 |PASS |
| `tests/unit/test_save_service.gd` | 5 |PASS |
| `tests/unit/test_seasons.gd` | 2 |PASS |
| `tests/unit/test_seed_shop.gd` | 3 |PASS |
| `tests/unit/test_shipping_bin.gd` | 2 |PASS |
| `tests/unit/test_smoke.gd` | 1 |PASS |
| `tests/unit/test_starter_seeds_and_quest.gd` | 2 |PASS |
| `tests/unit/test_title_flow.gd` | 6 |PASS |
| `tests/unit/test_title_layout.gd` | 3 |PASS |
| `tests/unit/test_tool_action.gd` | 2 |PASS |
| `tests/unit/test_tutorial_quest_and_debug.gd` | 3 |PASS |
| `tests/unit/test_ui_components.gd` | 4 |PASS |
| `tests/unit/test_ui_gallery.gd` | 2 |PASS |
| `tests/unit/test_ui_layout.gd` | 3 |PASS |
| `tests/unit/test_ui_mouse.gd` | 5 |PASS |
| `tests/unit/test_ui_theme.gd` | 3 |PASS |
| `tests/unit/test_wallet_state.gd` | 4 |PASS |
| `tests/unit/test_water_source_config.gd` | 6 |PASS |
| `tests/unit/test_water_source_world.gd` | 3 |PASS |
| `tests/unit/test_watering_can_state.gd` | 4 |PASS |
| `tests/unit/test_watering_can_upgrade.gd` | 5 |PASS |
| `tests/unit/test_watering_hud.gd` | 3 |PASS |
| `tests/unit/test_watering_refill.gd` | 5 |PASS |
| `tests/unit/test_watering_runtime.gd` | 4 |PASS |
| `tests/unit/test_watering_runtime_save.gd` | 4 |PASS |
| `tests/unit/test_watering_service.gd` | 4 |PASS |
| `tests/unit/test_watering_upgrade_flow.gd` | 5 |PASS |
| `tests/unit/test_watering_upgrade_ledger.gd` | 3 |PASS |
| `tests/unit/test_watering_upgrade_screen.gd` | 3 |PASS |
| `tests/unit/test_weather.gd` | 4 |PASS |
| `tests/unit/test_weather_daily_state.gd` | 10 |PASS |
| `tests/unit/test_weather_profile_validation.gd` | 9 |PASS |
| `tests/unit/test_weather_rollover_guard.gd` | 5 |PASS |
| `tests/unit/test_weather_rolls.gd` | 5 |PASS |
| `tests/unit/test_weather_runtime_save.gd` | 6 |PASS |
| `tests/unit/test_weather_snapshot_codec.gd` | 13 |PASS |
| `tests/unit/test_world_presentation.gd` | 5 |PASS |
| `tests/unit/test_world_review_layout.gd` | 1 |PASS |

## Phụ lục E — ảnh runtime đã xem trực tiếp

Các file sau nằm tại `C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/`, được ghi mới trong lượt test audit18/11/2026. Đã xem overview00 và cả15 ảnh tham chiếu, rồi xem các runtime capture này; chưa xem tay mọi capture trong ma trận test. Ảnh không chụp từ editorF5 của người dùng.

- [iso8a_vi_latest_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso8a_vi_latest_1152.png>)
- [iso8b_vi_choice0_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso8b_vi_choice0_1152.png>)
- [d72_c1_vi_1152_zoom1.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/d72_c1_vi_1152_zoom1.png>)
- [d72_c1_vi_night_rain.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/d72_c1_vi_night_rain.png>)
- [iso9_vi_complete_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso9_vi_complete_1152.png>)
- [iso5_vi_partial_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso5_vi_partial_1152.png>)
- [iso10_vi_mixed_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso10_vi_mixed_1152.png>)
- [iso11_vi_active_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso11_vi_active_1152.png>)
- [phase65c_vi_1152_shop.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/phase65c_vi_1152_shop.png>)
- [npc_dialogue_vi_1152x648.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/npc_dialogue_vi_1152x648.png>)
- [iso4_vi_manual_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso4_vi_manual_1152.png>)
- [iso7_vi_tab1_1152.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/iso7_vi_tab1_1152.png>)
- [ui_gallery_vi_1152_top.png](<C:/Users/daova/AppData/Local/Temp/the_life_test_appdata/Godot/app_userdata/game godot/ui_gallery_vi_1152_top.png>)

Ảnh dialogue có GUT panel che bên phải; hạn chế được ghi trong UI-12 và rủi ro. Chưa có capture cho09/11 vì không có screen tương ứng; không dùng ảnh mockup làm bằng chứng runtime.


## Phụ lục F — truy vết đầy đủ nhóm mục tiêu master

Bảng này ánh xạ các đặc tả S/F và tiêu chí khai thác E về sổ200 mục; không cộng các tiêu chí con thêm lần nữa vào mẫu số. Quyết định đã superseded (3D, Jolt, không chết cây...) được giữ làm lịch sử và chỉ rõ trong phần mâu thuẫn, không tự yêu cầu khôi phục.

| Đặc tả master | Mục đối chiếu / phần thiếu đã ghi |
|---|---|
| S01 Input | 0.2; DESIGN-1/2/3; bảng phím§7 |
| S02 Player/camera | 1.1–1.4; DESIGN-1/2; D62 |
| S03 Grid/occupancy | 0.3;6.2–6.3; ISO-1 |
| S04 Interactable/celltarget | 1.5;4.3; DESIGN-1 |
| S05 GameClock | 2.1–2.3;4.5;7.1b |
| S06 Inventory/item/hotbar | 3.1–3.3; ISO-5;6.5g;11.5 cho metadata quality |
| S07 ToolAction/animation hit | 4.3 PARTIAL, ISO-18 shovel; finitewater6.5h2b |
| S08 Farming/care/season/regrow | 4.1–4.4; ISO-6/15/18; CROP-STAGES/PERENNIAL |
| S09 Economy/saturation/orders | 5.1–5.6; UI-OWNERS DOC_ONLY |
| S10 Machine/due time/cancel | 6.1/D57/6.5b; MASTER-JOBCANCEL; days_remaining khác total_minutes |
| S11 Building/uid/return/refund/land | 6.2–6.5f;6.4a/b; MASTER-GENERICBUILDINGS |
| S12 Weather/seasonweights/unlock | 7.1a/b; MASTER-SEASONALWEATHER;7.6 |
| S13 Ecology | 7.3;7.4 |
| S14 Director/events/cooldown/trace | 7.5;11.3; M11 |
| S15 NPC/dialogue/quest/friendship/gift | 8.1–8.4; UI-07/12;8.6/11.6; gifting/birthdays chưa có |
| S16 Saves/codec/backup/recovery | 4.6; MASTER-SAVE-RECOVERY; các save6.4b/water/coop/weather |
| S17 UI/HUD/menu |ISO-2–11/13/16; UI-01…15; không fake state |
| S18 Audio/bus/regions/weather | 7.2; C5/M8;9.2 |
| S19 Localization | 3.4; D72-C4;11.10;§8.2 |
| S20 Settings/accessibility | 9.4;11.8; M14; UI-14 |
| S21 Dog | 8.5; art-only C1 không tính follow/name |
| S22 Animals/egg/crafting | 6.6a–d; MASTER-PRODUCTIONCHAIN ghi recipe trứng chưa có |
| S23 Fishing/foraging | 11.4; Master7regions |
| S24 Debug/cheats/overlay | 0.6;2.3; DESIGN-3; thiếu console/trace/ecology/occupancy overlay đầy đủ |
| S25 Async social | 10.1–10.6; GateB |
| S26 Onboarding | 9.1; M12; thư bà/storybeat còn thiếu |
| S27 Notebook/collections/achievements | 7.6;11.4/11.8; M12; UI-08 |
| S28 Optional analytics |MASTER-S28, chủ động chưa thêm |
| F0 Layers |§8.4; UI-OWNERS/LOG-UTILITY; DataRegistry/GameClock coupling |
| F1 Boot |ISO-8a/b; title/save/new/load runtime; SPEC manager creation chưa áp dụng |
| F2 Action | 4.3/4.4; animationhit thiếu; tool/nước thật có |
| F3 Day order | 4.5;6.6d;7.1b; ecology/economyorders/director chưa nối vì chưa có owner |
| F4 One-day playerloop |Core farming/economy/day-end/morning; phần story/forage/ambient còn thiếu |
| F5 Save/load | 4.6/MASTER-SAVE-RECOVERY; version12, atomic writes nhưng chưa backupfallback |
| F6 Atomic trade | 5.1/5.2; NPC/machine/land/bag/water/coop tests; service authority còn sai tên/ownership |
| F7 Director decision | 7.5 NOT_STARTED |
| F8 Quest/dialogue | 8.1/8.2; UI-08/12; không suy1deliveryquest thành campaign |
| F9 Buildmode | 6.3/6.5e/f; MASTER-GENERICBUILDINGS |
| F10 Onboarding data beats | 9.1/M12 PARTIAL |
| F11 Human+agent workflow |P-1/3, M0, Gitpending, GateA/B; nhiều phạm vi chưa commit |
| F12 Error/recovery |Save/weather/animal invalid-codec tests có; Log và backuprecovery chưa đủ |
| Master8.6 Valley development |Ecology/campaign/community chưa có; bao phủ bởi7.3/8.6/10.4/11.7 |
| Master10 art, pipeline, license |C0–C6; ISO-12–18; M0;9.3;12.4; asset§6 |
| Master11–12 tools/process/human |P-1–3/M0; lint chưa tìm trên PATH; GateA/B chưa có biên bản |
| Master14 templates |AGENTS/rules/contracts/API/PROGRESS tồn tại; template không phải feature gameplay |
| Master15 risks/16QA |§10; M0/M15; MASTER-SOAK/COMPATIBILITY; GateA/B |
| Master17 social/18schedule/19checklists/20release | 10.x/11.x/12.x; kế hoạch thời gian/checklist không tính là thực hiện xong |
| Master21 starter/open questions/A1–A13 |P/0.x, M12, storyM2.1–M2.5, WOW,7regions, productionchain và target supersession |

| Tiêu chí khai thác master8.5 | Truy vết implementation/thiếu/giới hạn |
|---|---|
| E1 Mule/transfer | 10.2 chưa có social; không có luồng chuyển coin hiện tại, chưa có capped gift service |
| E2 Arbitrage | 5.2/5.6; giá cơ sở/merchant isolated có test, chợ người chơi chưa có |
| E3 Printingrecipes | 6.7 validator PASS, deliberate over-cap fixture fail đúng; giá thành phẩm hiện0 |
| E4 Dominantcrop | 5.2/5.3 PARTIAL; thiếu saturation/order rotation, có mùa/cap dữ liệu |
| E5 Stockpiledorders | 5.3 NOT_STARTED; chưa có OrderTemplate reward formula |
| E6 Offlinepenalty |D03/D57 không maintenance/breakage; máy giữ buffer, offlinecatchup chưa có |
| E7 Inflation/repeatingsinks | 6.4/6.5 có tier đầu; thiếu sink lặp/decor/festival/endgame,11.6/11.7 |
| E8 Communitycaps | 10.4 NOT_STARTED |
| E9 Mail/crashdupe | 10.2 NOT_STARTED; chưa escrow/server idempotency |
| E10 Clockediting |MVP không catch-up;11.1 chưa làm clockrewind/cap; socialserver chưa có |
| E11 PositiveEV loot |Không có loot/gacha trong MVP theo D05; không tự thêm tính năng vốn bị loại |
| E12 Doubleharvest | 4.4 test_harvest/test_crop_regrow, fullbag giữ cây; đúng owner path |
| E13 Savereroll | 7.1b có savedforecast/golden; orders/director chưa có để chứng nhận toàn bộ3hệ |
| E14 UIrace |Nhiều transaction/reentry test máy/gà/upgrade có;3.3dragdrop chưa có và InventoryService DOC_ONLY |
| E15 Overflow/negative |Inventory/Weather/Coop/Land/Recipe numeric tests có;4.6 fuzz envelope tổng quát chưa có, không khẳng định mọi input đều fuzz-tested |
| E16 NPCbuy/sellloop | 5.2 validator/seedshop/merchant có guard giá;5.6 còn thiếu sim các chiến lược/chuỗi đầy đủ |
| E17 Sleepfastforward |Day-end/weather/coop once-per-day có test; orderrefresh/saturation chưa có, không coi ngủ là exploit bị cấm |
| E18 Editsave |Single-player local-authoritative được D04 chấp nhận;10.x server không tin client save chưa triển khai |
