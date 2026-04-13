# Implementation Checklist & Git Commands

## Pre-Implementation Setup

```bash
# 1. Create feature branch
git checkout -b fix/core-issues

# 2. Verify current state
git status
git log --oneline -5

# 3. Install missing dependency (if needed)
# flutter pub add flutter_dotenv
```

---

## Phase 1: Critical URL Bug Fix (2 min)

### Task 1.1: Fix transfer_screen.dart

**File**: `lib/screens/transfer_screen.dart`

**Line 451 - Change FROM:**
```dart
child: Image.network(
  '${ ApiConfig.baseUrl}$_resultImageUrl',
  fit: BoxFit.cover,
```

**Change TO:**
```dart
child: Image.network(
  _resultImageUrl!,
  fit: BoxFit.cover,
```

**Why**: makeup_api.dart (line 96) already returns full URL including baseUrl

**Verification**:
```bash
# Test in app
# 1. Select image
# 2. Select style
# 3. Apply makeup
# 4. Verify result image loads (no 404)
```

**Commit**:
```bash
git add glowup_ai_ar/lib/screens/transfer_screen.dart
git commit -m "fix(transfer): remove duplicate baseUrl from result image URL

- makeup_api.transferMakeup() returns full URL including baseUrl
- transfer_screen was prepending baseUrl again, causing 404
- Now uses _resultImageUrl directly from API response"
```

---

## Phase 2: Create Data Models & Services (45 min)

### Task 2.1: Create Parlour Model

**File**: `lib/models/parlour_model.dart`

**Content**: [See FIX_PLAN.md section "Step 1: Create Parlour Data Model"]

**Checklist**:
- [ ] File created at correct path
- [ ] All fields match Google Places API response
- [ ] fromJson factory method works correctly
- [ ] No syntax errors (dart analyze)

**Commit**:
```bash
git add glowup_ai_ar/lib/models/parlour_model.dart
git commit -m "feat(models): add Parlour data model

- Represents beauty salon/parlour data
- Converts from Google Places API response
- Fields: id, name, address, rating, services, phone, hours"
```

### Task 2.2: Create Parlour Service

**File**: `lib/services/parlour_service.dart`

**Content**: [See FIX_PLAN.md section "Step 2: Create Parlour Service"]

**Checklist**:
- [ ] File created at correct path
- [ ] searchParlours() method returns List<Parlour>
- [ ] getParlourDetails() method works
- [ ] Error handling included
- [ ] No syntax errors (dart analyze)

**Commit**:
```bash
git add glowup_ai_ar/lib/services/parlour_service.dart
git commit -m "feat(services): add parlour API service

- Integrates with Google Places API
- searchParlours(city) - find salons in a city
- getParlourDetails(placeId) - get full parlour info
- Returns Parlour model instances"
```

---

## Phase 3: Update Router Configuration (15 min)

### Task 3.1: Update main.dart Routes

**File**: `lib/main.dart`

**Changes**:
1. Replace lines 98-113 with new GoRoute definitions (see FIX_PLAN.md)
2. Add path parameters for `:city` and `:parlourId`
3. Extract parameters in builder functions

**Checklist**:
- [ ] All 4 route definitions updated
- [ ] Path parameters use correct format (`:paramName`)
- [ ] Builder functions extract parameters correctly
- [ ] Existing routes unchanged
- [ ] Compilation succeeds

**Testing**:
```dart
// Test URLs
/parlour-listing/Karachi
/parlour-detail/ChIJPZr4LiqYvzohIX2y5JlAjOc
/booking/ChIJPZr4LiqYvzohIX2y5JlAjOc
```

**Commit**:
```bash
git add glowup_ai_ar/lib/main.dart
git commit -m "feat(routing): add GoRouter parameters for parlour screens

- parlour-listing/:city - pass city name
- parlour-detail/:parlourId - pass place_id
- booking/:parlourId - pass place_id
- Enables data passing between screens via URL"
```

---

## Phase 4: Migrate Parlour Screens (1.5 hours)

