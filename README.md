# TickyTacky

TickyTacky là ứng dụng iOS chơi Tic Tac Toe/Caro 3x3 được viết bằng SwiftUI. Dự án hỗ trợ chơi local với người hoặc bot, chơi online theo phòng qua Firebase Realtime Database, lưu lịch sử trận, thành tựu, bảng xếp hạng và một số chi tiết UX như haptic feedback, toast, QR code và confetti khi thắng.

## Tính năng chính

- Chơi local 3x3 với hai người trên cùng thiết bị hoặc đấu với bot.
- Bot có 3 độ khó:
  - Easy: chọn nước đi ngẫu nhiên.
  - Medium: ưu tiên thắng ngay hoặc chặn đối thủ, sau đó mới chọn ngẫu nhiên.
  - Hard: dùng Minimax để chọn nước đi tối ưu.
- Gợi ý nước đi trong ván local bằng logic Hard.
- Chọn người đi trước: bạn, đối thủ hoặc ngẫu nhiên.
- Chơi online thời gian thực bằng Firebase Realtime Database.
- Tạo phòng riêng bằng mã 4 số hoặc phòng công khai trong lobby.
- Tham gia phòng bằng mã phòng hoặc quét QR.
- Trạng thái ready trước khi bắt đầu trận online.
- Online match dạng Best of 3: ai đạt 2 round thắng trước sẽ thắng match.
- Đồng hồ lượt online 10 giây; hết giờ app tự chọn nước đi bằng bot mức Medium.
- Emoji reaction trong phòng online.
- Rematch sau khi kết thúc match online.
- Lưu lịch sử trận bằng SwiftData.
- Thành tựu local/online lưu bằng `AppStorage`.
- Bảng xếp hạng online trên Firebase, cộng/trừ điểm theo kết quả.
- Dark mode, haptic feedback, tên hiển thị và màn hình Settings.

## Công nghệ

- SwiftUI cho giao diện.
- Swift Concurrency (`async/await`, `Task`, `AsyncStream`) cho bot, Firebase listener và xử lý bất đồng bộ.
- SwiftData cho lịch sử trận local trên thiết bị.
- Firebase:
  - Firebase Core
  - Firebase Realtime Database
  - Firebase Analytics
  - Firebase Crashlytics
- Factory / FactoryKit cho dependency injection.
- Swift Testing cho unit test target.
- XCTest cho UI test target.

## Yêu cầu môi trường

- Xcode hỗ trợ iOS 26 SDK.
- Deployment target hiện tại trong project: iOS 26.0.
- Swift Package Manager để resolve Firebase và Factory.
- Một Firebase project có Realtime Database.

## Cài đặt và chạy

1. Clone repository.
2. Mở `TickyTacky.xcodeproj` bằng Xcode.
3. Đảm bảo file `TickyTacky/GoogleService-Info.plist` thuộc đúng Firebase project của bạn.
4. Kiểm tra Realtime Database URL trong:

```swift
Database.database(url: "https://ticky-tacky-ios-default-rtdb.firebaseio.com/")
```

Hiện URL này được dùng trong `TickyTackyApp.swift` và `OnlineGameService.swift`.

5. Chọn scheme `TickyTacky`.
6. Chọn simulator hoặc thiết bị thật.
7. Nhấn `Cmd + R`.

## Chạy test

Chạy bằng Xcode:

- Unit tests: `Cmd + U`
- UI tests: chọn test target `TickyTackyUITests` trong Test Navigator.

Hoặc chạy bằng terminal:

