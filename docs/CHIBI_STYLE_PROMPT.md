# THE LIFE — PROMPT PHONG CÁCH CHIBI VÀ TỰ TẠO MODEL

_Dùng cùng `docs/MASTER_PROMPT.md`._

## PHẦN 0 — QUAN HỆ VỚI PROMPT TỔNG

Đọc `docs/MASTER_PROMPT.md`. Prompt này KẾ THỪA nó và chỉ THAY phong cách hình ảnh: câu “3D low-poly cách điệu” ở Phần 0 của prompt tổng thành “3D chibi dễ thương (mềm mại, tròn trịa, màu pastel ấm)”. Các yêu cầu đồ họa ở Phần 4 và Phần 5 của prompt tổng được thực hiện theo phong cách dưới đây; các mốc M2 đến M8 được làm theo thứ tự C0 đến C6 ở Phần 5 của prompt này. Logic game, dữ liệu, test, save, giao diện và âm thanh vẫn theo prompt tổng và đều do bạn tự làm.

Nếu M2 đến M8 đã làm theo phong cách khác: không vá chắp vá. Tạo tag pre-chibi, lập danh sách model đang có, tạo lại theo chibi, giữ nguyên ID, đường dẫn dữ liệu và hành vi để không phá logic và save.

Không bắt chước nhân vật, logo, bố cục, tên hay thiết kế cụ thể của bất kỳ game hay phim nào; chỉ dùng nguyên tắc chung của phong cách chibi. Mọi thiết kế là thiết kế gốc.

## PHẦN 1 — ART BIBLE

Viết vào `docs/ART_BIBLE.md` trước khi làm model; mọi model phải tuân theo.

Cảm giác chung: ấm áp, mềm mại, tròn trịa, vui mắt, như đồ chơi đặt trong diorama. Hình khối bo tròn, không cạnh sắc; mọi vật “mập”, chunky, nhận ra được bằng bóng đen (silhouette) ngay ở kích thước 64 px.

Tỉ lệ nhân vật: cao khoảng 2 đến 2,5 đầu; đầu chiếm 50 đến 55% chiều cao; thân nhỏ, tay chân ngắn, bàn tay tròn kiểu găng, bàn chân tròn. Chiều cao nhân vật khoảng 1,0 đơn vị so với ô lưới 1×1 (ghi hằng số vào data). Mọi vật khác tính theo nhân vật: cửa nhà cao khoảng 1,3 lần người, cây cao 2 đến 3 lần.

Khuôn mặt: mắt to, thấp và xa nhau, mống mắt đậm có 1 đến 2 điểm sáng (vật liệu không chịu ánh sáng nên không bị đổ bóng); miệng nhỏ; má hồng bằng mảng tròn mờ; lông mày đơn giản; không mũi hoặc mũi chấm nhỏ. Mắt, miệng là mesh nhỏ riêng để đổi biểu cảm.

Tóc: khối tròn chồng nhau, có 1 lọn vểnh; mỗi nhân vật một kiểu tóc và màu khác nhau.

Màu: pastel ấm, độ bão hòa vừa phải; bóng đổ nhuốm màu (tím hoặc xanh nhạt) thay vì đen; mỗi nhân vật có 1 màu chủ đạo và 1 phụ kiện đặc trưng để nhận ra từ xa. Bảng màu nằm trong `data/art/palette` và có bộ màu theo mùa.

Shader: toon mềm 2 đến 3 bậc, bóng nhuốm màu, rim light nhẹ, điểm sáng nhỏ trên vật bóng; viền (outline) kiểu inverted hull màu nâu đậm mỏng cho nhân vật, công cụ và vật tương tác chính; có công tắc “Viền” trong Cài đặt đồ họa để giữ FPS.

Hoạt họa: squash and stretch, nhún nhảy khi đi (đi như nhảy nhẹ), thở khi đứng, chớp mắt mỗi 3 đến 6 giây ngẫu nhiên, chuẩn bị động tác trước khi vung công cụ, dùng easing back và elastic cho tween. Không có chuyển động cứng hay giật.

Ngân sách tam giác: nhân vật tối đa 6.000; vật nhỏ 1.500; mỗi giai đoạn cây trồng 400; công trình 8.000; cây to 1.000 mỗi biến thể. Ghi số thật vào báo cáo.

Đặt tên: `assets/generated/models/<nhóm>/<id>.tscn` hoặc `.res`; ID khớp với ID trong data.

## PHẦN 2 — QUY TRÌNH TẠO MODEL BẰNG CODE

