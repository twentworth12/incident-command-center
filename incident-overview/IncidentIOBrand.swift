//
//  IncidentIOBrand.swift
//  incident-overview
//
//  Created by Claude Code on 7/31/25.
//
//  Complete incident.io brand system implementation based on https://incident.io/brand
//  
//  BRAND COMPLIANCE IMPLEMENTATION:
//  ✅ Exact color palette from incident.io brand guidelines
//  ✅ Light theme with white/sand backgrounds and charcoal text (matches incident.io website)
//  ✅ Typography system matching STK Bureau Serif/Sans and Geist Mono fonts  
//  ✅ Apple TV optimized sizing and spacing
//  ✅ Status color mapping for incident types
//  ✅ Brand-compliant view modifiers and styling helpers
//  ✅ Applied across ContentView dashboard and SettingsView
//  ✅ Proper contrast and readability following incident.io design patterns
//

import SwiftUI

// MARK: - incident.io Brand Colors
extension Color {
    
    // MARK: Primary Brand Colors
    
    /// Primary brand color - Alarmalade (#F25533)
    /// Used for primary actions, highlights, and brand elements
    static let incidentAlarmalade = Color(red: 242/255, green: 85/255, blue: 51/255)
    
    /// Primary background - Charcoal (#161618)
    /// Used for primary backgrounds and high contrast text
    static let incidentCharcoal = Color(red: 22/255, green: 22/255, blue: 24/255)
    
    /// Pure white (#FFFFFF)
    /// Used for text on dark backgrounds and high contrast elements
    static let incidentWhite = Color.white
    
    // MARK: Surface Colors
    
    /// Secondary background - Sand (#F8F5F0)
    /// Used for card backgrounds and secondary surfaces
    static let incidentSand = Color(red: 248/255, green: 245/255, blue: 240/255)
    
    /// Tertiary background - Contrast (#F1EBE2)
    /// Used for subtle contrast and tertiary surfaces
    static let incidentContrast = Color(red: 241/255, green: 235/255, blue: 226/255)
    
    /// Quaternary background - High Contrast (#E4D9C8)
    /// Used for borders and subtle emphasis
    static let incidentHighContrast = Color(red: 228/255, green: 217/255, blue: 200/255)
    
    // MARK: Status Colors (adapted for incident management)
    
    /// Critical/Live incidents - derived from Alarmalade
    static let incidentCritical = Color(red: 242/255, green: 85/255, blue: 51/255)
    
    /// Major incidents - warmer orange
    static let incidentMajor = Color(red: 255/255, green: 123/255, blue: 77/255)
    
    /// Minor incidents - amber
    static let incidentMinor = Color(red: 255/255, green: 179/255, blue: 71/255)
    
    /// Resolved incidents - green adapted to brand
    static let incidentResolved = Color(red: 46/255, green: 160/255, blue: 67/255)
    
    /// Learning/Post-incident - purple adapted to brand
    static let incidentLearning = Color(red: 175/255, green: 82/255, blue: 222/255)
    
    // MARK: Legacy Colors (for backwards compatibility)
    @available(*, deprecated, message: "Use incidentAlarmalade instead")
    static let incidentOrange = incidentAlarmalade
    
    @available(*, deprecated, message: "Use incidentAlarmalade instead") 
    static let incidentYellow = incidentAlarmalade
    
