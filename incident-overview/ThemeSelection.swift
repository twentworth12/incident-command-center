//
//  ThemeSelection.swift
//  incident-overview
//
//  Created by Claude Code on 8/4/25.
//

import SwiftUI

struct ThemeSelectionSection: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @FocusState private var focusedTheme: AppTheme?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Theme selection")
                    .font(.incidentTVHeading())
                    .foregroundColor(.incidentCharcoal)
                
                Text("Choose your visual style. Changes apply immediately.")
                    .font(.incidentTVBody())
                    .foregroundColor(.incidentCharcoal.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            VStack(spacing: 20) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    ThemeOptionButton(
                        theme: theme,
                        isSelected: themeManager.currentTheme == theme,
                        isFocused: focusedTheme == theme,
                        onSelect: {
                            themeManager.setTheme(theme)
                        }
                    )
                    .focused($focusedTheme, equals: theme)
                }
            }
        }
    }
}

struct ThemeOptionButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let isFocused: Bool
    let onSelect: () -> Void
    
    private var themePreview: Theme {
        switch theme {
        case .incidentIO:
            return IncidentIOTheme()
        case .wargames:
            return WargamesTheme()
        }
    }
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 24) {
                // Theme preview with NORAD-style elements for Wargames
                VStack(spacing: 12) {
                    if theme == .wargames {
                        // NORAD-style radar sweep or grid
                        ZStack {
                            Rectangle()
                                .fill(themePreview.cardBackground)
                                .frame(width: 80, height: 60)
                                .overlay(
                                    // Simulated radar grid
                                    VStack(spacing: 4) {
                                        ForEach(0..<4) { _ in
                                            Rectangle()
                                                .fill(themePreview.primaryText.opacity(0.3))
                                                .frame(height: 1)
                                        }
                                    }
                                )
                            
                            // Status indicators
                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(themePreview.criticalColor)
                                    .frame(width: 8, height: 8)
                                Rectangle()
                                    .fill(themePreview.majorColor)
                                    .frame(width: 8, height: 8)
                                Rectangle()
                                    .fill(themePreview.resolvedColor)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .cornerRadius(themePreview.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: themePreview.cornerRadius)
                                .stroke(themePreview.primaryText, lineWidth: themePreview.borderWidth)
                        )
                        
                        Text("TERMINAL")
                            .font(themePreview.captionFont(10))
                            .foregroundColor(themePreview.primaryText)
                    } else {
                        // incident.io style preview
                        HStack(spacing: 8) {
                            Circle()
                                .fill(themePreview.criticalColor)
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(themePreview.majorColor)
                                .frame(width: 16, height: 16)
                            Circle()
                                .fill(themePreview.resolvedColor)
                                .frame(width: 16, height: 16)
                        }
                        .padding(16)
                        .background(themePreview.cardBackground)
                        .cornerRadius(themePreview.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: themePreview.cornerRadius)
                                .stroke(themePreview.secondaryText.opacity(0.3), lineWidth: themePreview.borderWidth)
                        )
                        
                        Text("Sample")
                            .font(themePreview.bodyFont(14))
                            .foregroundColor(themePreview.primaryText)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(theme.displayName)
                        .font(.incidentSansHeading())
                        .foregroundColor(.incidentCharcoal)
                    
                    Text(themeDescription)
                        .font(.incidentSansBody())
                        .foregroundColor(.incidentCharcoal.opacity(0.7))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.incidentResolved)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                    .fill(isSelected ? Color.incidentResolved.opacity(0.1) : Color.incidentSand.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: IncidentIOBrand.CornerRadius.large)
                            .stroke(
                                isFocused ? Color.incidentAlarmalade : 
                                isSelected ? Color.incidentResolved : Color.clear,
                                lineWidth: isFocused ? 4 : (isSelected ? 2 : 0)
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
    
    private var themeDescription: String {
        switch theme {
        case .incidentIO:
            return "Clean, professional design following incident.io brand guidelines"
        case .wargames:
            return "Retro 80s terminal style inspired by NORAD command centers from WarGames"
        }
    }
}