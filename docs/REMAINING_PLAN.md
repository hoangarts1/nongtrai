# Kế hoạch hoàn tất phần còn lại của THE LIFE

**APPROVED2026-11-20: owner chose the recommended whole33package, simulation-owned missing balance, protected existing data/Player/legacy access, full gates and sequential commit/push.**

Baseline: `104290a48e49fbfa7641123508461bc56bf32f43`, master=origin/master sau8.6a-j. Full đã chạy ở batch trước:261scripts/1008of1008/101031assertions;4nhóm157.612/106.796/97.820/133.200s, pinned4.7.2. Không gọi lại test chỉ để lập kế hoạch.

Yêu cầu hiện tại: làm hết plan. Đề xuất một hợp đồng thực thi chung: làm tuần tự toàn bộ milestone dưới đây, full test/commit/push mỗi mốc, không cần xin lại cho từng nhóm10 khi vẫn nằm trong phạm vi đã duyệt. Các gate bên ngoài phải có bằng chứng thật; không dùng automation để tự đánh dấu playtest hay phát hành đã xong.

## 1. Những gì đã biết và không làm lại

- ISO/Phase0-8 có nhiều checkbox lịch sử chưa phản ánh code. Không dựng lại hệ đã có chỉ vì checkbox trống. Preserve nền2D/asset cây16/máy7, Player/chó, InputMap đã pin, bình/túi/gà/land, thời tiết/ecology/Director prototype, UI nhỏ, Sổ tay và save16.
- `docs/AUDIT_REPORT.md` là audit lịch sử trước các batch mới; không dùng NOT_STARTED cũ để phủ nhận8.5/8.6/7.3/7.5 đã có bằng chứng.
- Hai file prompt của người dùng (`the_life_prompt.md` deleted, `the_life_master_prompt.md` untracked) giữ nguyên và không commit.
- Giữ Player theo D62 và các phê duyệt8.5/8.6 mới nhất; mục manager/no-player cũ đã bị thay thế, không tự khởi động lại việc xóa nhân vật.
- Source: ROADMAP phần migration + bảngPhase0-12, Master4.3/4.5/7.4/7.5/8/16, PROJECT_RULES, API_INDEX/ARCHITECTURE/DATA_SCHEMA/DECISIONS và contracts hiện có.

## 2. Một quyết định thiết kế cần chốt để không phải dừng mỗi mốc

**Khuyến nghị: giao agent chốt thông số còn thiếu bằng mô phỏng trong DATA, lấy `parameters.csv` làm bộ khởi điểm, giữ giá/ID/cap đã khóa trừ khi có bằng chứng mô phỏng và quyết định cập nhật riêng.** Sử dụng art2D mẫu hiện có cho cơ chế chưa có art; finalart/tone là gate review thật. Áp dụng quyền legacy rõ ràng cho save<=16, không lấy quyền prototype cũ làm bằng chứng đã sửa công trình.

Tất cả số dưới đây là ĐỀ XUẤT, chưa thành dữ liệu game: hộp thư100; nhàcấp2/3=600/1800; kho riêng40ô=300; kênh1200; cối600; cầu8000; trạm12000; dọn nước4đoạn*100; vòi phun3x3=300. Không yêu cầu gỗ/đá giả khi chưa có hệ thu thập.

Xung đột thật: `data/recipes/mill_wheat_flour.tres` dùng2autumn_wheat và wheat hiện bán42; output đang0. Giá bột55 ở ví dụ Master Plan sẽ lỗ29. Ứng viên bột96/90phút cho8xu/giờ; bánh230 từ2bột/180phút cho38/3xu/giờ, dưới trần tier2=40. Máy mill hiện350, không thay thành600:600ở bảng này là chi phí dự án sửa cối. Không tự áp ví dụ starting200/kho24ô đè lên cấu hình hiện hành.

Các giá khác phải qua validator caps80/15-40-120, mô phỏng chiến lược/ngày đến mốc, nguyên tử/refund và anti-softlock. Bảng sơ bộ không phải báo cáo đã cân bằng toàn game.

