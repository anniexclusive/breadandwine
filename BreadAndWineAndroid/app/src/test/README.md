# BreadAndWine Android Tests

Simple unit tests for the BreadAndWine Android app.

## Test Coverage

### SettingsViewModelTest
- Tests notification toggle logic
- Verifies state management
- Tests all three notification types (master, morning, nugget)

### DevotionalModelTest
- Tests data model helper methods
- Verifies HTML stripping from titles
- Tests date formatting
- Tests content preview generation
- Verifies banner image URL extraction

### DevotionalCacheTest
- Tests settings persistence
- Verifies default values
- Tests data class integrity

### NotificationSchedulerTest
- Tests notification scheduling logic
- Verifies alarm creation
- Tests custom message support
- Verifies cancellation logic

## Running Tests

### Android Studio
1. Right-click on `app/src/test` directory
2. Select "Run 'Tests in 'test''"

### Command Line
```bash
./gradlew test
```

### Run Specific Test Class
```bash
./gradlew test --tests SettingsViewModelTest
```

### View Test Report
After running tests, open:
```
app/build/reports/tests/testDebugUnitTest/index.html
```

## Dependencies
- JUnit 4
- Kotlin Test
- MockK (mocking framework)
- Coroutines Test
- AndroidX Core Testing

## Notes
- Tests use MockK for mocking Android components
- Coroutine tests use TestDispatcher for deterministic execution
- Tests are isolated and don't require device/emulator
- All tests follow Given-When-Then structure for clarity
