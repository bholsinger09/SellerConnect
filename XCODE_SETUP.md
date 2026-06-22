# Setting Up the Embedded Backend in Xcode

This guide walks through adding the embedded Vapor backend to the SellerConnect iOS app.

## Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later deployment target
- Both `SellerConnect` and `SellerConnectBackend` directories

## Step-by-Step Setup

### 1. Add Backend Package to Xcode Project

1. Open `SellerConnect.xcodeproj` in Xcode
2. Go to **File → Add Packages...**
3. In the search box, select **Local** (or paste the path directly)
4. Navigate to `/Users/benh/Documents/SellerConnect/SellerConnectBackend`
5. Click **Add Package**
6. In the dialog that appears:
   - Choose `SellerConnect` target
   - Click **Add Package**

### 2. Link Backend Library to App Target

1. Select the **SellerConnect** project in Xcode
2. Select the **SellerConnect** target (the app, not tests)
3. Go to **Build Phases**
4. Expand **Link Binary With Libraries**
5. Click **+** button
6. Search for `SellerConnectBackend`
7. Select it and click **Add**

### 3. Update Import Statements

The `SellerConnectApp.swift` file is already updated to conditionally import:
```swift
#if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
import SellerConnectBackend
#endif
```

### 4. Verify Build Settings

1. Select **SellerConnect** target
2. Go to **Build Settings**
3. Search for "Package Dependency"
4. Verify `SellerConnectBackend` appears in the list

## Troubleshooting

### Issue: "Cannot import SellerConnectBackend"

**Solution:**
- Ensure the package was added in Build Phases > Link Binary With Libraries
- Clean build folder: **Cmd + Shift + K**
- Build again: **Cmd + B**

### Issue: "Module SellerConnectBackend not found"

**Solution:**
- Verify the package path is correct
- Delete `Derived Data`: 
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData/*SellerConnect*
  ```
- Reopen the project

### Issue: Build fails on physical device

**Solution:**
- Verify iOS platform is added to backend Package.swift
- Check that app's deployment target matches or is higher
- Verify architecture support (arm64)

## Building and Running

### Development (Embedded Server)

```bash
# Open Xcode
open SellerConnect/SellerConnect.xcodeproj

# Select simulator or device
# Press Play or Cmd+R
```

The app will automatically start the embedded Vapor server on first launch.

### Testing Backend Independently

For testing without the iOS app:

```bash
cd SellerConnectBackend
swift build

# Run standalone server
swift run SellerConnectBackendExecutable
```

Server will be available at `http://localhost:8080`

## Database Location

The embedded backend stores data at:
```
~/Library/Developer/CoreSimulator/Devices/<DEVICE-ID>/data/Containers/Data/Application/<APP-ID>/Documents/db.sqlite
```

### Finding Your App's Directory

```bash
# List all app containers
xcrun simctl get_app_container booted com.example.SellerConnect data

# Access database
xcrun simctl spawn booted sqlite3 <PATH>/db.sqlite ".tables"
```

## Verifying Server is Running

You can add debugging to check if server started successfully. In Xcode console, you should see:

```
Embedded Vapor server started on http://localhost:8080
```

If you see errors, check the console output for details.

## Switching Between Embedded and External Backend

To use external backend instead of embedded:

1. Open `APIConfiguration.swift`
2. Change the debug environment:
   ```swift
   static let current: Environment = {
       #if DEBUG
       return .development  // Change from .embedded to .development
       #else
       return .production
       #endif
   }()
   ```

3. Make sure external server is running on `localhost:8080` or update the URL

## Performance Considerations

- **First Run**: Server initialization may take 1-2 seconds
- **Memory**: Embedded server uses ~50-100MB RAM
- **Battery**: Minimal impact when idle
- **Background**: Server may be suspended when app backgrounded

## Next Steps

1. Build and run the app
2. Try registering a new account
3. Check Xcode console for server logs
4. Verify data persists across app restarts

## Support

For issues, check:
- Xcode console for error messages
- `EMBEDDED_BACKEND.md` for architecture overview
- `RUNNING_LOCALLY.md` for backend-specific setup