## 3. ALLOW_LIST chung đề xuất

Chi tiết máy đọc: [allow-list.json](allow-list.json). Mỗi milestone chụp backup/HEAD/index/SHA save thật, ghi tập file chính xác trước sửa trong tập chung. Mốc đầu có [F01-exact-allow-list.json](F01-exact-allow-list.json); đây là kế hoạch, không phải các file đã thay đổi.

Cho phép scriptDATA/domain/view trong `scripts/**/*.gd(.uid)`, Resources trong `data/**/*.tres`, UI nhỏ trong `ui/**/*.{gd,gd.uid,tscn}`, test/helpers, tool/runner/contracts, localevi/en và tài liệu triển khai đã liệt kê. Chỉ thêm golden mới>16. Cho phép cấu hình input/settings/export có tài liệu và test; không đổi tùy tiện controls. Runner chỉ tách thêm nhóm tuần tự đủ test/ảnh/manifest nếu đo được cần, luôn180giây/child.

**Bảo vệ:** AGENTS/PROJECT_RULES/MasterPlan/mockups;addonsGUT;16golden hiện có;scene cũ trong `scenes/`;asset/font/license/3Darchive cũ;prompt riêng;save/settings/key thật. Không rename/xóa ID/signal/API hiện tại. New world scenes cần hợp đồng/tập file cụ thể; ưu tiên Node2D script-built như runtime hiện có.

**Test compatibility:** giữ mọi invariant, test âm, assertion và capture. Chỉ sửa các kỳ vọng thật sự bị spec mới thay thế (version/count/gating), dùng diff riêng, thêm test điều kiện cũ và mới; không đổi expected để giấu bug. Mỗi save bump thêm migration+golden và kiểm tra tất cả bản trước. Không pre-bump phiên bản cho tính năng chưa tồn tại.

## 4. Thứ tự thực thi và nghiệm thu

Các hàngF là công việc agent có thể triển khai khi có đặc tả/đầu vào; H là gate người thật/tài khoản/hạ tầng. Một hàng hoàn tất mới bắt đầu hàng kế tiếp. Bảng không nói các tính năng tương lai đang tồn tại.

| ID | Nguồn | Mục tiêu | Phụ thuộc |
|---|---|---|---|
| F01 | 0.6;5.1;AUDIT DOC_ONLY | Chủ sở hữu giao dịch và Log | 104290a |
| F02 | 8.6 clear_land;ISO14 | Dọn đất có lưu trạng thái | F01 |
| F03 | 8.1;8.3;8.6 meet_neighbors | An và Bác Lâm hoạt động thật | F02 |
| F04 | 8.6 ChapterI;UI11;6.5 | Sửa hộp thư/nhà và mở kho | F03 |
| F05 | 3.3;ISO5;6.5 | Túi kéo thả và thao tác vật phẩm | F04 |
| F06 | 5.2-5.6 | Giá bão hòa và bảng đơn hàng | F05 |
| F07 | 6.1;6.7;Master7.4 | Máy theo total_minutes và chuỗi thành phẩm | F06 |
| F08 | 8.6 M2.1;11.5 | M2.1 kênh và tưới tự động | F07 |
| F09 | 8.6 M2.2 | M2.2 cối xay và đơn An | F08 |
| F10 | 8.6 M2.3;9.2 | M2.3 cầu/khu đông/Minh | F09 |
| F11 | 8.6 M2.4;4.5W4;7.5 | M2.4 trạm/Cỗ máy Mùa | F10 |
| F12 | 8.6 M2.5;7.3-7.4 | M2.5 nước/sổ sinh thái/W2 | F11 |
| F13 | UI09;UI map;7.6 | Lịch và bản đồ đúng mockup | F12 |
| F14 | prompt keep stamina;ISO6;11.5 | Stamina/ăn và nâng cấp còn lại | F13 |
| F15 | 9.1;8.6;4.5W1-W5 | Onboarding và chuỗi WOW | F14 |
| F16 | 9.4;ISO7 | Cài đặt và trợ năng cơ bản | F15 |
| F17 | 9.2-9.3;4.7 | Hình/âm thanh nhất quán và giấy phép | F16 |
| F18 | 9.5;Master16.4;11.9 | Bug bash và5000ngày | F17 |
| F19 | 9.6 | Windows export và bộ bàn giao | F18 |
| H1 | 9.7;gates | GATE A/B và3-5người lạ | F19 |
| F20 | 10.1 | NetworkGateway/MockBackend | H1 |
| F21 | 10.2 | Tài khoản/mã bạn/quà | F20 |
| F22 | 10.3-10.4 | Thăm snapshot/dự án cộng đồng | F21 |
| F23 | 10.5-10.6 | Bảng vinh danh/report/xóa tài khoản | F22 |
| F24 | 11.2 | Bốn mùa/lễ hội | H1 (offline expansion branch; no live-backend dependency) |
| F25 | 11.3 | Thời tiết và15-25sự kiện | F24 |
| F26 | 11.4 | Câu cá/hái lượm/bộ sưu tập | F25 |
| F27 | 11.5 | Chất lượng/phân/đất/nhà kính | F26 |
| F28 | 11.6 | NPC6-8/trang phục/trang trí sâu | F27 |
| F29 | 11.7;4.3;4.5 | Chương III/W3/hậu game | F28 |
| F30 | 11.8-11.10 | Gamepad/achievements/localization/perf | F29 |
| F31 | 11.1;D03 | Offline progress tùy chọn | F30 |
| H2 | 12 | Beta và phát hành | F31 |