### Task 4.1: Rewrite parlour_listing.dart

**File**: `lib/screens/parlour_listing.dart`

**Changes**:
1. Add `city` parameter to constructor
2. Remove `ModalRoute.of(context)` usage
3. Use `ParlourService.searchParlours(city)`
4. Convert tap navigation to GoRouter
5. Add UI improvements (rating display, services chips, etc.)

**Checklist**:
- [ ] Constructor accepts city parameter
- [ ] initState uses city from parameter
- [ ] No ModalRoute usage
- [ ] Navigation uses `context.go('/parlour-detail/${parlour.id}')`
- [ ] Proper error handling
- [ ] Loading state shown
- [ ] Empty state handled
- [ ] All UI matches mockup
- [ ] No unused imports

**Testing**:
```bash
# Test flow:
# 1. Search Filter Screen → enter "Karachi"
# 2. Navigate to /parlour-listing/Karachi
# 3. List of parlours loads
# 4. Tap parlour → navigate to detail screen
```

**Commit**:
```bash
git add glowup_ai_ar/lib/screens/parlour_listing.dart
git commit -m "refactor(screens): migrate parlour_listing to GoRouter

- Accept city as route parameter
- Use ParlourService.searchParlours() instead of PlacesService
- Remove ModalRoute dependency
- Convert navigation to context.go()
- Add rating display, service chips
- Improve error and loading states"
```

### Task 4.2: Rewrite parlour_detail.dart

**File**: `lib/screens/parlour_detail.dart`

**Changes**:
1. Add `parlourId` parameter to constructor
2. Fetch full parlour details using service
3. Convert booking navigation to GoRouter
4. Display all parlour information
5. Better error handling

**Checklist**:
- [ ] Constructor accepts parlourId parameter
- [ ] Fetches data in initState
- [ ] No Navigator.pushNamed usage
- [ ] Navigation uses `context.go('/booking/${parlour.id}')`
- [ ] All parlour details displayed
- [ ] Services shown as chips
- [ ] Proper error handling
- [ ] Loading state shown
- [ ] No unused imports

**Testing**:
```bash
# Test flow:
# 1. From listing → tap parlour
# 2. Detail screen loads with parlour info
# 3. Click "Book Now" → navigate to booking screen
```

**Commit**:
```bash
git add glowup_ai_ar/lib/screens/parlour_detail.dart
git commit -m "refactor(screens): migrate parlour_detail to GoRouter

- Accept parlourId as route parameter
- Fetch parlour details using ParlourService
- Remove Navigator.pushNamed dependency
- Convert booking navigation to context.go()
- Display all parlour details (name, rating, address, hours, services)
- Add error and loading states"
```

### Task 4.3: Rewrite booking_screen.dart

**File**: `lib/screens/booking_screen.dart`

**Changes**:
1. Add `parlourId` parameter to constructor
2. Fetch parlour details for reference
3. Add service selection from parlour's service list
4. Add date picker
5. Add time picker
6. Add booking confirmation logic
7. Convert navigation to GoRouter

**Checklist**:
- [ ] Constructor accepts parlourId parameter
- [ ] Fetches parlour details
- [ ] Date picker works
- [ ] Time picker works
- [ ] Service dropdown populated from parlour data
- [ ] Confirm booking handles validation
- [ ] Shows confirmation dialog
- [ ] Navigation after booking uses `context.go('/home')`
- [ ] No unused imports
- [ ] Proper error handling

**Testing**:
```bash
# Test flow:
# 1. From detail → click "Book Now"
# 2. Booking screen shows parlour name
# 3. Select service, date, time
# 4. Click "Confirm Booking" → shows confirmation
# 5. Navigate back to home
```

**Commit**:
```bash
git add glowup_ai_ar/lib/screens/booking_screen.dart
git commit -m "refactor(screens): rewrite booking_screen with GoRouter support

- Accept parlourId as route parameter
- Fetch and display parlour details
- Add date and time pickers
- Service dropdown uses parlour's actual services
- Proper validation before booking
- Confirmation dialog with feedback
- Navigate back to home after booking"
```

