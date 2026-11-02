# PROMPT: Chuyển The Life sang 2D isometric + dựng giao diện theo mockup

Đọc AGENTS.md, PROJECT_RULES.md, ARCHITECTURE.md, ROADMAP.md trước.
Chỗ nào ghi "AI đề xuất" thì tự chọn và ghi vào DECISIONS.md.
Chỗ nào còn trống hoặc mâu thuẫn thì HỎI người dùng trước khi làm.
Model/sprite thật người dùng sẽ bổ sung sau, vì vậy luôn dùng placeholder và không để logic phụ thuộc asset.

## 0. Tài liệu tham chiếu giao diện
Người dùng có 15 mockup (1152×648). Hãy yêu cầu người dùng đặt chúng vào `docs/ui_reference/` với tên:
01_menu_chinh, 02_tao_nhan_vat, 03_ingame_ban_ngay, 04_ingame_dem_mua, 05_ban_tin_sang,
06_tui_do, 07_nhan_vat, 08_so_nhiem_vu, 09_lich_su_kien, 10_cua_hang, 11_nang_cap_nha,
12_hoi_thoai, 13_ket_thuc_ngay, 14_tam_dung_cai_dat, 15_ui_kit, và ảnh tổng quan 00_overview.
Mockup là ảnh tham chiếu để dựng lại bằng node Godot, KHÔNG dùng ảnh mockup làm asset trong game.
Nếu chưa có file thì ghi vào PROGRESS.md là đang chờ, đừng đoán.

## 1. Quyết định nền tảng (ghi DECISIONS.md, cập nhật ARCHITECTURE.md và ROADMAP.md)
- Game là 2D isometric. Bỏ Camera3D, Jolt, yaw/pitch, mọi node 3D.
- Ô lưới 64×32 px (hình thoi). TileMapLayer, tile_shape = Isometric, y_sort_enabled = true.
  Dùng map_to_local() / local_to_map(); không tự viết công thức riêng.
- FarmGridState lưu bằng Dictionary Vector2i -> dữ liệu ô, KHÔNG phụ thuộc TileMapLayer (TileMapLayer chỉ để hiển thị).
- Lớp thế giới: Ground, Farmland, Objects (y-sort), Highlight (ô đang trỏ).
- Player: CharacterBody2D + Camera2D, WASD + Shift theo InputMap hiện có.
  Hướng đi theo màn hình, thành phần dọc nhân 0.5 cho khớp góc isometric; đi chéo vẫn chuẩn hóa.
- Giữ 8 collision layer (đặt lại tên ở 2D physics layers).
- Chọn ô bằng chuột: get_global_mouse_position() rồi local_to_map().
- Placeholder: TileSet và sprite sinh bằng code hoặc PNG đơn giản.
- Độ phân giải thiết kế 1152×648. Project Settings: stretch mode = canvas_items, aspect = keep.
  Mọi UI dùng anchor/container, không đặt vị trí pixel cứng.

## 2. Hệ thống giao diện (theo mockup)

### 2.1 Design tokens (lấy từ 15_ui_kit)
| Token | Hex | Dùng cho |
|---|---|---|
| ink (viền nâu) | #3A2412 | viền, chữ đậm |
| wood | #BC8340 | khung gỗ, nút phụ |
| paper | #F5E3B0 | nền giấy kem |
| green | #5FB230 | nút chính (Tiếp tục, Mua, Sang ngày mới) |
| yellow | #F7BC32 | nút nhấn (Nhận quà, Cài đặt) |
| red | #D6453A | nút nguy hiểm (Thoát, Vứt), băng rôn đỏ |
| sky | #6FB7F0 | nút Nâng cấp, thanh kinh nghiệm, thẻ thời tiết mưa |
| coin | #FFD25A | xu |
Quy tắc từ kit: viền nâu đậm 3–4 px; bóng đổ xuống dưới (kiểu nút nổi);
chữ tiêu đề có viền nâu; icon 32×32, nét viền 1.8, tô 2 tông + 1 điểm sáng.
Nút bấm có 4 trạng thái: normal, hover, pressed, disabled (xám, chữ "Chưa đủ xu").