### F01 — Chủ sở hữu giao dịch và Log

TASK: Tạo Log và facade EconomyService/InventoryService; chuyển consumer runtime sang cùng giao dịch nguyên tử, ledger/reason, refund và guard. Giữ public API tương thích, giá/đồ/coin hiện tại; sửa tài liệu theo code thật.

ACCEPTANCE: Giao dịch thành công/thất bại/đầy túi/reentry/refund/restore; không lệch coin/item; toàn bộ test cũ và full launcher pass.

Nhóm phạm vi: `economy` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `refactor: unify guarded economy and inventory transactions`.

### F02 — Dọn đất có lưu trạng thái

TASK: Dọn debris bằng xẻng qua ID/ô thật, cập nhật va chạm và cảnh vật; không chặt cây trồng lâu năm hay xóa asset. Ghi nhận clear_land từ lệnh hoàn tất.

ACCEPTANCE: Chỉ mục tiêu hợp lệ trong tầm; một lần; reload không mọc lại; cancel/fail không đổi; cảnh vật/đồ/cây/chó/NPC đúng.

Nhóm phạm vi: `clearing` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add persistent safe scenery clearing`.

### F03 — An và Bác Lâm hoạt động thật

TASK: Đăng ký an/bac_lam, địa điểm, lịch, nhà và thoại Việt/Anh; dùng renderer/portrait mẫu 2D hiện có. Gặp qua tương tác thật mới ghi nhận, không lấy thấy NPC làm bằng chứng.

ACCEPTANCE: Bốn NPC đến đúng nơi/giờ, đường đi không qua vật cản, save/load/language; meet_neighbors chỉ sau đủ hai cuộc gặp.

Nhóm phạm vi: `neighbors` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add An and Lam schedules and story introductions`.

### F04 — Sửa hộp thư/nhà và mở kho

TASK: RepairConfig/State/Service + UI nhỏ; trả xu nguyên tử, sửa một lần; nhà cấp2/3 và kho chứa tách túi. Dùng cấp nhà thật thay hằng1 trong shop/máy. Giữ đồ/máy đã sở hữu.

ACCEPTANCE: Thiếu tiền/hủy/lặp/callback không mất xu; nhà/kho/flags tồn tại sau load; cảnh báo bố trí; ChươngI đủ10 mục tiêu chỉ khi đủ lệnh thật.