---

## Phase 5: Implement Filter Flow (30 min)

### Task 5.1: Rewrite search_filter_screen.dart

**File**: `lib/screens/search_filter_screen.dart`

**Changes**:
1. Add city/location input
2. Add service filter dropdown
3. Add distance filter
4. Add rating filter slider
5. Add filter preview dialog
6. Navigate to listing with filters applied

**Checklist**:
- [ ] City input field present
- [ ] Service dropdown with all services
- [ ] Distance input with number keyboard
- [ ] Rating slider (0-5 stars)
- [ ] Preview dialog shows selected filters
- [ ] "See Results" navigates to listing with city
- [ ] Reset button clears all filters
- [ ] All controllers properly disposed
- [ ] No unused imports

**Testing**:
```bash
# Test flow:
# 1. Click "Search Filter" from home
# 2. Enter city name (e.g., "Karachi")
# 3. Select service filter (optional)
# 4. Click "See Results"
# 5. Preview dialog shows filters
# 6. Click "Search"
# 7. Navigate to parlour listing
```

**Commit**:
```bash
git add glowup_ai_ar/lib/screens/search_filter_screen.dart
git commit -m "feat(screens): implement complete filter flow UX

- City/location search with validation
- Service type filter dropdown
- Distance and rating filters
- Filter preview before applying
- Navigate to listing with selected city
- Reset button to clear filters
- Proper error messages and validation"
```

---

## Phase 6: Login Screen Polish (10 min)

### Task 6.1: Add Password Visibility Toggle

**File**: `lib/screens/auth/login_screen.dart`

**Changes**:
1. Add `_showPassword` state variable
2. Add visibility toggle button
3. Update password field to use toggled obscureText

**Checklist**:
- [ ] State variable added
- [ ] Suffix icon button added to password field
- [ ] Toggle works correctly
- [ ] Icon changes (visibility/visibility_off)
- [ ] Compilation succeeds

**Testing**:
```bash
# Test:
# 1. Open login screen
# 2. Type in password field
# 3. Click visibility icon
# 4. Password becomes visible
# 5. Click again → hidden
```

**Commit**:
```bash
git add glowup_ai_ar/lib/screens/auth/login_screen.dart
git commit -m "feat(auth): add password visibility toggle

- Adds suffix icon button to password field
- Toggle shows/hides password text
- Icon updates based on state"
```

---

## Phase 7: Security & Error Handling (20 min)

### Task 7.1: Move API Key to Environment

**File**: `.env` (NEW)

**Content**:
```
GOOGLE_PLACES_API_KEY=AIzaSyD05nk8icrnwPG0Xc4FMUabmJoySdjfalA
```

**Checklist**:
- [ ] .env file created in project root
- [ ] Contains API key
- [ ] Added to .gitignore

### Task 7.2: Update Dependencies

**File**: `pubspec.yaml`

**Changes**:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

**Command**:
```bash
flutter pub add flutter_dotenv
```

### Task 7.3: Update main.dart for .env

**File**: `lib/main.dart`

**Changes**:
1. Import flutter_dotenv
2. Load .env in main()

**Code**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");  // ADD THIS
  // ... rest of main
}
```

### Task 7.4: Update parlour_service.dart

**File**: `lib/services/parlour_service.dart`

**Changes**:
Replace hardcoded API key with env variable

**Code**:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ParlourService {
  static String get apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
  // ... rest of class
}
```

### Task 7.5: Update .gitignore

**File**: `.gitignore`

**Add**:
```
.env
```

### Task 7.6: Improve Error Messages in transfer_screen.dart

**File**: `lib/screens/transfer_screen.dart` (lines 158-166)

**Changes**: [See FIX_PLAN.md section "1. Better Error Messages"]

**Checklist**:
- [ ] Error handling updated
- [ ] Better error messages for common scenarios
- [ ] Retry button on error SnackBar