Dùng builder tham số trong `tools/art/chibi/`: `chibi_character` (đầu, thân, tay, chân, tóc, mắt, miệng, má, trang phục, phụ kiện), `prop_builder`, `crop_builder`, `building_builder`, `tree_builder`. Dựng bằng `SurfaceTool` / `ArrayMesh`, hoặc ghép primitive (`SphereMesh`, `CapsuleMesh`, `BoxMesh` bo tròn, `CylinderMesh`, `TorusMesh`), rồi lưu thành `.res` / `.tscn` để không tốn chi phí lúc chạy.

Khớp xoay bằng cây `Node3D` pivot (đầu, thân, tay trái, tay phải, chân trái, chân phải, phụ kiện) do `AnimationPlayer` dựng bằng code điều khiển; không dùng mesh skinning.

Biến thể theo seed: kiểu tóc, màu da, màu áo, kích cỡ cây, hoa. Người chơi chọn ngoại hình theo biểu mẫu mình đã điền (ít nhất 6 kiểu tóc, 6 tông da, màu tóc và màu áo tùy chỉnh).

Mỗi model PHẢI qua vòng kiểm tra hình ảnh: (1) dựng; (2) chạy `tools\art_review.bat` để tạo contact sheet 512 px cho mỗi model từ 4 góc (góc camera của game yaw 45° pitch 35° và 3 góc phụ), cả ánh sáng ngày lẫn đêm, cộng ảnh đặt trong cảnh thật; (3) nếu bạn đọc được ảnh: liệt kê ít nhất 5 vấn đề thật (tỉ lệ sai, mắt khuất, bộ phận lơ lửng hoặc xuyên nhau, z-fighting, màu lệch bảng màu, bóng đen khó nhận, quá dữ hoặc kém dễ thương), sửa rồi chụp lại, tối đa 3 vòng; (4) nếu không đọc được ảnh: vẫn tạo contact sheet để mình nhận xét, không tự tuyên bố “đẹp”.

Kiểm tra tự động không cần ảnh: không có tam giác suy biến, không NaN, không vượt ngân sách tam giác, mọi mesh nằm trong hộp bao kỳ vọng, pivot đặt đúng, mọi model nạp được không lỗi, tỉ lệ đầu và thân nằm trong khoảng của art bible.

Bảng so sánh tỉ lệ: scene `tools/art_lineup.tscn` đặt tất cả nhân vật, NPC, cây, công trình cạnh nhau với thước ô lưới; chụp ảnh khi hoàn tất mỗi nhóm.

## PHẦN 3 — DANH SÁCH MODEL BẮT BUỘC

Nhân vật: người chơi (tùy chỉnh ngoại hình); An (thợ bánh: mũ đầu bếp tròn, tạp dề); Bác Lâm (thợ mộc: râu, thắt lưng dụng cụ, bút chì sau tai); Linh (yêu thiên nhiên: vòng hoa hoặc kẹp lá, giỏ nhỏ); Minh (thương nhân: ba lô to, mũ); và các NPC khác theo dữ liệu. Thú nuôi hoặc bạn đồng hành nhỏ (mèo hoặc cún) đi theo hoặc nằm ở nhà, nếu ROADMAP hoặc master plan không cấm.

Mặt và biểu cảm: bình thường, vui, ngạc nhiên, buồn, ngủ, đang nói (miệng mấp máy theo tốc độ chữ trong hội thoại). API `CharacterFace.set_emotion(id)`. Bong bóng cảm xúc (tim, !, ?, nốt nhạc, giọt mồ hôi, zzz) vẽ bằng code.

Công cụ cầm tay: cuốc, bình tưới, liềm, túi hạt, cần câu (nếu có), kèm phiên bản trên tay nhân vật.

Cây trồng: mỗi loại 4 giai đoạn cộng héo, hình dáng riêng và dễ thương (lá tròn, củ mập, thân cao mềm); giai đoạn chín có điểm nhấn (lấp lánh nhẹ, hơi nhún). Tùy chọn: mặt nhỏ dễ thương trên nông sản ở icon.

Cây to, bụi, hoa, đá, nấm, cỏ: tán tròn như mây, thân ngắn mập; có biến thể theo mùa.

Công trình: nhà của bà (nhà gỗ ấm cúng, mái tròn, cửa tròn, ống khói); thùng bán; cửa hàng hạt giống dạng quầy có mái che; nhà hoặc quầy của từng NPC; trạm quan trắc với Cỗ máy Mùa (bánh răng tròn, đèn phát sáng, nét mặt dễ thương); hàng rào, cầu gỗ, giếng, đèn đường, hộp thư, biển chỉ đường.