Nhóm phạm vi: `repairs` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: restore the mailbox house and storage`.

### F05 — Túi kéo thả và thao tác vật phẩm

TASK: Kéo/đổi/gộp/tách stack và gán hotbar qua InventoryService; không để UI sở hữu đồ. Hoàn thiện tier túi/bình đã chốt bằng DATA, không thu lại tiền bậc cũ.

ACCEPTANCE: Bảo toàn tổng đồ, full/invalid/stale/reentry; mouse/keyboard và52ô; oldsave/order/nhặt sản phẩm giữ nguyên.

Nhóm phạm vi: `inventory` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: complete guarded inventory interactions and upgrade tiers`.

### F06 — Giá bão hòa và bảng đơn hàng

TASK: Pressure theo item và ngày; công thức số nguyên, đơn seeded3/ngày, hạn1-3 ngày không phạt, thưởng trong trần. Shop/Minh/thùng bán dùng báo giá thật; không tạo lịch sử bán cũ. Có đơn khởi đầu thật qua An/hộp thư trước cầu; first_delivery giữ ID, nhận bằng chứng từ nguồn giao hàng đã đăng ký.

ACCEPTANCE: JSON continuation không reroll; reward một lần, đầy túi/thiếu đồ không mất; sim4-5chiến lược; UI hiển thị giá/trend có nguồn.

Nhóm phạm vi: `orders` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add saved saturation pricing and seeded orders`.

### F07 — Máy theo total_minutes và chuỗi thành phẩm

TASK: Công việc mới có finish_at_total_minutes, qua giờ/ngủ cùng quy tắc; job cũ giữ thời gian còn lại. Chốt giá7 đầu ra bằng sim, thêm bánh mì dùng bột, giữ ID cũ.

ACCEPTANCE: Không delta/timer cho job; boundary90/180phút và ngủ nhiều ngày; buffer/full/reentry; giá trị tăng thêm<=15/40/120 theo cấp.

Nhóm phạm vi: `production` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: complete timed production and balanced processed goods`.

### F08 — M2.1 kênh và tưới tự động

TASK: Dự án sửa kênh thực, thiết bị tưới3x3 trên đất sở hữu; cấp nước trước tăng trưởng trong DaySimulator. Dùng owner/occupancy hiện có, UI đặt/xoay/cất phù hợp.

ACCEPTANCE: Sửa trả tiền một lần; không tưới đất khóa; không trừ bình thủ công; không hai simulation paths; save/reload/season/dust đúng.

Nhóm phạm vi: `irrigation` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: restore the canal and enable bounded irrigation`.

### F09 — M2.2 cối xay và đơn An

TASK: Sửa cối là mốc truyện riêng, không coi mua máy là đã sửa. Nối công thức bột/bánh và đơn An thực, nhiệm vụ/readout theo điều kiện.

ACCEPTANCE: Chỉ unlock sau giao dịch sửa; chuỗi vào/ra/coin dùng dữ liệu thật; nhận thưởng một lần; trạng thái và read flags qua load.

Nhóm phạm vi: `mill` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: restore the mill and bakery progression`.

### F10 — M2.3 cầu/khu đông/Minh

TASK: Thêm khu ngoài vùng chơi cũ và cầu qua sông có dữ liệu/va chạm/đường NPC. NewGame mở Minh/khu/hạt theo mốc; save<=16 giữ quyền prototype cũ bằng entitlement riêng, không bịa đã sửa cầu.

ACCEPTANCE: Không xây rào/nước phủ farm/máy/vị trí cũ; không softlock; trước/sau sửa và migration đều đi được đúng quyền; Ctrl+M không kích hoạt M. Kiểm tra DAG: đơn hàng ChươngI khả dụng trước cầu; giữ turnip_delivery legacy, không tạo vòng ChươngI -> cầu -> Minh -> đơn đầu -> ChươngI.

Nhóm phạm vi: `bridge` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: restore the bridge and eastern region access`.

### F11 — M2.4 trạm/Cỗ máy Mùa

TASK: Sửa trạm nguyên tử, MomentData/W4 và cảnh2D mẫu; NewGame mở dự báo/Director sau mốc thật. Forecast nội bộ vẫn saved/seeded; quyền cũ không mất, không gọi prototype là đã hoàn thành truyện.

ACCEPTANCE: Director mặc định tắt trước mốc mới; bật đúng một lần sau sửa; lưu/tải không reroll/diễn lại; cancel/failed không unlock.

Nhóm phạm vi: `station` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: restore the station and production story gates`.

