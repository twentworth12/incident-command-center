//
//  ThemeManager.swift
//  incident-overview
//
//  Created by Claude Code on 8/4/25.
//

import SwiftUI

// MARK: - Theme System
enum AppTheme: String, CaseIterable {
    case incidentIO = "incident.io"
    case wargames = "Wargames"
    
    var displayName: String {
        return self.rawValue
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .incidentIO
    
    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme"
    
    private init() {
        loadTheme()
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        userDefaults.set(theme.rawValue, forKey: themeKey)
    }
    
    private func loadTheme() {
        if let savedTheme = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
}

// MARK: - Theme Protocol
protocol Theme {
    // Background Colors
    var primaryBackground: Color { get }
    var secondaryBackground: Color { get }
    var cardBackground: Color { get }
    var overlayBackground: Color { get }
    
    // Text Colors
    var primaryText: Color { get }
    var secondaryText: Color { get }
    var accentText: Color { get }
    
    // Status Colors
    var criticalColor: Color { get }
    var majorColor: Color { get }
    var minorColor: Color { get }
    var resolvedColor: Color { get }
    var unknownColor: Color { get }
    
    // Accent Colors
    var primaryAccent: Color { get }
    var secondaryAccent: Color { get }
    
    // Typography
    var titleFont: (CGFloat) -> Font { get }
    var headingFont: (CGFloat) -> Font { get }
    var bodyFont: (CGFloat) -> Font { get }
    var captionFont: (CGFloat) -> Font { get }
    var monoFont: (CGFloat) -> Font { get }
    
    // Layout
    var cornerRadius: CGFloat { get }
    var borderWidth: CGFloat { get }
    var shadowRadius: CGFloat { get }
    
    // Special Effects
    var shouldFlash: Bool { get }
    var animationDuration: Double { get }
}

// MARK: - incident.io Theme
struct IncidentIOTheme: Theme {
    var primaryBackground: Color { .incidentSand }
    var secondaryBackground: Color { .incidentWhite }
    var cardBackground: Color { .incidentWhite }
    var overlayBackground: Color { .incidentContrast }
    
    var primaryText: Color { .incidentCharcoal }
    var secondaryText: Color { .incidentCharcoal.opacity(0.7) }
    var accentText: Color { .incidentAlarmalade }
    
    var criticalColor: Color { .incidentCritical }
    var majorColor: Color { .incidentMajor }
    var minorColor: Color { .incidentMinor }
    var resolvedColor: Color { .incidentResolved }
    var unknownColor: Color { .gray }
    
    var primaryAccent: Color { .incidentAlarmalade }
    var secondaryAccent: Color { .incidentMajor }
    
    var titleFont: (CGFloat) -> Font { { Font.incidentSerifTitle($0) } }
    var headingFont: (CGFloat) -> Font { { Font.incidentSerifHeading($0) } }
    var bodyFont: (CGFloat) -> Font { { Font.incidentSansBody($0) } }
    var captionFont: (CGFloat) -> Font { { Font.incidentSansCaption($0) } }
    var monoFont: (CGFloat) -> Font { { Font.incidentMono($0) } }
    
    var cornerRadius: CGFloat { IncidentIOBrand.CornerRadius.large }
    var borderWidth: CGFloat { 1 }
    var shadowRadius: CGFloat { 8 }
    
    var shouldFlash: Bool { true }
    var animationDuration: Double { 0.2 }
}

// MARK: - Wargames Theme (80s NORAD/Matrix Style)
struct WargamesTheme: Theme {
    var primaryBackground: Color { Color.black }
    var secondaryBackground: Color { Color.black }
    var cardBackground: Color { Color.black }
    var overlayBackground: Color { Color.black }
    
    var primaryText: Color { Color(red: 0, green: 1, blue: 0) } // Bright Matrix green
    var secondaryText: Color { Color(red: 0, green: 0.9, blue: 0) } // Slightly dimmer green
    var accentText: Color { Color(red: 0, green: 1, blue: 0) } // Same bright green
    
    var criticalColor: Color { Color(red: 1, green: 0.8, blue: 0) } // Amber for critical (rare 80s color)
    var majorColor: Color { Color(red: 0, green: 1, blue: 0) } // Bright green
    var minorColor: Color { Color(red: 0, green: 0.8, blue: 0) } // Dimmer green
    var resolvedColor: Color { Color(red: 0, green: 0.7, blue: 0) } // Resolved green
    var unknownColor: Color { Color(red: 0, green: 0.5, blue: 0) } // Dim green
    
    var primaryAccent: Color { Color(red: 0, green: 1, blue: 0) } // Matrix green
    var secondaryAccent: Color { Color(red: 0, green: 1, blue: 0) } // Matrix green
    
    var titleFont: (CGFloat) -> Font { { Font.system(size: $0, weight: .bold, design: .monospaced) } }
    var headingFont: (CGFloat) -> Font { { Font.system(size: $0, weight: .bold, design: .monospaced) } }
    var bodyFont: (CGFloat) -> Font { { Font.system(size: $0, weight: .medium, design: .monospaced) } }
    var captionFont: (CGFloat) -> Font { { Font.system(size: $0, weight: .regular, design: .monospaced) } }
    var monoFont: (CGFloat) -> Font { { Font.system(size: $0, weight: .medium, design: .monospaced) } }
    
    var cornerRadius: CGFloat { 0 } // No rounding - pure terminal
    var borderWidth: CGFloat { 1 }
    var shadowRadius: CGFloat { 0 } // No shadows in terminal UI
    
    var shouldFlash: Bool { true }
    var animationDuration: Double { 0.3 } // Slightly slower for that retro feel
}

// MARK: - Theme Extension for SwiftUI
extension View {
    @ViewBuilder
    func themedBackground(_ theme: Theme) -> some View {
        self.background(theme.primaryBackground)
    }
    
    @ViewBuilder
    func themedCardBackground(_ theme: Theme) -> some View {
        self
            .background(theme.cardBackground)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.secondaryText.opacity(0.3), lineWidth: theme.borderWidth)
            )
    }
    
    @ViewBuilder
    func themedText(_ theme: Theme, style: TextStyle = .primary) -> some View {
        switch style {
        case .primary:
            self.foregroundColor(theme.primaryText)
        case .secondary:
            self.foregroundColor(theme.secondaryText)
        case .accent:
            self.foregroundColor(theme.accentText)
        }
    }
}

enum TextStyle {
    case primary, secondary, accent
}

// MARK: - Current Theme Access
extension ThemeManager {
    var theme: Theme {
        switch currentTheme {
        case .incidentIO:
            return IncidentIOTheme()
        case .wargames:
            return WargamesTheme()
        }
    }
}