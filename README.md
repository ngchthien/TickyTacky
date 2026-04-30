# TickyTacky - Đỉnh Cao Cờ Caro (Tic Tac Toe) Hiện Đại

TickyTacky không chỉ là một trò chơi Tic Tac Toe thông thường; đây là một ứng dụng iOS cao cấp được xây dựng với sự tinh tế trong thiết kế, trí tuệ nhân tạo (AI) mạnh mẽ và khả năng chơi trực tuyến thời gian thực.

## ✨ Các Tính Năng Nổi Bật

Dựa trên việc phân tích mã nguồn, dưới đây là những tính năng cốt lõi làm nên sự khác biệt của TickyTacky:

### 🎮 Chế Độ Chơi Đa Dạng
- **Đấu với Máy (AI)**: Sử dụng thuật toán **Minimax** cho độ khó "Khó" (Hard), đảm bảo một thử thách không thể đánh bại nếu bạn không tính toán kỹ.
- **Chơi Local**: Hai người chơi trên cùng một thiết bị với giao diện tối ưu.
- **Đấu Online (Firebase)**: Kết nối và thi đấu với người chơi khác trên toàn thế giới thông qua Firebase Realtime Database.

### 🌐 Tính Năng Online Cao Cấp
- **Phòng Chơi Công Khai & Riêng Tư**: Bạn có thể tạo phòng để người lạ tham gia hoặc chia sẻ mã phòng cho bạn bè.
- **Quét Mã QR**: Gia nhập phòng chơi nhanh chóng bằng cách quét mã QR (tích hợp `QRScannerView` và `QRCodeService`).
- **Best of 3 (Bo3)**: Chế độ thi đấu phân định thắng thua qua 3 hiệp đấu kịch tính.
- **Cảm Xúc (Emoji Reactions)**: Gửi các biểu tượng cảm xúc thời gian thực để tương tác với đối thủ trong trận đấu.

### 🏆 Hệ Thống Thành Tựu & Xếp Hạng
- **Thành Tựu (Achievements)**: Theo dõi và mở khóa các cột mốc như "Bot Slayer", "Speedster" (thắng dưới 10 giây), hay "Unstoppable" (chuỗi thắng).
- **Bảng Xếp Hạng (Leaderboard)**: Cạnh tranh vị trí dẫn đầu với cộng đồng người chơi.
- **Lịch Sử Trận Đấu**: Lưu trữ và xem lại các kết quả đối đầu trước đó.

### 💎 Trải Nghiệm Người Dùng (UX/UI)
- **Haptic Feedback**: Sử dụng `HapticService` để mang lại cảm giác rung phản hồi chân thực khi chạm vào các ô cờ hoặc khi có kết quả trận đấu.
- **Giao Diện Hiện Đại**: Hỗ trợ đầy đủ **Dark/Light Mode** với bảng màu "Midnight Aurora" được tinh chỉnh tỉ mỉ.
- **Hiệu Ứng Sinh Động**: Hiệu ứng pháo hoa (Confetti) khi chiến thắng và các chuyển cảnh mượt mà.

## 🚀 Công Nghệ Sử Dụng

Dự án được xây dựng trên nền tảng công nghệ mới nhất của hệ sinh thái Apple:

- **Ngôn ngữ**: Swift 5.10+
- **Giao diện**: SwiftUI (Khai báo giao diện hiện đại)
- **Kiến trúc**: MVVM kết hợp với **Factory** (Dependency Injection) để quản lý mã nguồn sạch và dễ kiểm thử.
- **Xử lý bất đồng bộ**: Sử dụng **Swift Concurrency** (`async/await`, `AsyncStream`) cho việc xử lý logic AI và dữ liệu Firebase một cách mượt mà, không gây treo giao diện.
- **Backend**: Firebase Realtime Database cho tính năng multiplayer thời gian thực.
- **Dependency Management**: Tích hợp các service thông qua mô hình Container-based DI.

## ⚙️ Cấu Hình & Cài Đặt

1. **Yêu cầu**: Xcode 15.0+, iOS 17.0+
2. **Firebase**: 
   - Đảm bảo tệp `GoogleService-Info.plist` đã được cấu hình trong dự án.
   - Database URL phải được trỏ chính xác trong `TickyTackyApp.swift`.
3. **Chạy dự án**: Mở tệp `TickyTacky.xcodeproj` và nhấn `Cmd + R`.

---

Được thiết kế và phát triển với ❤️ nhằm mang lại trải nghiệm chơi game chuyên nghiệp và đẳng cấp.