### F12 — M2.5 nước/sổ sinh thái/W2

TASK: Dọn các đoạn suối/ao có owner thật, tính water_clarity từ snapshot các vùng đã dọn, làm mượt như profile hiện có; cập nhật J/bản tin/VFX nước/trăng/đom đóm.

ACCEPTANCE: Không còn giá trị giả; unavailable khi chưa đo; ngày cập nhật đúng một lần; old baseline không replay; W2 một lần có save.

Nhóm phạm vi: `water_ecology` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: connect measured water restoration and ecology moments`.

### F13 — Lịch và bản đồ đúng mockup

TASK: Lịch28ngày, mùa/năm, deadline đơn/sự kiện thật; chỉ ba dự báo đã biết. Bản đồ đọc hình học, quyền đất, vị trí NPC/công trình/nguồn nước thật; mở K/M hiện có.

ACCEPTANCE: vi/en3sizes; không fake birthdays/forecasttuần/fasttravel; exact Ctrl+M; GUI input/focus/scroll và old modal regressions.

Nhóm phạm vi: `calendar_map` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add data-backed calendar and world map screens`.

### F14 — Stamina/ăn và nâng cấp còn lại

TASK: State stamina thật nếu chốt P4, ăn qua owner và UI hiện có; công cụ/hoàn tác cùng giao dịch; hoàn thiện các bậc nhà/túi/bình theo cấu hình. Không biến hết stamina thành chặn vòng trồng cơ bản.

ACCEPTANCE: Không âm/vượt max; ăn một lần/hủy không mất đồ; giá và lợi ích từ Resource; new/load/day/refund/busy và oldsave giữ nguyên.

Nhóm phạm vi: `stamina` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: complete gentle stamina food and upgrade integration`.

### F15 — Onboarding và chuỗi WOW

TASK: BeatData đọc hành động thật, hướng dẫn ngắn; hoàn tất chuỗi ChươngI đến trạm. Moment conditions/cờ đã xem/VFX/camera/nhạc dùng DATA, không ép lặp thư.

ACCEPTANCE: Hành trình thật từ ngày1 qua mọi mốc có autosave; W1/W2/W4/W5 chỉ đúng điều kiện; đo onboarding nhưng không gọi tự động là playtest người lạ.

Nhóm phạm vi: `onboarding` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: finish milestone-driven onboarding and slice moments`.

### F16 — Cài đặt và trợ năng cơ bản

TASK: UI scale/contrast/subtitle/reduced motion/focus và hint input thật; preferences riêng settings.cfg, áp dụng/hoàn tác nguyên tử. Làm nốt khung mockup có hệ thống hỗ trợ.

ACCEPTANCE: Không có nút chết/số giả; vi/en/longtext3sizes; native GUI/input/IME regression, live setting persists và game data không đổi.

Nhóm phạm vi: `accessibility` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: complete slice settings and accessibility`.

### F17 — Hình/âm thanh nhất quán và giấy phép

TASK: Kiểm kê asset runtime, hoàn thiện biểu diễn làng/rừng/công trình/chân dung bằng nguồn hợp lệ; giữ asset lịch sử. Placeholder phải được gắn trạng thái đúng, finalart chỉ xong khi duyệt.

ACCEPTANCE: CREDITS/manifest truy được nguồn; all16crops/7machines; không gridline cũ; cảnh/âm thanh theo khu/thời tiết; render matrix/visual review.

Nhóm phạm vi: `presentation` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: finish coherent slice presentation and asset credits`.

### F18 — Bug bash và5000ngày

TASK: Soak pureworld5000ngày,4-5strategy kinh tế, save qua mọi milestone, fuzzy/corrupt và UI native journey; đo cache/node/memory thay vì suy đoán FPS.

