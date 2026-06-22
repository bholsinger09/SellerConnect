# Running SellerConnect Locally

## Backend Server Setup

The SellerConnect iOS app requires the backend server to be running for registration and API calls to work.

### Prerequisites
- Swift 5.9+ (comes with Xcode)
- macOS 12+

### Start the Backend Server

1. **Navigate to backend directory:**
   ```bash
   cd SellerConnectBackend
   ```

2. **Run the server:**
   ```bash
   swift run
   ```

   You should see output like:
   ```
   [ NOTICE ] Server starting on http://0.0.0.0:8080
   ```

3. **Verify server is running:**
   ```bash
   curl http://localhost:8080/todos
   ```
   
   Should return a JSON response (empty array initially).

### Frontend App Setup

1. **Ensure backend is running** (see above)

2. **Open the iOS project:**
   ```bash
   open SellerConnect/SellerConnect.xcodeproj/project.xcworkspace
   ```

3. **Build and run in Xcode:**
   - Select "SellerConnect" scheme
   - Choose "My Mac" as the destination (or a simulator)
   - Press Play (Cmd+R) to build and run

### Troubleshooting

#### "Cannot connect to the server" Error
- Verify backend is running: `curl http://localhost:8080/todos`
- Check that backend output shows: `Server starting on http://0.0.0.0:8080`
- Try restarting the backend server

#### Port 8080 Already in Use
```bash
# Find what's using port 8080
lsof -i :8080

# Kill the process if needed
kill -9 <PID>

# Then restart the backend
cd SellerConnectBackend && swift run
```

#### Swift Build Takes Too Long
- First build can take 5-10 minutes due to dependency compilation
- Subsequent builds are faster
- Xcode may appear frozen - this is normal

### Database

The backend uses SQLite with a local file:
- **Location:** `SellerConnectBackend/db.sqlite`
- **Auto-created:** First run creates the database
- **Reset database:** Delete `db.sqlite` and restart server

### Stopping the Server

Press Ctrl+C in the terminal running the server.

### Restarting During Development

After code changes to backend:
1. Stop the server (Ctrl+C)
2. Run `swift run` again
3. Xcode should reload automatically

### Testing the API Manually

```bash
# Register a new user
curl -X POST http://localhost:8080/users \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "email": "john@example.com",
    "password": "SecurePass@123!"
  }'

# Get all users
curl http://localhost:8080/users

# Get specific user
curl http://localhost:8080/users/{id}
```
