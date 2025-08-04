# Incident Command Center for Apple TV

<div align="center">

![Apple TV](https://img.shields.io/badge/Apple%20TV-17.0+-black?logo=apple&logoColor=white)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-tvOS-blue?logo=swift&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

**A professional incident management dashboard designed specifically for Apple TV, featuring dual themes and real-time monitoring of your incident.io incidents with war room and retro 80s NORAD command center interfaces.**

[Features](#features) • [Themes](#themes) • [Installation](#installation) • [Usage](#usage) • [Screenshots](#screenshots) • [Contributing](#contributing)

</div>

## 🎯 Overview

Incident Command Center transforms your Apple TV into a powerful incident monitoring display, perfect for command centers, NOCs (Network Operations Centers), and team areas. Built with SwiftUI and optimized for tvOS, it provides an always-on view of your critical incidents with intuitive Apple TV remote navigation.

**🆕 NEW**: Now featuring dual theme system with professional incident.io styling and authentic 80s Wargames/NORAD terminal aesthetics!

## ✨ Features

### 🖥️ **War Room Dashboard**
- **Real-time incident monitoring** with 30-second auto-refresh
- **Large, high-contrast display** optimized for viewing from across the room
- **Color-coded incident status** with pulse animations for critical incidents
- **3-column grid layout** showing up to 12 incidents simultaneously

### 🎮 **Apple TV Optimized**
- **Focus-based navigation** designed for Apple TV remote
- **Voice control** compatible with Siri Remote
- **Scale effects and animations** providing clear visual feedback
- **Play/Pause shortcut** for quick settings access

### 🔐 **Enterprise Security**
- **Secure API key storage** using iOS Keychain Services
- **Device-only keychain access** with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **No hardcoded credentials** - users configure their own incident.io API keys
- **Encrypted communication** with incident.io API

### 📊 **Smart Data Management**
- **Incident prioritization** by severity rank, status urgency, and creation time
- **Mock data fallback** for development and offline scenarios
- **Intelligent error handling** with graceful degradation
- **Efficient API usage** with proper request limiting
- **Metrics dashboard** with 24-hour trend charts and status distribution
- **Consistent card heights** and professional data visualization

## 🎨 Themes

### 🏢 **incident.io Professional Theme**
- Clean, modern design following incident.io brand guidelines
- Professional typography with custom serif and sans-serif fonts
- Warm color palette with incident.io signature colors
- Subtle shadows and rounded corners for premium feel
- Optimized for professional command center environments

### 🖥️ **Wargames 80s NORAD Theme**
- Authentic 80s terminal aesthetic inspired by the movie "WarGames"
- Phosphor green monospace typography on pure black background
- Matrix/UNIX terminal styling with no rounded corners
- Amber alerts for critical incidents (authentic 80s color)
- Perfect for retro command centers and nostalgic monitoring setups
- Animated cursor effects and terminal-style incident displays

### ⚙️ **Theme Switching**
- **Live theme switching** in settings with immediate preview
- **Persistent user preferences** saved between app launches
- **Theme-aware components** that adapt all UI elements
- **Smooth transitions** between theme modes

## 🚀 Installation

### Prerequisites

- **Apple TV (4th generation or later)** running tvOS 17.0+
- **Xcode 16.4+** for building and deployment
- **incident.io account** with API access
- **Apple Developer account** for device deployment

### Building from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/twentworth12/incident-command-center.git
   cd incident-command-center
   ```

2. **Open in Xcode**
   ```bash
   open incident-overview.xcodeproj
   ```

3. **Configure your Apple TV**
   - Connect your Apple TV to the same network as your Mac
   - Enable Developer Mode on Apple TV (Settings > General > Privacy & Security > Developer)
   - Pair your Apple TV with Xcode (Window > Devices and Simulators)

4. **Build and Deploy**
   - Select your Apple TV as the target device
   - Build and run the project (⌘+R)

### Development Commands

```bash
# Build for Apple TV Simulator
xcodebuild -project incident-overview.xcodeproj -scheme incident-overview -sdk appletvsimulator -configuration Debug build

# Build for physical Apple TV device
xcodebuild -project incident-overview.xcodeproj -scheme incident-overview -sdk appletvos -configuration Release build

# Run tests
xcodebuild test -project incident-overview.xcodeproj -scheme incident-overview -destination 'platform=tvOS Simulator,name=Apple TV'
```

## 📱 Usage

### Initial Setup

1. **Launch the app** on your Apple TV
2. **Press Play/Pause** on your remote to access Settings (or navigate to the settings button)
3. **Enter your incident.io API key**:
   - Navigate to the text field
   - Press the center button to activate the keyboard
   - Enter your API key from incident.io dashboard
   - Press "Save API Key"

### Getting Your incident.io API Key

1. Go to your [incident.io dashboard](https://app.incident.io/)
2. Navigate to **Settings > API Keys**
3. Create a new API key with appropriate permissions
4. Copy the key (starts with `inc_`)

### Navigation

- **Arrow keys**: Navigate between incidents and UI elements
- **Center button**: Select/activate focused element
- **Play/Pause**: Quick access to Settings
- **Menu button**: Return to previous screen
- **Remote app**: Use your iPhone as a remote for easier text input

### Dashboard Features

- **Status indicators**: Color-coded badges show incident severity
- **Auto-refresh**: Data updates every 30 seconds automatically  
- **Last updated**: Timestamp shows when data was last refreshed
- **Mock data mode**: Displays sample data when API is unavailable
- **Theme selection**: Switch between incident.io and Wargames themes in settings
- **Metrics cards**: Critical count, active incidents, resolved today, status breakdown, and 24h trends
- **Consistent layouts**: All dashboard cards maintain uniform 200px height

## 📸 Screenshots

*Screenshots coming soon - the app displays a professional war room style interface with incident tiles, status indicators, and navigation optimized for large screen viewing.*

## 🛠️ Technical Architecture

### Core Components

- **`ContentView.swift`**: Main dashboard with dual theme support and incident grid
- **`ThemeManager.swift`**: Complete theme system with ObservableObject pattern
- **`ThemeSelection.swift`**: Theme selection UI with live preview components
- **`IncidentIOBrand.swift`**: Brand consistency system with colors, fonts, and styling
- **`SettingsView.swift`**: API key configuration and theme selection interface
- **`KeychainManager.swift`**: Secure API key storage and retrieval
- **`IncidentService.swift`**: API integration with enhanced security and mock data fallback
- **`Incident.swift`**: Data models with sentence case conversion extensions

### Key Technologies

- **SwiftUI**: Modern UI framework for tvOS
- **iOS Keychain Services**: Secure credential storage
- **URLSession**: HTTP client for API communication
- **Swift Concurrency**: Async/await for network operations
- **Timer**: Auto-refresh functionality

### Security Features

- API keys stored in device keychain only
- No network communication without user consent
- Graceful handling of API failures
- No sensitive data in logs or crash reports
- Enhanced error logging with sanitized messages
- Production-ready security best practices

### Recent Updates

- ✨ **Dual Theme System**: Switch between professional and retro 80s themes
- 🎨 **Brand Consistency**: Complete IncidentIOBrand design system
- 🔧 **UI Improvements**: Fixed grey borders and consistent card heights
- 📊 **Enhanced Charts**: Improved 24-hour trend visualization with sample data
- 🔒 **Security Enhancements**: Removed sensitive data from logging
- 🎯 **UX Polish**: Sentence case conversion and improved information hierarchy

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for any new functionality
5. Ensure all tests pass
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices for tvOS
- Include proper error handling
- Add documentation for public APIs
- Ensure accessibility compliance

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **[incident.io](https://incident.io/)** for providing excellent incident management services
- **Apple** for tvOS and SwiftUI frameworks
- **Swift Community** for best practices and guidance

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/twentworth12/incident-command-center/issues)
- **Documentation**: See [CLAUDE.md](CLAUDE.md) for development details
- **incident.io API**: [Official Documentation](https://api-docs.incident.io/)

---

<div align="center">

**Built with ❤️ for incident response teams**

[⭐ Star this repo](https://github.com/twentworth12/incident-command-center) • [🐛 Report Bug](https://github.com/twentworth12/incident-command-center/issues) • [💡 Request Feature](https://github.com/twentworth12/incident-command-center/issues)

</div>