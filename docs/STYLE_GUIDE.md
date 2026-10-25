# STYLE GUIDE — Nội dung & giọng văn của THE LIFE

Dành cho mọi văn bản người chơi nhìn thấy (hội thoại, nhiệm vụ, vật phẩm, thư, UI) và cho AI khi soạn nội dung nháp. Agent chỉ soạn NHÁP; người phát triển duyệt giọng văn.

## 1. Giọng văn
- Ấm áp, giản dị, nhẹ nhàng; như một người hàng xóm tử tế. Không sến, không gồng, không "kịch".
- Câu ngắn. Ít tính từ. Tả bằng hình ảnh cụ thể (mùi bánh, tiếng mưa trên mái) thay vì lời khen chung chung.
- Không giáo điều, không đe dọa. Áp lực luôn đi kèm gợi ý cách đối phó.
- Dùng "bạn" khi hệ thống nói với người chơi. Lời bà viết trong sổ tay/thư xưng "ta" và gọi "con".

## 2. Xưng hô & giọng từng NPC
| NPC | Giọng | Xưng hô với người chơi |
|---|---|---|
| An (thợ bánh) | vui vẻ, nói nhiều về bột và lò nướng | "bạn" |
| Bác Lâm (thợ mộc) | trầm, chậm, hay nhắc chuyện xưa của thung lũng | "cháu" / gọi tên |
| Linh (yêu thiên nhiên) | nhẹ, mơ màng, thích chỉ cho người ta nhìn kỹ | "bạn" |
| Minh (thương nhân) | nhanh nhảu, hóm hỉnh, hay kể chuyện nơi khác | "anh/chị bạn" hoặc "bạn" |

## 3. Từ ngữ riêng (dùng thống nhất)
Thung Lũng Mùa · Cỗ máy Mùa (hoặc "Bánh răng của Mùa") · trạm quan trắc · sổ tay của bà · trang trại · coin.

## 4. TỪ CẤM trong văn bản người chơi
- "AI", "trí tuệ nhân tạo", "thuật toán", "hệ thống Director".
- Thuật ngữ RPG nặng (cấp độ, EXP, buff/debuff) nếu không hợp tông.
- Từ gây áp lực/đe dọa kiểu "thất bại", "bị phạt", "mất hết" (đổi thành lời gợi ý nhẹ nhàng).

## 5. Giới hạn độ dài
- Một hộp hội thoại ≤ 120 ký tự (khoảng 1–2 câu). Tên vật phẩm ≤ 24 ký tự. Mô tả vật phẩm ≤ 100 ký tự. Mục tiêu nhiệm vụ ≤ 60 ký tự.
- Chuỗi tiếng Anh thường dài hơn → kiểm tra không vỡ layout.

## 6. Quy ước khóa dịch (translation key)
- `KEY_SNAKE`, theo mẫu `LOẠI_ĐỐI_TƯỢNG_TRƯỜNG`: `ITEM_WHEAT_NAME`, `ITEM_WHEAT_DESC`, `NPC_AN_NAME`, `DLG_AN_INTRO_01`, `QUEST_FIRST_HARVEST_TITLE`, `PROMPT_INTERACT`.
- Mọi khóa phải có ở CẢ `vi` và `en`. Thiếu một ngôn ngữ = lỗi của `DataValidator`.
- Không nhét văn bản vào code; không ghép câu bằng cách nối chuỗi (dùng placeholder: `"Bạn nhận được %d xu"`).

## 7. Khi nhờ AI soạn nội dung
- Yêu cầu AI chỉ xuất đúng định dạng dữ liệu (CSV/.tres) theo `docs/DATA_SCHEMA.md`, kèm cả hai ngôn ngữ.
- AI soạn nháp → `DataValidator` kiểm cấu trúc → bạn duyệt giọng văn → mới vào game.

## 8. Câu cố định cần giữ (nội dung gốc)
- Sổ tay trang đầu: "Một mảnh đất không trở nên giàu có chỉ nhờ những gì ta thu hoạch. Nó trở nên giàu có nhờ những gì ta để lại."
- Mục tiêu đầu tiên: "Hãy biến nơi này thành nhà của bạn."
- Các lá thư của bà: xem Phụ lục A trong `docs/reference/THE_LIFE_MASTER_PLAN.txt`.