ACCEPTANCE: Không âm/NaN/dupe/reroll/softlock; single/grouped/JSON giống nhau; mọi golden cũ giữ byte; full pinned launcher180s/child.

Nhóm phạm vi: `verification` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `test: verify the complete offline slice and long-world invariants`.

### F19 — Windows export và bộ bàn giao

TASK: Tạo export preset/CLI đóng gói và install/readme/log/knownissues; dùng engine/template đúng bản. Template hiện chưa cài: chuẩn bị trước, cài/download cần chốt đầu vào.

ACCEPTANCE: Release export không debug Ctrl+M; output chạy được trên máy dev; máy sạch là mục nghiệm thu thật riêng, không gán PASS giả.

Nhóm phạm vi: `export` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `build: package a reproducible Windows vertical slice`.

### H1 — GATE A/B và3-5người lạ

TASK: Chủ dự án chạy F5/duyệt tone/art, nhờ3-5người chơi thật; agent chuẩn bị checklist/build/phiếu, đọc feedback, sửa blocker. Không tự nhắn người khác.

ACCEPTANCE: Có log/metrics/feedback thật và quyết định đạt gate; chưa có bằng chứng thì BLOCKED cho Phase10.

Nhóm phạm vi: `human_gate` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `Gate bên ngoài: không tạo commit giả để nói đã đạt.`.

### F20 — NetworkGateway/MockBackend

TASK: Chỉ sau GATE B: interface/DTO/versioned mock, offline-first, timeout/retry/idempotency contracts; không HTTP rải trong gameplay.

ACCEPTANCE: Không server vẫn chơi/lưu; không key/token trong repo; backend thực cần provider và cấu hình đã chốt.

Nhóm phạm vi: `network` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add an offline-safe network gateway and mock contracts`.

### F21 — Tài khoản/mã bạn/quà

TASK: Auth/friend code/inbox; phần thưởng và idempotency được kiểm chứng server, không tin client. Giới hạn và lỗi mạng từ Resource.

ACCEPTANCE: Crash/retry/duplicate/timeout không tạo quà; backend thật cần credentials server-side và deployment riêng; mock không tính là live secure.

Nhóm phạm vi: `social` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add guarded accounts friends and gift inbox`.

### F22 — Thăm snapshot/dự án cộng đồng

TASK: Snapshot JSON versioned chỉ đọc, cosmetic thiếu có placeholder; ledger dự án solo được, capped, hoàn thành một lần.

ACCEPTANCE: Không tải Resource/script từ save/network; concurrent claims/idempotency; offline/server-down; owner local không bị snapshot ghi đè.

Nhóm phạm vi: `community` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add safe farm visits and community projects`.

### F23 — Bảng vinh danh/report/xóa tài khoản

TASK: Leaderboard casual có validation server; report/filter; consent/privacy/delete/account lifecycle và graceful degradation. Policy pháp lý là draft phải duyệt.

ACCEPTANCE: Không client scores; quyền truy cập/retention/delete có test; không tự công bố policy hoặc gửi dữ liệu người chơi.

Nhóm phạm vi: `privacy` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: finish social safety privacy and deletion workflows`.

### F24 — Bốn mùa/lễ hội

TASK: Cây/hoạt động/trang trí/theo mùa và festival event data; giữ all16crops/ID, không khóa tiến độ vì đổi mùa.

ACCEPTANCE: Seeded/calendar/save/season edges đúng; rewards một lần; không phá perennial/regrow/greenhouse rules.

Nhóm phạm vi: `seasons` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: expand seasonal activities and festivals`.

### F25 — Thời tiết và15-25sự kiện

TASK: Mở rộng profile/event DATA có counterplay và báo trước; bảo toàn các dự báo đã lưu và các event cũ.

ACCEPTANCE: Simulation profiles/cooldown/grace/pity; không random punish; no-reroll; balance caps và UX explanation.

Nhóm phạm vi: `events` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: expand forecastable weather and living-world events`.

### F26 — Câu cá/hái lượm/bộ sưu tập

