# Embedded Backend Architecture Diagram

## System Architecture - Before vs After

### BEFORE: Localhost Dependency
```
┌─────────────────────────────────────────────────┐
│                iOS App Bundle                    │
│  ┌─────────────────────────────────────────┐   │
│  │       SellerConnect App                  │   │
│  │  ┌──────────────┐    ┌───────────────┐  │   │
│  │  │   SwiftUI    │    │  RegisterView │  │   │
│  │  │   UI Layer   │    │    ViewModel  │  │   │
│  │  └──────────────┘    └───────────────┘  │   │
│  │         │                   │              │   │
│  │         └───────┬───────────┘              │   │
│  │              APIClient                    │   │
│  └─────────────────────────────────────────┘   │
│              │                                  │
│              ↓ HTTP                             │
│         localhost:8080                         │
│              ↓                                  │
└─────────────────────────────────────────────────┘
              │
              ↓ EXTERNAL NETWORK REQUEST
    ┌─────────────────────────────┐
    │   External Vapor Server     │
    │   (localhost/AWS/Render)    │
    │                             │
    │   ┌──────────────────────┐  │
    │   │  SQLite Database     │  │
    │   │  (External Server)   │  │
    │   └──────────────────────┘  │
    └─────────────────────────────┘

PROBLEMS:
✗ Requires running local server during development
✗ Requires external cloud service for App Store deployment
✗ App only works if server is accessible
✗ User data potentially on external server
✗ Cost for hosting the server
```

### AFTER: Embedded Backend
```
┌────────────────────────────────────────────────────────┐
│                    iOS App Bundle                       │
│  ┌─────────────────────────────────────────────────┐  │
│  │                  Swift Runtime                   │  │
│  │  ┌────────────────────────────────────────────┐ │  │
│  │  │          SellerConnect App                  │ │  │
│  │  │  ┌──────────────┐    ┌───────────────────┐ │ │  │
│  │  │  │   SwiftUI    │    │  RegisterView     │ │ │  │
│  │  │  │   UI Layer   │    │  ViewModel        │ │ │  │
│  │  │  └──────────────┘    └───────────────────┘ │ │  │
│  │  │         │                   │               │ │  │
│  │  │         └───────┬───────────┘               │ │  │
│  │  │              APIClient                      │ │  │
│  │  └────────────────────────────────────────────┘ │  │
│  │         ↕ HTTP (localhost:8080)                 │  │
│  │  ┌────────────────────────────────────────────┐ │  │
│  │  │        Embedded Vapor Server               │ │  │
│  │  │         (EmbeddedServer.swift)             │ │  │
│  │  │  ┌──────────────────────────────────────┐  │ │  │
│  │  │  │      REST API Routes                  │  │ │  │
│  │  │  │  • POST /users/register               │  │ │  │
│  │  │  │  • GET /users                         │  │ │  │
│  │  │  │  • DELETE /users/:id                  │  │ │  │
│  │  │  └──────────────────────────────────────┘  │ │  │
│  │  │                    │                        │ │  │
│  │  │                    ↓                        │ │  │
│  │  │  ┌──────────────────────────────────────┐  │ │  │
│  │  │  │  SQLite Database                     │  │ │  │
│  │  │  │  (App Documents Directory)           │  │ │  │
│  │  │  │                                      │  │ │  │
│  │  │  │  • users table                       │  │ │  │
│  │  │  │  • todos table                       │  │ │  │
│  │  │  └──────────────────────────────────────┘  │ │  │
│  │  │                                             │ │  │
│  │  │  Lifecycle: App Launch ↔ Server Start/Stop │ │  │
│  │  └────────────────────────────────────────────┘ │  │
│  └─────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘

BENEFITS:
✓ Server built into app (runs on device)
✓ No external dependency required
✓ User data stays on device
✓ Fast local HTTP calls (~10-50ms)
✓ Ready for App Store deployment
✓ No hosting costs
✓ Works offline for existing data
✗ Server may suspend when app backgrounded (iOS limitation)
```

## File Organization - New Structure