```bash
xcodebuild test \
  -project TickyTacky.xcodeproj \
  -scheme TickyTacky \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Tên simulator có thể cần đổi theo máy đang cài.

## Cấu trúc thư mục

```text
TickyTacky/
├── App/                  # App entry point, Firebase setup, root view
├── Domain/               # Model, enum, constants, SwiftData model
├── Extensions/           # Helper extension và Factory registrations
├── Features/             # Màn hình và ViewModel theo từng tính năng
│   ├── AppMode/
│   ├── Game/
│   ├── GameSetup/
│   ├── History/
│   ├── Home/
│   ├── Leaderboard/
│   ├── OnlineGame/
│   ├── OnlineLobby/
│   └── Settings/
├── Resources/            # Chuỗi dùng trong app
├── Services/             # Bot, board logic, Firebase, history, haptic, QR, toast
├── Stores/               # App state và game setup/game store
├── UIComponents/         # Component SwiftUI tái sử dụng
├── Assets.xcassets/      # Icon, logo, avatar
└── Colors.xcassets/      # Bảng màu app
```

## Kiến trúc

Dự án đi theo hướng MVVM kết hợp service/store:

- `Features/*View.swift`: dựng UI bằng SwiftUI.
- `Features/*ViewModel.swift`: giữ state màn hình, điều phối action người dùng và gọi service/store.
- `Stores/*`: lưu trạng thái app mode, cấu hình game và logic game local.
- `Services/*`: gom các phần phụ thuộc hoặc logic riêng như bot, Firebase online room, leaderboard, history, analytics, haptic, QR code và toast.
- `Domain/*`: định nghĩa kiểu dữ liệu cốt lõi như `Player`, `Board`, `CellState`, `GameState`, `MatchHistory`, `Achievement`.
- `Container+Registration.swift`: đăng ký dependency bằng Factory để các ViewModel có thể inject service/store.

Root flow bắt đầu ở `TickyTackyApp`, cấu hình Firebase rồi render `AppModeView`. `AppModeLiveStore` quyết định màn hình hiện tại: Home, Game Setup, Game, History, Settings, Online Lobby, Online Game hoặc Leaderboard.

## Luồng chơi local

1. Người dùng vào `GameSetupView`.
2. Chọn player, loại đối thủ, độ khó và lượt đi đầu.
3. `GameViewModel` khởi tạo `Player`, `Board`, `GameState`.
4. Mỗi nước đi được validate qua `GameStore`.
5. Nếu đối thủ là bot, `BotEngineService` chọn nước đi theo độ khó.
6. Khi ván kết thúc, app:
   - animate ô thắng,
   - cập nhật số trận thắng,
   - lưu `MatchHistory` bằng SwiftData,
   - kiểm tra achievement,
   - hiển thị confetti/haptic khi phù hợp.

## Luồng chơi online

1. Người dùng vào `OnlineLobbyView`.
2. Có thể tạo phòng riêng, tạo phòng công khai hoặc join bằng mã/QR.
3. `OnlineGameService` tạo room trong Firebase tại node `rooms/{roomID}`.
4. Hai người chơi toggle ready; khi cả hai ready, room chuyển sang `playing`.
5. Board online được lưu dưới dạng mảng 9 phần tử trong Firebase.
6. Host/player 1 report kết quả từng round để tránh double report.
7. Match kết thúc khi một người đạt 2 điểm round.
8. Kết quả match được lưu lịch sử, cập nhật achievement và cập nhật leaderboard.

## Dữ liệu Firebase chính

```text
rooms/{roomID}
├── id
├── player1Name, player1ID, player1Ready
├── player2Name, player2ID, player2Ready
├── board
├── currentTurn
├── status
├── winnerID
├── isPublic
├── player1Score, player2Score
├── player1Rematch, player2Rematch
└── player1Emoji/player2Emoji + timestamp

leaderboard/{userID}
├── id
├── name
├── points
└── lastUpdated
```

## Thành tựu

Các achievement hiện có:

- First Victory: thắng trận đầu tiên.
- Bot Slayer: thắng bot ở độ khó Hard.
- Speedster: thắng dưới 10 giây.
- Strategist: thắng trong đúng 5 nước đi.
- Tie Master: đạt 5 trận hòa.
- Unstoppable: thắng 3 trận liên tiếp.

Trạng thái mở khóa được lưu bằng `AppStorage("unlocked_achievements")`.

## Ghi chú phát triển

- `GoogleService-Info.plist` đang có trong repo. Nếu đổi Firebase project, thay file này và cập nhật Database URL cho đồng nhất.
- Realtime Database persistence được bật trong `TickyTackyApp`.
- Haptic có thể bật/tắt trong Settings bằng `AppStorage("isHapticEnabled")`.
- Unit test hiện mới là scaffold mặc định; phần logic đáng ưu tiên test thêm là `BotEngineService`, `BoardLogicService`, `GameStore` và `OnlineGameService` transaction flow.
- Worktree hiện có thể chứa thay đổi đang phát triển. Khi chỉnh sửa, nên kiểm tra `git status` trước để tránh đè thay đổi chưa commit.