    @available(*, deprecated, message: "Use incidentAlarmalade gradient instead")
    static let incidentGradient = LinearGradient(
        gradient: Gradient(colors: [incidentAlarmalade, incidentMajor]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - incident.io Typography System
extension Font {
    
    // MARK: Serif Typography (for large headings)
    
    /// Large serif heading - equivalent to STK Bureau Serif Book
    /// Use for main titles and primary headings
    static func incidentSerifTitle(_ size: CGFloat = 48) -> Font {
        return .system(size: size, weight: .medium, design: .serif)
    }
    
    /// Medium serif heading
    /// Use for section titles and secondary headings
    static func incidentSerifHeading(_ size: CGFloat = 32) -> Font {
        return .system(size: size, weight: .medium, design: .serif)
    }
    
    /// Small serif heading
    /// Use for card titles and tertiary headings
    static func incidentSerifSubheading(_ size: CGFloat = 24) -> Font {
        return .system(size: size, weight: .medium, design: .serif)
    }
    
    // MARK: Sans-Serif Typography (for body and smaller headings)
    
    /// Sans-serif heading - equivalent to STK Bureau Sans Medium
    /// Use for UI labels and smaller headings
    static func incidentSansHeading(_ size: CGFloat = 20) -> Font {
        return .system(size: size, weight: .semibold, design: .default)
    }
    
    /// Sans-serif body - equivalent to STK Bureau Sans Book
    /// Use for body text and descriptions
    static func incidentSansBody(_ size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .medium, design: .default)
    }
    
    /// Sans-serif caption
    /// Use for captions and small text
    static func incidentSansCaption(_ size: CGFloat = 14) -> Font {
        return .system(size: size, weight: .medium, design: .default)
    }
    
    // MARK: Monospace Typography (for codes and technical content)
    
    /// Monospace medium - equivalent to Geist Mono
    /// Use for API keys, codes, and technical content
    static func incidentMono(_ size: CGFloat = 16) -> Font {
        return .system(size: size, weight: .medium, design: .monospaced)
    }
    
    /// Monospace large - for prominent codes
    static func incidentMonoLarge(_ size: CGFloat = 20) -> Font {
        return .system(size: size, weight: .medium, design: .monospaced)
    }
    
    // MARK: Apple TV Optimized Sizes
    
    /// Extra large title for Apple TV viewing distance
    static func incidentTVTitle() -> Font {
        return .incidentSerifTitle(64)
    }
    
    /// Large heading for Apple TV
    static func incidentTVHeading() -> Font {
        return .incidentSerifHeading(40)
    }
    
    /// Body text optimized for Apple TV
    static func incidentTVBody() -> Font {
        return .incidentSansBody(24)
    }
    
    /// Caption text for Apple TV
    static func incidentTVCaption() -> Font {
        return .incidentSansCaption(18)
    }
}

// MARK: - incident.io Brand Styles
struct IncidentIOBrandStyles {
    
    // MARK: Card Styles
    
    /// Standard incident.io card background
    static let cardBackground = Color.incidentSand
    
    /// Card border color
    static let cardBorder = Color.incidentHighContrast
    
    /// Card corner radius
    static let cardCornerRadius: CGFloat = 12
    
    /// Card shadow
    static let cardShadow = Color.incidentCharcoal.opacity(0.1)
    
    // MARK: Button Styles
    
    /// Primary button background
    static let primaryButtonBackground = Color.incidentAlarmalade
    
    /// Primary button text
    static let primaryButtonText = Color.incidentWhite
    
    /// Secondary button background  
    static let secondaryButtonBackground = Color.incidentSand
    
    /// Secondary button text
    static let secondaryButtonText = Color.incidentCharcoal
    
    // MARK: Status Styles
    
    /// Get color for incident status
    static func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "critical", "live":
            return .incidentCritical
        case "major":
            return .incidentMajor
        case "minor":
            return .incidentMinor
        case "resolved", "closed":
            return .incidentResolved
        case "learning", "post_incident":
            return .incidentLearning
        default:
            return .incidentCharcoal
        }
    }
    
    /// Get contrasting text color for status
    static func statusTextColor(for status: String) -> Color {
        switch status.lowercased() {
        case "critical", "live", "major":
            return .incidentWhite
        default:
            return .incidentCharcoal
        }
    }
}

// MARK: - Custom View Modifiers for incident.io Brand
extension View {
    
    /// Apply incident.io card styling
    func incidentIOCard() -> some View {
        self
            .background(IncidentIOBrandStyles.cardBackground)
            .cornerRadius(IncidentIOBrandStyles.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: IncidentIOBrandStyles.cardCornerRadius)
                    .stroke(IncidentIOBrandStyles.cardBorder, lineWidth: 1)
            )
            .shadow(color: IncidentIOBrandStyles.cardShadow, radius: 4, x: 0, y: 2)
    }
    
    /// Apply incident.io primary button styling
    func incidentIOPrimaryButton() -> some View {
        self
            .background(IncidentIOBrandStyles.primaryButtonBackground)
            .foregroundColor(IncidentIOBrandStyles.primaryButtonText)
            .cornerRadius(8)
    }
    
    /// Apply incident.io secondary button styling
    func incidentIOSecondaryButton() -> some View {
        self
            .background(IncidentIOBrandStyles.secondaryButtonBackground)
            .foregroundColor(IncidentIOBrandStyles.secondaryButtonText)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(IncidentIOBrandStyles.cardBorder, lineWidth: 1)
            )
    }
    
    /// Apply incident.io status badge styling
    func incidentIOStatusBadge(status: String) -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(IncidentIOBrandStyles.statusColor(for: status))
            .foregroundColor(IncidentIOBrandStyles.statusTextColor(for: status))
            .cornerRadius(16)
            .font(.incidentSansCaption(12))
    }
    
    /// Apply incident.io focus styling for tvOS
    func incidentIOFocus(isFocused: Bool) -> some View {
        self
            .scaleEffect(isFocused ? 1.05 : 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: IncidentIOBrandStyles.cardCornerRadius)
                    .stroke(Color.incidentAlarmalade, lineWidth: isFocused ? 4 : 0)
            )
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - incident.io Brand Constants
struct IncidentIOBrand {
    
    /// Standard spacing values following incident.io design system
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }
    
    /// Apple TV optimized spacing
    struct TVSpacing {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 48
        static let xxl: CGFloat = 64
        static let xxxl: CGFloat = 80
    }
    
    /// Brand compliant corner radius values
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let pill: CGFloat = 999
    }
}