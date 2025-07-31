//
//  IncidentRowView.swift
//  incident-overview
//
//  Created by Claude Code on 7/30/25.
//

import SwiftUI

struct IncidentRowView: View {
    let incident: Incident
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                // Incident name
                Text(incident.name)
                    .font(.headline)
                    .lineLimit(2)
                
                // Status and severity
                HStack(spacing: 8) {
                    Text(incident.safeStatus.name)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                    
                    if let severity = incident.severity {
                        Text("P\(severity.rank ?? 0)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                // Created date
                if let createdDate = incident.formattedCreatedDate {
                    Text(createdDate, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch incident.safeStatus.category.lowercased() {
        case "live", "investigating":
            return .red
        case "monitoring":
            return .orange
        case "resolved", "closed":
            return .green
        default:
            return .gray
        }
    }
}