**Commit**:
```bash
git add .env
git add glowup_ai_ar/pubspec.yaml
git add glowup_ai_ar/lib/main.dart
git add glowup_ai_ar/lib/services/parlour_service.dart
git add .gitignore
git commit -m "security: move Google Places API key to environment

- Create .env file for API key
- Add flutter_dotenv dependency
- Load .env in main() on app startup
- Update ParlourlService to read from environment
- Add .env to .gitignore to prevent accidental commits"
```

---

## Final Verification

### Code Quality Checks

```bash
# Run analyzer
flutter analyze

# Format code
dart format lib/

# Check for unused imports
grep -r "^import\|^export" lib/ | sort | uniq
```

### Testing Checklist

#### Test 1: Makeup Transfer Flow
- [ ] Open app → Transfer Screen
- [ ] Select image
- [ ] Select style
- [ ] Apply makeup
- [ ] Result image loads correctly (no 404)
- [ ] No double URL in logs

#### Test 2: Parlour Search Flow
- [ ] Open app → home
- [ ] Tap search/filter button
- [ ] Navigate to search filter screen
- [ ] Enter city name
- [ ] Adjust filters (optional)
- [ ] Click "See Results"
- [ ] Preview dialog appears
- [ ] Navigate to parlour listing
- [ ] List loads with parlours
- [ ] No errors in logs

#### Test 3: Parlour Booking Flow
- [ ] From listing → tap parlour
- [ ] Detail screen loads
- [ ] Shows all parlour info
- [ ] Click "Book Now"
- [ ] Booking screen loads
- [ ] Parlour name displays
- [ ] Service dropdown populated
- [ ] Select date/time/service
- [ ] Click "Confirm Booking"
- [ ] Confirmation shows
- [ ] Navigate back to home

#### Test 4: Login Screen
- [ ] Open login screen
- [ ] Type password
- [ ] Click visibility icon
- [ ] Password becomes visible
- [ ] No layout issues

#### Test 5: Error Scenarios
- [ ] No internet → try transfer → see error message with retry
- [ ] Invalid city in search → see error message
- [ ] Empty fields in forms → see validation messages

### Device/Screen Size Testing

```bash
# Test on multiple device sizes:
flutter run -d <device_id>

# Common sizes to test:
# - 5" phone (375px width)
# - 6" phone (390px width)  
# - 7" tablet (600px width)
# - Landscape orientation
```

---

## Rollback Plan (If Needed)

```bash
# If major issues occur, revert to last known good:
git reset --hard a74531e

# Or revert specific file:
git checkout a74531e -- lib/screens/transfer_screen.dart

# Check what was reverted:
git log --oneline -3
```

---

## Final Commit & Push

```bash
# View all changes
git status

# Create final summary commit
git add -A
git commit -m "refactor(app): complete GoRouter migration and fix critical bugs

Major changes:
- Fix double URL bug in makeup result display
- Create Parlour data model and service layer
- Migrate all parlour screens to GoRouter pattern
- Implement complete filter flow with preview
- Add password visibility toggle to login
- Move API key to environment configuration
- Improve error handling and messages

Files modified: 10
Files created: 3
Issues fixed: 6

Test: All flows verified end-to-end"

# Push to feature branch
git push -u origin fix/core-issues

# Create PR on GitHub
gh pr create --title "fix: critical bugs and GoRouter migration" \\
  --body "Comprehensive fix for 6 issues including critical double URL bug and GoRouter incompatibility"
```

---

## Documentation Updates

After all fixes, update:
1. `README.md` - Add feature documentation
2. `docs/ARCHITECTURE.md` - Document GoRouter usage
3. `docs/API_INTEGRATION.md` - Document Parlour service

---

## Notes for Implementation

- ✅ Use `context.go()` for all navigation (never use Navigator)
- ✅ Always extract route parameters in GoRoute builder
- ✅ Handle null safely when accessing route parameters
- ✅ Test each phase before moving to next
- ✅ Commit after each major component
- ✅ Keep error logging consistent with existing format
- ✅ Verify no API key leaks in logs

