# Embedded Vapor Backend Architecture

## Overview

SellerConnect now uses an **embedded Vapor backend** that runs directly on the user's iOS device. This eliminates the need for external servers while keeping the app fully functional.

## Architecture Changes

### Before
```
iOS App ←→ HTTP ←→ Vapor Backend (External Server)
           localhost:8080    or AWS/Render
```

### After
```
iOS App ↕
   ├─ Vapor Backend (Embedded)
   └─ Local Database
        HTTP via localhost:8080
```

## How It Works

1. **App Launch**: The iOS app initializes the embedded Vapor server
2. **Server Runs**: Vapor server starts on `http://localhost:8080` internally
3. **Data Management**: All data is stored in the app's local SQLite database
4. **API Calls**: The iOS app makes HTTP requests to its own embedded server
5. **Background**: Server runs in the app's background/suspended state

## Package Structure

### SellerConnectBackend
- **Library Target** (`SellerConnectBackend`): 
  - Contains all Vapor backend code (controllers, models, migrations, etc.)
  - Can be imported by iOS app
  - Includes `EmbeddedServer` class for lifecycle management

- **Executable Target** (`SellerConnectBackendExecutable`):
  - Standalone server for development/testing
  - Uses the library target
  - Still supports running as a separate process if needed

## Integration Steps

### 1. Add Backend Package to iOS Project
- Xcode → "SellerConnectApp" target
- Build Phases → "Link Binary With Libraries"
- Add `SellerConnectBackend` package

### 2. Initialize Server in App Startup
```swift
import SwiftUI
import SellerConnectBackend

@main
struct SellerConnectApp: App {
    @State private var serverError: String?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        do {
                            try await EmbeddedServer.shared.start()
                        } catch {
                            serverError = "Failed to start backend: \(error)"
                        }
                    }
                }
        }
    }
}
```

### 3. No Changes to API Client Needed
- `APIClient` already uses `http://localhost:8080`
- Requests are now routed to the embedded server
- Works seamlessly with no code changes

## Database

- **Location**: App's Documents directory
- **Filename**: `db.sqlite`
- **Migrations**: Automatic on first run
- **Isolated**: Each app instance has its own database

## Advantages

✅ **No external server dependency**
✅ **Works offline** (after initial data sync)
✅ **User data stays on device**
✅ **Faster API calls** (local HTTP)
✅ **App Store compliant** (self-contained)
✅ **Cost-effective** (no server hosting)

## Limitations

⚠️ **Background Execution**:
- Server may be suspended when app goes to background
- iOS limits background networking
- Users should keep app in foreground for critical operations

⚠️ **Multi-Device Sync**:
- Each device has independent database
- No automatic cloud sync
- Would require custom implementation

⚠️ **Data Sharing**:
- Users can't easily share data between devices
- Consider CloudKit or backend sync if needed in future

## Running Standalone Server

If you still need the server to run separately (for testing/development):

```bash
cd SellerConnectBackend
swift run SellerConnectBackendExecutable
```

## Migration from External Backend

For users upgrading from old version:

1. **Install new app** with embedded backend
2. **First launch**: Server auto-initializes
3. **Existing data**: Lost (fresh database)
4. **Re-register**: Users create new accounts locally

If you need data migration, would require:
- Export script from old backend
- Import logic in new app
- Data transformation as needed

## Future Enhancements

- [ ] CloudKit sync for multi-device support
- [ ] User data export/import
- [ ] Selective background sync
- [ ] On-demand background fetch
- [ ] Family Sharing for shared databases
