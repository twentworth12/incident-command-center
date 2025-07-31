# Contributing to Incident Command Center

Thank you for your interest in contributing to the Incident Command Center for Apple TV! This document provides guidelines and information for contributors.

## 🎯 How to Contribute

### 🐛 Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title** and description
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Screenshots** if applicable
- **Environment details**:
  - tvOS version
  - Apple TV model
  - Xcode version
  - incident.io API response (sanitized)

### 💡 Suggesting Features

Feature requests are welcome! Please:

- **Check existing issues** for similar requests
- **Describe the problem** your feature would solve
- **Explain your proposed solution** in detail
- **Consider the impact** on tvOS user experience
- **Think about Apple TV constraints** (remote navigation, screen distance, etc.)

### 🔧 Code Contributions

#### Development Setup

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/incident-command-center.git
   cd incident-command-center
   ```
3. **Open in Xcode**:
   ```bash
   open incident-overview.xcodeproj
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

#### Code Guidelines

**Swift Style**
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use clear, descriptive names for variables and functions
- Prefer `let` over `var` when possible
- Use proper access control (`private`, `internal`, `public`)

**SwiftUI for tvOS**
- Use `.focusable()` and `@FocusState` for navigation
- Test with Apple TV remote (or simulator)
- Ensure proper scaling for TV viewing distances
- Use `.buttonStyle(.card)` for focusable buttons
- Consider accessibility for VoiceOver users

**Security**
- Never commit API keys, secrets, or credentials
- Use iOS Keychain for secure storage
- Validate all user inputs
- Handle API errors gracefully
- Follow secure coding practices

**Architecture**
- Keep view logic in SwiftUI views
- Put business logic in separate service classes
- Use proper error handling with `do-catch`
- Prefer composition over inheritance
- Write testable code with dependency injection

#### Testing

- **Write tests** for new functionality
- **Run existing tests** before submitting:
  ```bash
  xcodebuild test -project incident-overview.xcodeproj -scheme incident-overview -destination 'platform=tvOS Simulator,name=Apple TV'
  ```
- **Test on actual Apple TV** when possible
- **Verify accessibility** features work correctly

#### Documentation

- **Update README.md** for user-facing changes
- **Update CLAUDE.md** for development details
- **Add inline comments** for complex logic
- **Document public APIs** with Swift documentation comments

### 📋 Pull Request Process

1. **Ensure your code follows** the guidelines above
2. **Update documentation** as needed
3. **Add tests** for new functionality
4. **Verify all tests pass**
5. **Create a clear PR description**:
   - What changes were made
   - Why they were made
   - How to test them
   - Any breaking changes

6. **Link related issues** using GitHub keywords (e.g., "Fixes #123")

#### PR Review Criteria

- ✅ Code follows Swift and SwiftUI best practices
- ✅ tvOS navigation works correctly with Apple TV remote
- ✅ Security guidelines are followed
- ✅ Tests are included and passing
- ✅ Documentation is updated
- ✅ No breaking changes (or properly documented)
- ✅ Performance impact is acceptable

## 🏗️ Project Structure

```
incident-overview/
├── incident-overview/           # Main app source
│   ├── ContentView.swift       # Main dashboard
│   ├── SettingsView.swift      # API key configuration
│   ├── KeychainManager.swift   # Secure storage
│   ├── IncidentService.swift   # API integration
│   ├── Incident.swift          # Data models
│   └── ...
├── incident-overviewTests/     # Unit tests
├── incident-overviewUITests/   # UI tests
├── CLAUDE.md                   # Development documentation
├── README.md                   # User documentation
└── CONTRIBUTING.md             # This file
```

## 🎨 Design Principles

### tvOS User Experience
- **Large, readable text** for viewing from across the room
- **High contrast colors** for accessibility
- **Simple navigation** optimized for Apple TV remote
- **Focus indicators** that are clearly visible
- **Minimal user input** required

### Incident Management
- **Real-time updates** for critical information
- **Clear status indicators** for quick assessment
- **Prioritization** by severity and urgency
- **Graceful degradation** when API is unavailable

### Security & Privacy
- **User controls their data** (own API keys)
- **Secure storage** using iOS Keychain
- **No data collection** by the app
- **Transparent error handling**

## 🚨 Security

If you discover a security vulnerability, please **DO NOT** create a public issue. Instead:

1. **Email the maintainer** directly with details
2. **Allow time** for the issue to be addressed
3. **Coordinate disclosure** timing if needed

## 📜 Code of Conduct

This project follows a simple code of conduct:

- **Be respectful** to other contributors
- **Focus on constructive feedback**
- **Help create a welcoming environment**
- **Assume good intentions**

## 🆘 Getting Help

- **General questions**: Create a GitHub Discussion
- **Bug reports**: Create a GitHub Issue
- **Feature requests**: Create a GitHub Issue
- **Development help**: Check CLAUDE.md or create a Discussion

## 🎉 Recognition

Contributors will be recognized in:
- GitHub Contributors section
- Release notes for significant contributions
- Special thanks in README for major features

---

**Thank you for contributing to making incident response better for everyone!** 🚀