### 2.2 Font
Mockup gợi ý: tiêu đề Baloo 2 ExtraBold, nội dung Nunito SemiBold (đủ dấu tiếng Việt).
Hiện dự án đã có Open Sans. AI đề xuất: dùng Baloo 2 + Nunito theo mockup nếu license cho phép
(ghi vào CREDITS.md), giữ Open Sans làm fallback. Kiểm tra render đủ dấu tiếng Việt (ắ ặ ể ữ ự ...).
Chữ phụ nghiêng kiểu serif (câu trích, mẹo) cần 1 font serif nghiêng: AI đề xuất, ghi lại.

### 2.3 Theme và thành phần (đặt trong `ui/`)
- `ui/theme/the_life_theme.tres` là Theme duy nhất, gán cho root UI. Không override style rải rác trong từng scene.
- Khung 9-slice: NinePatchRect / StyleBoxTexture với margin 28 mỗi cạnh
  (góc giữ nguyên, cạnh lặp, giữa kéo giãn). Có 2 khung: khung gỗ (viền gỗ + giấy kem) và ô đồ vật.
  Chưa có PNG thì dùng StyleBoxFlat (bo góc, viền, bóng) làm placeholder, sau thay bằng texture mà không đổi scene.
- Scene tái sử dụng (mỗi cái 1 scene + script riêng, có test nếu có logic):
  `Panel_Wood`, `Banner` (băng rôn tiêu đề, màu xanh/đỏ/xanh dương), `Btn_Primary/Secondary/Danger/Accent`,
  `Btn_Round_HUD` (nút tròn có chữ phím B/J/K/M/Esc), `ItemSlot` (trống, có đồ + số lượng, chọn, khóa),
  `ProgressBar_Styled` (xanh lá / xanh dương / vàng), `Toggle_OnOff`, `Slider_Styled`, `HeartRow` (quý mến, 5 tim),
  `KeyHint` (ô phím E, Q, Esc...), `Pill` (Ngày 3, 1.240 xu), `Tag` (MỚI, CHÍNH), `CoinLabel`, `TabBar` (tab cặp Q/E).
- Tạo `ui/ui_gallery.tscn` hiển thị tất cả thành phần ở mọi trạng thái, để đối chiếu với 15_ui_kit bằng mắt.
- Icon: bảng icon trong 15_ui_kit (xu, tim, sét thể lực, mặt trời, mưa, trăng, cuốc, bình tưới, liềm, giỏ, cà rốt,
  cà chua, củ cải, ngô, bí ngô, gỗ, đá, rơm, túi, sổ nhiệm vụ, lịch, bản đồ, quầy chợ, quà). Dùng tên file
  `assets/ui/icons/ic_<tên>.png` 32×32. Chưa có file thì placeholder hình tròn có chữ cái đầu và ghi vào danh sách thiếu asset.

### 2.4 Quy tắc kiến trúc UI
- UI chỉ hiển thị và phát tín hiệu. KHÔNG chứa logic game. Dữ liệu đọc từ state/autoload; hành động đi qua `events.gd`.
- Mọi chuỗi hiển thị qua `tr()` với bảng dịch tiếng Việt (CSV), không hardcode trong scene.
- Màn hình chặn nhập liệu của thế giới khi mở (pause/inventory/shop), dùng InputMap có sẵn; không thêm phím mới nếu chưa có trong INPUT_MAP.md.
- Phím trong mockup cần đối chiếu INPUT_MAP.md: B túi đồ, J nhiệm vụ, K lịch, M bản đồ, Esc tạm dừng,
  1–8 thanh công cụ, E tương tác (trong menu, Q/E đổi tab), F cất nhanh, Z sắp xếp, T ghim nhiệm vụ.
  Phím nào chưa có thì HỎI người dùng, đừng tự thêm.

## 3. Bố cục HUD trong game (03 và 04)
- Trên trái: tờ nhiệm vụ ghim (nền giấy, tick, tiến độ x/y, "Thưởng").
- Trên phải: bảng Thứ/ngày/mùa/năm + cung mặt trời + giờ; dưới là ô xu; dưới nữa là thẻ "Sự kiện".
- Phải: thanh thể lực dọc.
- Dưới giữa: thanh công cụ 8 ô (số phím 1–8), nhãn tên công cụ đang chọn phía trên.
- Dưới trái: 5 nút tròn B J K M Esc; phía trên là toast ("+3 Cà rốt", "Xong: ..."), tối đa 2 toast xếp chồng.
- Trong thế giới: nhãn tên nhà, bong bóng "E · Cuốc đất" gần vật có thể tương tác, bong bóng giọt nước trên ô cần tưới.
- Ban đêm/mưa (04): thế giới tối đi (CanvasModulate), cửa sổ nhà sáng, hạt mưa, HUD giữ nguyên.
  Làm sau, khi có thời tiết; chỉ chừa chỗ gắn.

