import Foundation
import SwiftUI

struct VolumeInfo: Identifiable {
    let id: String
    let name: String
    let totalBytes: Int64
    let freeBytes: Int64
    let icon: String

    var usedBytes: Int64 { totalBytes - freeBytes }
    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var freeFormatted: String {
        ByteCountFormatter.string(fromByteCount: freeBytes, countStyle: .file)
    }

    var totalFormatted: String {
        ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)
    }

    var usedFormatted: String {
        ByteCountFormatter.string(fromByteCount: usedBytes, countStyle: .file)
    }

    var usageColor: Color {
        switch usedFraction {
        case 0..<0.6: return .green
        case 0.6..<0.8: return .yellow
        case 0.8..<0.9: return .orange
        default: return .red
        }
    }

    var usageGradient: LinearGradient {
        switch usedFraction {
        case 0..<0.6:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        case 0.6..<0.8:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
        case 0.8..<0.9:
            return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        default:
            return LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing)
        }
    }
}

struct DiskSpaceProvider {
    static func getVolumes() -> [VolumeInfo] {
        let fileManager = FileManager.default
        let keys: [URLResourceKey] = [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeIsRemovableKey,
            .volumeIsInternalKey,
            .volumeIsLocalKey
        ]

        guard let mountedVolumes = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        ) else {
            return []
        }

        var volumes: [VolumeInfo] = []

        for volumeURL in mountedVolumes {
            guard let resources = try? volumeURL.resourceValues(forKeys: Set(keys)) else {
                continue
            }

            let name = resources.volumeName ?? volumeURL.lastPathComponent
            let total = Int64(resources.volumeTotalCapacity ?? 0)
            let free = resources.volumeAvailableCapacityForImportantUsage ?? 0

            guard total > 0 else { continue }

            let isInternal = resources.volumeIsInternal ?? false
            let isRemovable = resources.volumeIsRemovable ?? false

            let icon: String
            if isInternal && !isRemovable {
                icon = "internaldrive.fill"
            } else if isRemovable {
                icon = "externaldrive.fill"
            } else {
                icon = "externaldrive.connected.to.line.below.fill"
            }

            volumes.append(VolumeInfo(
                id: volumeURL.path,
                name: name,
                totalBytes: total,
                freeBytes: free,
                icon: icon
            ))
        }

        // Sort: internal drives first, then by name
        volumes.sort { lhs, rhs in
            if lhs.icon.contains("internaldrive") && !rhs.icon.contains("internaldrive") {
                return true
            }
            if !lhs.icon.contains("internaldrive") && rhs.icon.contains("internaldrive") {
                return false
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }

        return volumes
    }
}
