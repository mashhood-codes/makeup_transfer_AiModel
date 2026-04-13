# Quick Reference: GlowUp AI AR Fix Summary

## Critical Issues Found

| Issue | File | Line | Severity | Fix Time |
|-------|------|------|----------|----------|
| Double URL Bug | transfer_screen.dart | 451 | P0 CRITICAL | 2 min |
| GoRouter Incompatibility | parlour_listing.dart | 20 | P1 HIGH | 45 min |
| GoRouter Incompatibility | parlour_detail.dart | 23 | P1 HIGH | 45 min |
| GoRouter Incompatibility | booking_screen.dart | N/A | P1 HIGH | 45 min |
| Filter Flow Stub | search_filter_screen.dart | All | P1 HIGH | 30 min |
| Password Toggle Missing | login_screen.dart | 73-81 | P2 MEDIUM | 10 min |
| Hardcoded API Key | places_service.dart | 8 | SECURITY | 10 min |
| Missing Error Handling | transfer_screen.dart | 158-166 | P2 MEDIUM | 10 min |

## Files to Create

1. `lib/models/parlour_model.dart` - Parlour data model
2. `lib/services/parlour_service.dart` - Parlour API service
3. `.env` - Environment configuration (for API key)

## Files to Modify

1. `lib/screens/transfer_screen.dart` - Fix URL bug + error handling
2. `lib/screens/parlour_listing.dart` - GoRouter migration
3. `lib/screens/parlour_detail.dart` - GoRouter migration
4. `lib/screens/booking_screen.dart` - GoRouter migration + data binding
5. `lib/screens/search_filter_screen.dart` - Implement filter flow
6. `lib/screens/auth/login_screen.dart` - Password visibility toggle
7. `lib/main.dart` - Add GoRouter parameters
8. `.gitignore` - Add .env

## Implementation Order

### 1. Critical Fix (2 min)
Change transfer_screen.dart line 451:
```dart
// From:
'${ ApiConfig.baseUrl}$_resultImageUrl'
// To:
_resultImageUrl!
```

### 2. Models & Services (30 min)
- Create `parlour_model.dart` - 25 lines
- Create `parlour_service.dart` - 50 lines

### 3. Routes (15 min)
- Update `main.dart` - Change 6 GoRoute definitions to accept parameters

### 4. Screens (2 hours)
- Update `parlour_listing.dart` - 130 lines (new)
- Update `parlour_detail.dart` - 140 lines (new)
- Update `booking_screen.dart` - 160 lines (new)
- Update `search_filter_screen.dart` - 150 lines (new)

### 5. Auth Screens (15 min)
- Add password toggle to `login_screen.dart`

### 6. Security & Polish (20 min)
- Move API key to .env
- Add error handling improvements

## Expected Outcomes

After all fixes:
- ✅ Makeup transfer results display correctly
- ✅ All navigation uses GoRouter (consistent)
- ✅ Users can search parlours by city
- ✅ Full parlour booking flow works
- ✅ Filter preview shows before applying
- ✅ Better error messages
- ✅ API key secured
- ✅ All screens responsive

## Verification Steps

1. Run `flutter clean && flutter pub get`
2. Navigate through entire app flow
3. Verify each screen loads data correctly
4. Test error scenarios (offline, timeout)
5. Check all button navigation works
6. Verify images load (makeup result + parlour images)

## Notes

- App uses GoRouter (not Navigator) - all screens must follow this pattern
- Places API uses hardcoded key - move to .env before release
- Parlour data comes from Google Places API - ensure quota sufficient
- All screens use Material Design 3 - maintain consistency
- Maintains existing error logging with print statements