```
SellerConnect/
├── SellerConnect/                                 # iOS App (Xcode)
│   ├── SellerConnect.xcodeproj/
│   │   └── project.pbxproj
│   └── SellerConnect/
│       ├── SellerConnectApp.swift              # ✨ Initializes server
│       ├── APIConfiguration.swift              # ✨ Added .embedded env
│       ├── Views/
│       │   ├── ContentView.swift
│       │   ├── RegisterView.swift              # Registration UI
│       │   └── ...
│       ├── ViewModels/
│       │   ├── RegisterViewModel.swift         # Validation logic
│       │   └── ...
│       └── Services/
│           └── APIClient.swift                 # HTTP client
│
├── SellerConnectBackend/                       # Vapor Backend
│   ├── Package.swift                          # ✨ Dual targets + iOS
│   ├── Sources/
│   │   ├── SellerConnectBackend/               # 📦 LIBRARY TARGET
│   │   │   ├── EmbeddedServer.swift           # ✨ Server manager
│   │   │   ├── configure.swift                # ✨ Public function
│   │   │   ├── routes.swift                   # ✨ Public function
│   │   │   ├── Controllers/
│   │   │   │   ├── UserController.swift
│   │   │   │   └── TodoController.swift
│   │   │   ├── Models/
│   │   │   │   ├── User.swift
│   │   │   │   └── Todo.swift
│   │   │   ├── Migrations/
│   │   │   │   ├── CreateUser.swift
│   │   │   │   └── CreateTodo.swift
│   │   │   ├── DTOs/
│   │   │   │   ├── UserDTO.swift
│   │   │   │   └── TodoDTO.swift
│   │   │   └── ...
│   │   │
│   │   └── SellerConnectBackendExecutable/    # ✨ EXECUTABLE TARGET
│   │       └── main.swift                     # Standalone entry point
│   │
│   ├── Tests/
│   │   └── SellerConnectBackendTests.swift
│   └── README.md
│
├── Documentation/
│   ├── IMPLEMENTATION_SUMMARY.md              # ✨ Executive summary
│   ├── EMBEDDED_BACKEND.md                    # ✨ Architecture guide
│   ├── EMBEDDED_IMPLEMENTATION.md             # ✨ Integration steps
│   ├── XCODE_SETUP.md                        # ✨ Xcode setup guide
│   ├── QUICKSTART.md                         # ✨ Quick checklist
│   ├── RUNNING_LOCALLY.md                    # Backend info
│   ├── SECURITY.md                           # Security guidelines
│   └── README.md
│
└── Git
    └── .gitignore                             # ✨ Enhanced (49 patterns)
```

## Data Flow Diagram

### Registration Flow
```
┌─────────────────┐
│  User Taps Reg  │
└────────┬────────┘
         │
         ↓
┌─────────────────────────────────────┐
│  RegisterView.swift                 │
│  • firstName TextField              │
│  • email SecureField                │
│  • password SecureField             │
│  • confirmPassword SecureField      │
└────────┬────────────────────────────┘
         │
         ↓ User enters data & taps Register
┌─────────────────────────────────────┐
│  RegisterViewModel.swift            │
│  • Validate password requirements   │
│  • Check passwords match            │
│  • Check email not empty            │
│  • Call register() function         │
└────────┬────────────────────────────┘
         │
         ↓ if validation passes
┌─────────────────────────────────────┐
│  APIClient.post() async             │
│  • Build JSON payload               │
│  • Set Content-Type: application/json
│  • Create URLRequest to POST         │
│    /users/register                  │
│  • 10-second timeout                │
└────────┬────────────────────────────┘
         │
         ↓ HTTP POST to localhost:8080
┌──────────────────────────────────────────────┐
│  Embedded Vapor Server (EmbeddedServer)      │
│  • Receives request on :8080                │
│  • Router directs to UserController         │
│  • UserController processes register()      │
│    1. Validate password regex               │
│    2. Check email not duplicate             │
│    3. Hash password with Bcrypt             │
│    4. Store in SQLite database              │
└────────┬─────────────────────────────────────┘
         │
         ↓ Success or Error response
┌──────────────────────────────────────┐
│  APIClient receives response         │
│  • Decode JSON                       │
│  • Return data to ViewModel          │
└────────┬──────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────┐
│  RegisterViewModel updates UI        │
│  • Set registrationSuccess = true    │
│  • Or set errorMessage               │
│  • Clear form fields                 │
└────────┬──────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────┐
│  RegisterView displays               │
│  • Success message with navigation   │
│  • Or error message                  │
└──────────────────────────────────────┘
```

