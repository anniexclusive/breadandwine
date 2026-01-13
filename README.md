# Bread & Wine Devotional - iOS

Native iOS app delivering daily spiritual devotionals from Firstlove Assembly. Built with Swift and SwiftUI.

## Overview

Daily devotional app featuring scripture readings, spiritual insights, prayers, and Bible reading plans. Available on iPhone and iPad with adaptive layouts.

**Key Features:**
- Daily devotionals with rich HTML content
- Daily nuggets (quick spiritual insights)
- Text-to-speech (British English, 0.65x speed)
- Share functionality
- Local notifications (6 AM morning, 10 AM nugget)
- Background fetch (9:45 AM daily)
- Offline caching
- Adaptive UI (iPhone/iPad optimized)
- Dark mode support

## Tech Stack

- **Language**: Swift
- **UI**: SwiftUI
- **Architecture**: MVVM with Combine
- **Backend**: WordPress REST API + Firebase (FCM, Firestore)
- **Storage**: UserDefaults
- **Background**: BGTaskScheduler + UNUserNotificationCenter
- **Networking**: URLSession
- **HTML Rendering**: WKWebView with custom CSS

## Build Commands

```bash
# Build for simulator
xcodebuild -project BreadAndWine.xcodeproj -scheme BreadAndWine -configuration Debug build

# Run tests
xcodebuild test -project BreadAndWine.xcodeproj -scheme BreadAndWine -destination 'platform=iOS Simulator,name=iPhone 15'

# Clean build
xcodebuild clean -project BreadAndWine.xcodeproj -scheme BreadAndWine
```

## Setup

1. Clone repository
2. Add `GoogleService-Info.plist` to project root (from Firebase Console)
3. Open `BreadAndWine.xcodeproj` in Xcode
4. Select a simulator or device
5. Press Cmd+R to build and run

## Key Architecture

**Adaptive Navigation:**
- iPad: NavigationSplitView with persistent/dismissible sidebar
- iPhone: NavigationView with slide-out drawer menu
- Detects via `@Environment(\.horizontalSizeClass)`

**Notification System:**
- Morning (6 AM): Daily reminder via UNUserNotificationCenter
- Nugget (10 AM): Daily nugget with actual text
- Background fetch (9:45 AM): Updates nugget content before delivery

**HTML Rendering:**
- Uses WKWebView with custom CSS injection
- System font integration for native feel
- Dark mode support via colorScheme
- Custom blockquote styling

## Documentation

See `CLAUDE.md` for detailed architecture, development guide, and troubleshooting.

## Version Info

- **Current**: Latest (check Info.plist)
- **Bundle ID**: `com.firstloveassembly.breadandwine`
- **Min iOS**: 16.0
- **Target iOS**: 17.0+