Sinh vật nền: chim, bướm, cá, ong, đom đóm dạng hạt tròn phát sáng.

Vật phẩm: mỗi `ItemData` một mesh nhỏ và icon dạng nhãn dán (sticker): viền trắng dày, bóng nhẹ, nền trong suốt, 128 px.

## PHẦN 4 — GIAO DIỆN VÀ ÂM THANH DỄ THƯƠNG

Giao diện: một Theme thống nhất; bảng và nút bo tròn mạnh (dạng viên thuốc), màu pastel, đổ bóng mềm, viền sáng, icon sticker, hotbar như các ô kẹo, thanh tiến độ bo tròn; hiệu ứng nhún (bounce) khi mở bảng, hover và bấm; con trỏ chuột vẽ bằng code (bàn tay hoặc chân mèo) và đổi theo công cụ; logo game bằng chữ có viền, bóng và nhún nhẹ. Nếu mình đã thả font bo tròn có đủ dấu tiếng Việt vào `assets/fonts` thì dùng; chưa có thì dùng Open Sans và để `StyleBox` tạo cảm giác tròn trịa. Mọi chữ vẫn qua `tr()`.

Âm thanh: tổng hợp bằng code, âm sắc kalimba, marimba, glockenspiel, ukulele gảy mềm; thang âm ngũ cung; SFX dạng “pop”, “bloop”, chuông nhỏ; mỗi NPC có tiếng lẩm bẩm riêng (chuỗi nốt ngắn đổi cao độ, phát theo từng chữ khi hội thoại) và có công tắc tắt trong Cài đặt. Dịu tai, không chói; bám Phần 4 của prompt tổng về bus và ID.

Hiệu ứng (VFX): lấp lánh hình sao, tim khi tặng quà, khói bụi dạng cầu tròn nở ra, bong bóng nước, cánh hoa; giới hạn số hạt để giữ FPS.

## PHẦN 5 — MỐC CHIBI

Thay cho phần đồ họa của M2 đến M8; mỗi cuộc trò chuyện tối đa 1 mốc đồ họa nặng hoặc 2 mốc nhẹ.

- C0 (thay M2) Art bible và nền: `docs/ART_BIBLE.md`, bảng màu pastel, shader (toon nhuốm màu, outline, rim, gió, nước, dither-fade), builder chibi, art_review, art_lineup, test nạp shader và ngân sách tam giác. Tag `chibi-core`.
- C1 (thay M3) Nhân vật: người chơi và tùy chỉnh ngoại hình, 4 NPC, thú nuôi, khuôn mặt và biểu cảm, hoạt họa, bong bóng cảm xúc. Tag `chibi-characters`.
- C2 (thay M4) Cây trồng, vật phẩm, công cụ, đất cuốc và đất ướt, hiệu ứng nông trại, icon sticker. Tag `chibi-farming`.
- C3 (thay M5 và M6) Thế giới chibi: địa hình mềm, công trình, đường, nước, ranh giới (rừng và vách đá bo tròn), vật trang trí, hiệu ứng theo mùa và sinh vật nền, theo Phần 5 của prompt tổng. Tag `chibi-world`.
- C4 (thay M7) Giao diện chibi: Theme, icon, menu, màn hình chính 3D, con trỏ, tooltip. Tag `chibi-ui`.
- C5 (thay M8) Âm thanh dễ thương: SFX, ambient, nhạc theo mùa, tiếng lẩm bẩm NPC, bus. Tag `chibi-audio`.
- C6 Rà soát tổng thể: bảng so sánh tỉ lệ, nhất quán màu và nét, FPS, dung lượng, ảnh cuối. Tag `chibi-v1`. Sau đó quay lại M9 trở đi của prompt tổng và áp dụng cùng phong cách cho mọi model mới (máy chế biến, công trình xây dựng, cá...).

## PHẦN 6 — BÁO CÁO CUỐI MỖI CUỘC TRÒ CHUYỆN

Như Phần 7 của prompt tổng, cộng thêm: danh sách model đã tạo kèm số tam giác, đường dẫn contact sheet và ảnh lineup, các vấn đề bạn tự thấy và đã sửa, các điểm mình cần xem kỹ nhất (mặt nhân vật, cây trồng, giao diện), và câu dán cho cuộc sau: “Đọc `docs/MASTER_PROMPT.md` và `docs/CHIBI_STYLE_PROMPT.md` rồi làm tiếp từ `PROGRESS.md`”.