## Component Interaction

```
┌─────────────────────────────────────────────────────────────┐
│                    iOS App Lifecycle                         │
└─────────────────────────────────────────────────────────────┘
                           ↓
                    App Launches
                           ↓
    ┌───────────────────────┴───────────────────────┐
    │                                               │
    ↓                                               ↓
SellerConnectApp                         EmbeddedServer
    │                                        │
    ├─ @main decorator                       ├─ @MainActor
    ├─ WindowGroup                           ├─ Singleton
    ├─ onAppear modifier                     ├─ @Published properties
    │   │                                    │   • isRunning
    │   │                                    │   • errorMessage
    │   ├─ Calls initializeServer()          │
    │   │   │                                │
    │   │   └─ Task { }                      │
    │   │       │                            │
    │   │       └─ try await                 │
    │   │            EmbeddedServer          │
    │   │            .shared.start()         │
    │   │               │                    │
    │   │               ├────────────────────┤
    │   │               │                    │
    │   │               └─ Creates Vapor     │
    │   │                  Application       │
    │   │                     │              │
    │   │                     ├─ configure() │
    │   │                     │              │
    │   │                     └─ app.execute()
    │   │                        (async Task)
    │   │
    │   └─ Displays ContentView
    │       └─ Can navigate to RegisterView
    │           │
    │           ↓
    │       User taps "Register"
    │           │
    │           ↓
    │       RegisterView
    │           │
    │           ├─ User enters data
    │           │
    │           ↓
    │       RegisterViewModel
    │           │
    │           ├─ Validates input
    │           │
    │           ├─ Calls APIClient.post()
    │           │      ↓
    │           │   HTTP POST localhost:8080
    │           │      ↓
    │           └─ EmbeddedServer.routes()
    │                  └─ UserController.register()
    │                     └─ Fluent saves to SQLite
    │
    └─ App Background/Terminate
        └─ EmbeddedServer stops
```

## Deployment Journey

### Development Phase
```
Developer Machine
├─ Simulator/Device
│  └─ App runs
│     └─ EmbeddedServer initializes
│        └─ Vapor starts on :8080
│           └─ SQLite database created
└─ Can test all features locally
```

### App Store Submission
```
SellerConnect.app Bundle
├─ App Code (SwiftUI, MVVM)
├─ Embedded Vapor Framework
│  └─ All backend code included
├─ SQLite driver
├─ Other dependencies
└─ ~50-100MB larger than without backend

Installation on Device
├─ App downloaded from App Store
├─ App launched by user
├─ Vapor server initializes
├─ Database created in app container
└─ User can use immediately (no server needed)
```

## Timeline: Before → After Transition

### BEFORE
```
Development:
  1. Start Vapor server manually (localhost:8080)
  2. Open iOS app
  3. App connects to localhost server
  4. Develop and test

Deployment:
  1. Deploy Vapor to AWS/Render
  2. Update app API endpoint
  3. Submit to App Store
  4. Pay monthly hosting costs
  5. Manage external server
```

### AFTER
```
Development:
  1. Open iOS app
  2. Server auto-starts (embedded)
  3. Develop and test

Deployment:
  1. Submit app to App Store
  2. Server already included
  3. Zero external dependencies
  4. Zero hosting costs
  5. Zero server management
```

## Summary

- **Architecture**: Monolithic (server + app in single bundle)
- **Runtime**: Server runs as background task within app process
- **Database**: Local SQLite in app's Documents directory
- **Networking**: HTTP via localhost (not exposed externally)
- **Lifecycle**: Controlled by app (starts/stops with app)
- **Deployment**: Standard iOS app deployment (App Store)
- **Cost**: Only app hosting (no separate backend needed)

This represents a fundamental shift from a distributed client-server architecture to a self-contained mobile app architecture.
