# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a tvOS SwiftUI application called "incident-overview" that provides an incident management dashboard for Apple TV. The app displays real-time incident data from the incident.io API with a focus-based navigation interface optimized for TV remote control.

## Architecture

- **App Entry Point**: `incident_overviewApp.swift` - Main app file with simple WindowGroup setup
- **Main UI**: `ContentView.swift` - Main dashboard with war room style interface, includes multiple view components
- **Data Models**: `Incident.swift` - Codable models for incident.io API data with extensions for date formatting
- **API Service**: `IncidentService.swift` - Service class for API calls (currently using mock data)
- **UI Components**: Multiple custom views within ContentView.swift including WarRoomHeader, WarRoomIncidentTile, WarRoomIncidentDetail
- **Additional Views**: IncidentDetailView.swift, IncidentRowView.swift (separate component files)
- **Testing**: Separate unit tests (Testing framework) and UI tests (XCTest framework)

## Development Commands

### Building and Running
```bash
# Build the project for Apple TV Simulator (requires tvOS SDK and simulators)
xcodebuild -project incident-overview.xcodeproj -scheme incident-overview -sdk appletvsimulator -configuration Debug build

# Build for physical Apple TV device  
xcodebuild -project incident-overview.xcodeproj -scheme incident-overview -sdk appletvos -configuration Release build

# Clean build folder
xcodebuild -project incident-overview.xcodeproj -scheme incident-overview clean

# Note: Open the project in Xcode for easier development and testing with Apple TV Simulator
open incident-overview.xcodeproj
```

### Testing
```bash
# Run unit tests on Apple TV Simulator
xcodebuild test -project incident-overview.xcodeproj -scheme incident-overview -destination 'platform=tvOS Simulator,name=Apple TV'

# Run specific test target
xcodebuild test -project incident-overview.xcodeproj -scheme incident-overview -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:incident-overviewTests

# Run UI tests
xcodebuild test -project incident-overview.xcodeproj -scheme incident-overview -destination 'platform=tvOS Simulator,name=Apple TV' -only-testing:incident-overviewUITests
```

## Key Technical Details

- **Target Platform**: tvOS 17.0+, built with Xcode 16.4
- **UI Framework**: SwiftUI with NavigationView and focus-based navigation
- **Data Source**: incident.io API with real-time incident data (currently using mock data fallback)
- **Testing Frameworks**: Swift Testing (unit tests) + XCTest (UI tests)
- **Bundle ID**: tomwentworth.incident-overview
- **API Authentication**: Uses Bearer token authentication for incident.io API

## Code Structure and Key Features

### UI Design
- **War Room Dashboard**: Command center style interface with large fonts, high contrast colors
- **Focus-based Navigation**: Optimized for Apple TV remote with focusable elements and scale effects
- **Real-time Updates**: Auto-refreshes every 30 seconds via Timer
- **Status Indicators**: Color-coded status badges with pulse animations for critical incidents
- **Grid Layout**: 3-column grid for incident tiles on main dashboard

### Data Flow
- ContentView manages the main state and data fetching
- Direct API calls to incident.io with fallback to mock data on error
- Incident sorting by priority (severity rank), status urgency, and creation time
- Real-time updates with loading states and last updated timestamps

### API Integration
- Currently has API integration code but falls back to mock data
- Bearer token embedded in code (should be externalized for production)
- Handles up to 12 incidents from API response
- Error handling with fallback to mock data

### Navigation Patterns
- Main dashboard shows incident grid
- Drill-down to detailed incident view
- Back navigation with focus management
- All views optimized for TV viewing distances (large fonts, spacing)