TASK: Domain/Resources và UI thật cho fishing/forage/collection; source nodes thu một lần, không reset-dupe khi reload.

ACCEPTANCE: Loại/season/time/seed/lure hợp lệ; đầy túi giữ vật; sell/rewards qua service và caps; save/resource limits.

Nhóm phạm vi: `gathering` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add persistent fishing foraging and collections`.

### F27 — Chất lượng/phân/đất/nhà kính

TASK: Soil/fertilizer/quality/greenhouse và tưới nâng cao theo DATA; migration cây cũ giữ tuổi/sản lượng; không hardcode bonus.

ACCEPTANCE: One day path; crop cap80 và recipe caps; không doublefertilize/refunddupe; winter và perennial có cách chơi tiếp.

Nhóm phạm vi: `soil` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add balanced soil quality and advanced cultivation`.

### F28 — NPC6-8/trang phục/trang trí sâu

TASK: Thêm nội dung lịch/quan hệ/NPC/outfit/decor thật bằng catalogue và placement. Không giả final portrait hay phát hành asset chưa rõ quyền.

ACCEPTANCE: Không kẹt đường; wardrobe/despawn/restore/pivots/occupancy và credits; full native/input/save tests.

Nhóm phạm vi: `content` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: expand neighbors outfits and decoration systems`.

### F29 — Chương III/W3/hậu game

TASK: Dự án quảng trường/lễ hội/cộng đồng, mục tiêu cá nhân và trạng thái cân bằng; Director chuyển maintenance, thế giới tiếp tục.

ACCEPTANCE: Một lần/không thưởng lặp; đủ điều kiện sinh thái/mốc thật; không softlocksolo; save qua kết thúc vẫn chơi.

Nhóm phạm vi: `endgame` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: complete the valley restoration and postgame`.

### F30 — Gamepad/achievements/localization/perf

TASK: Native controller navigation/remap, trợ năng hoàn chỉnh, achievements interface và text pass; profiling/graphics options. SDK/appID/hardware phải có trước tích hợp thực.

ACCEPTANCE: Không claim Steam achievement bằng mock; full diacritics/longtext; benchmark thật trên target và test hardware do người thực hiện.