## 4. Quy ước thời gian suy ra từ mockup (AI đề xuất, ghi DECISIONS.md, cần người dùng xác nhận)
- 1 tuần = 7 ngày, bắt đầu từ Thứ Hai (T2..CN). Ngày 1 là Thứ Hai nên ngày 3 là Thứ Tư.
- 1 mùa = 28 ngày (lịch 4 hàng × 7). Mùa Xuân, Năm 1. Giờ thức dậy 6:00 sáng.
- Cây không được tưới 2 ngày liên tiếp thì héo ("Quên 1 ngày nữa là cây sẽ héo!"). Mưa thì cây tự được tưới.
- Cà rốt lớn 3 ngày, cà chua 5 ngày (thu nhiều lần), củ cải 4 ngày, ngô 7 ngày (mở ở nhà cấp 2).
- Giá hạt: cà rốt 20, cà chua 35, củ cải 25, phân bón 15. Giá bán cà rốt 35, củ cải 45.
  Các con số này chỉ là dữ liệu mẫu trong mockup: đặt trong CropData (resource), không hardcode, và hỏi người dùng nếu muốn khác.

## 5. Thứ tự thực hiện
1. Chuyển nền tảng sang 2D theo mục 1. Giữ autoload, InputMap, GUT, font. Chạy test headless và main scene headless.
2. UI nền: theme, font, các thành phần mục 2.3, `ui_gallery.tscn`. Hỏi người dùng các điểm trống trước khi làm.
3. HUD cơ bản (mục 3): ô xu, giờ/ngày, thể lực, thanh công cụ, toast. Dữ liệu thật từ GameClock/InventoryState (làm kèm bước 4).
4. GameClock + ngủ sang ngày mới + màn hình Kết thúc ngày (13): thu chi hôm nay, lợi nhuận, cảnh báo cây chưa tưới, nút "Sang ngày mới".
   Các phần chưa có hệ thống (thời tiết, sự kiện, nhiệm vụ) hiển thị trống hoặc ẩn, không giả số liệu.
5. InventoryState + màn Túi đồ (06): lưới 8×5, lọc theo loại, chi tiết vật phẩm, Ăn / Cất vào ô / Vứt.
6. CropData -> FarmGridState -> cuốc, gieo, tưới -> cây lớn theo ngày -> thu hoạch vào kho.
7. Save/load MVP + màn Tạm dừng & Cài đặt (14) nối với settings.gd và save_service.gd.
Mỗi bước có test GUT, chạy lại toàn bộ test, cập nhật PROGRESS.md, DECISIONS.md, API_INDEX.md.

## 6. Chưa làm ở giai đoạn này (đặt vào ROADMAP.md)
01 Menu chính, 02 Tạo nhân vật, 05 Bản tin sáng, 07 Nhân vật (kỹ năng, quan hệ), 08 Sổ nhiệm vụ,
09 Lịch & Sự kiện, 10 Cửa hàng, 11 Nâng cấp nhà, 12 Hội thoại.
Chỉ dựng khi hệ thống tương ứng (thời tiết, NPC, nhiệm vụ, cửa hàng, nâng nhà) đã có logic.
Dùng lại khung tab chung của 06–09 (5 tab: Túi đồ, Nhân vật, Nhiệm vụ, Lịch & Sự kiện, Bản đồ; Q/E đổi tab) ngay từ màn Túi đồ.

## 7. Điểm cần hỏi người dùng trước khi làm
- Dùng Baloo 2 + Nunito như mockup, hay giữ Open Sans?
- Người dùng có file PNG gốc của icon/khung không, hay để AI vẽ placeholder bằng StyleBoxFlat?
- Xác nhận ô 64×32 và độ phân giải thiết kế 1152×648.
- Xác nhận quy ước thời gian ở mục 4 và các phím ở mục 2.4 chưa có trong INPUT_MAP.md.