Nhóm phạm vi: `platform` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: finish platform controls accessibility and localization`.

### F31 — Offline progress tùy chọn

TASK: Mặc định tắt cho đến khi chốt cap; nếu bật dùng cùng DaySimulator, giới hạn ngày, không sự kiện tiêu cực, phát hiện giờ lùi; không bỏ chế độ world-pauses mặc định.

ACCEPTANCE: Sleep/direct/offline cùng kết quả trong quyền đã chốt; không reroll/dupereward/clockrewind exploit; lưu versioned.

Nhóm phạm vi: `offline` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `feat: add opt-in bounded offline progress`.

### H2 — Beta và phát hành

TASK: Build candidate/store assets/trailer/draft notes; beta20-100người2-4tuần, không thêm feature. Thu phí/tài khoản/store/legal/công bố/gửi thư phải có đầu vào và duyệt phát hành cụ thể.

ACCEPTANCE: Có feedback/test máy sạch/quyền asset/chính sách thực; chỉ đánh dấu Release sau hành động phát hành và xác nhận thật.

Nhóm phạm vi: `release` cùng các adapter tích hợp/locale/test/docs trong ALLOW_LIST; danh sách file chính xác được chụp trước sửa. Commit đề xuất: `Gate bên ngoài: không tạo commit giả để nói đã đạt.`.

## 5. Địa điểm/gating đề xuất và bảo toàn save

- NPC An/Lâm: lịch Master7.4 (An7-18, Lâm8-17), homes/workshops và đường đi trong vùng hiện tại; toạ độ chính xác phải qua kiểm tra geometry/collider/route trước đăng ký Resource. Không bịa node path; hợp đồng scene/data được viết trước adapter.
- Khu đông/cầu/trạm nằm ở phần mở rộng ngoài vùng39x39 hiện tại, không rào lại farm/máy/Player cũ. Giếng/suối/ao và refill còn hoạt động. Camera/NPC bounds theo Resource, kiểm tra negativecells/all zoom.
- Save<=16 nhận quyền legacy cho prototype/đồ đang có, không tự nhận project đã sửa/readpageđãđọc. NewGame dùng progression mới; basic seeds/vòng trồng luôn có cách tiếp tục.
- Từng owner mới có serialize/deserialize đầu tiên. Từng integration bump save có golden mới; toàn bộ16golden cũ giữ byte, seed/forecast/job/máy/đồ/quan hệ/chó không reset hay mô phỏng bù.

**Chống vòng khóa tiến độ bắt buộc:** NewGame không được yêu cầu hoàn tất ChươngI rồi mới sửa cầu/mởMinh trong khi đơn đầu ChươngI lại chỉ thuộc Minh. Thêm đơn khởi đầu thật từ An/hộp thư trước cầu; giữ ID `first_delivery` và legacy `turnip_delivery`, mở rộng nguồn bằng DATA/receipt hợp lệ. Story không trả thêm thưởng. Test đường đi ngày1 -> đơn đầu -> ChươngI -> cầu là tiêu chí bắt buộc.

## 6. Những gate không thể tự coi là xong

1. PROJECT_RULES§17 yêu cầu người thật chạy manualeditor; GATE B/9.7 cần3-5người lạ và số liệu thật. Chưa có kết quả không vàoPhase10.
2. Inventory tại thời điểm lập kế hoạch: không có thư mục Godot export_templates đã cài, không có export_presets.cfg. Chuẩn bị preset/script trước; bản export thật cần template4.7.2 và test máy sạch. Không tự tải/cài phần mềm khi chưa chốt.
3. Online cần provider/project/server ownership/credentials đúng môi trường, caps/retention và duyệt deploy. Không dùng service_role trong game client, không ghi secrets vào repo, không coi MockBackend là server bảo mật.
4. SDK/appID/achievement/controllerhardware/legal final/store account/budget và quyền asset là đầu vào thật. Không tự tiêu tiền, publish, gửi thư hay tự tạo phản hồi playtest.
5. Beta20-100người2-4tuần và Release cần lịch/người/tài khoản, phê duyệt bản reviewable trước hành động bên ngoài. Optional offline catchup giữ off tới khi chốt cap; không đổi D03 ngầm.

## 7. Cách báo cáo và thực thi sau khi chốt

Mỗi hàng: exactfiles+backup -> DATA/domain/view -> focused/pure/native phù hợp -> fulllauncher đã pin (mỗi child180s) -> SHA/scope audit -> commit/push thường -> hash remote -> updatePROGRESS/API_INDEX. Báo kết quả thật, không đổi test/harness để giả PASS. Gặp bug ba lần sửa thất bại thì dừng đúng AGENTS để báo nguyên nhân; thiếu đầu vào thật thì hoàn tất phần chuẩn bị độc lập trước khi hỏi.

Đây là deliverable lập kế hoạch, không có code/test mới đã chạy. Logbaseline1008thuộc batch8.6a-j đã hoàn thành, không phải chứng nhận kế hoạch này đã làm xong. Nếu chốt quyền thiết kế cùng ALLOW_LIST, có thể triển khai liên tục các hàngF, chỉ dừng ở gate/đầu vào/thay đổi ngoài phạm vi thực sự.

Lý do cần chốt trước code: AGENTS§3 yêu cầu “plan first ... and wait for approval before coding”; §2.1 chỉ sửa trongALLOW_LIST, §2.2/§5 không tự đoán yêu cầu thiếu. Lệnh “làm hết plan” đã xác định mục tiêu, nhưng chưa chốt các giá/gating/protected-file exceptions trong gói này.


## Execution record

User approval recorded at D:/godot/game-godot-backups/finish-roadmap-run-20261120-093950/approval.txt. F01 pushed e4adabda3581ed2383c7d072da77bb8269315a82, full1023/1023. Current milestone: F02 under final verification. Only completed individual PROGRESS entries are automation-delivered. All future tasks remain planned; H1/H2 require external evidence.
