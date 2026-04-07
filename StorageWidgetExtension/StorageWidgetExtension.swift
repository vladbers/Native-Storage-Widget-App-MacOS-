import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct StorageTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> StorageEntry {
        StorageEntry(date: Date(), volumes: StorageEntry.placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (StorageEntry) -> Void) {
        let volumes = DiskSpaceProvider.getVolumes()
        completion(StorageEntry(date: Date(), volumes: volumes))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StorageEntry>) -> Void) {
        let volumes = DiskSpaceProvider.getVolumes()
        let entry = StorageEntry(date: Date(), volumes: volumes)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct StorageEntry: TimelineEntry {
    let date: Date
    let volumes: [VolumeInfo]

    static let placeholder: [VolumeInfo] = [
        VolumeInfo(id: "/", name: "Macintosh HD", totalBytes: 500_000_000_000, freeBytes: 150_000_000_000, icon: "internaldrive.fill"),
        VolumeInfo(id: "/Volumes/External", name: "External SSD", totalBytes: 1_000_000_000_000, freeBytes: 600_000_000_000, icon: "externaldrive.fill"),
    ]
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: StorageEntry

    var body: some View {
        if let volume = entry.volumes.first {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: volume.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(volume.usageGradient)
                    Text(volume.name)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer()
                }

                Spacer()

                Text(volume.freeFormatted)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text("свободно из \(volume.totalFormatted)")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)

                StorageBar(fraction: volume.usedFraction, gradient: volume.usageGradient)
                    .frame(height: 7)
                    .padding(.top, 2)
            }
            .padding(12)
        } else {
            Text("Нет дисков")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: StorageEntry

    var body: some View {
        let displayVolumes = Array(entry.volumes.prefix(3))

        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "opticaldiscdrive.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.blue.gradient)
                Text("Хранилище")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 10)

            if displayVolumes.isEmpty {
                Spacer()
                Text("Диски не найдены")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(Array(displayVolumes.enumerated()), id: \.element.id) { index, volume in
                    MediumVolumeRow(volume: volume)
                    if index < displayVolumes.count - 1 {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
                if entry.volumes.count > 3 {
                    Text("+ ещё \(entry.volumes.count - 3)")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
            }
        }
        .padding(12)
    }
}

struct MediumVolumeRow: View {
    let volume: VolumeInfo

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: volume.icon)
                .font(.system(size: 11))
                .foregroundStyle(volume.usageGradient)
                .frame(width: 14)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(volume.name)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                    Text("\(volume.freeFormatted) свободно")
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
                StorageBar(fraction: volume.usedFraction, gradient: volume.usageGradient)
                    .frame(height: 5)
            }
        }
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let entry: StorageEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "opticaldiscdrive.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.blue.gradient)
                Text("Хранилище")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(entry.date, style: .time)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 12)

            if entry.volumes.isEmpty {
                Spacer()
                Text("Диски не найдены")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ForEach(Array(entry.volumes.enumerated()), id: \.element.id) { index, volume in
                    LargeVolumeRow(volume: volume)
                    if index < entry.volumes.count - 1 {
                        Divider()
                            .padding(.vertical, 6)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(14)
    }
}

struct LargeVolumeRow: View {
    let volume: VolumeInfo

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(volume.usageColor.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: volume.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(volume.usageGradient)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(volume.name)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                    Spacer()
                    Text("\(Int(volume.usedFraction * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(volume.usageColor)
                }
                StorageBar(fraction: volume.usedFraction, gradient: volume.usageGradient)
                    .frame(height: 6)
                HStack {
                    Text("\(volume.freeFormatted) свободно")
                        .font(.system(size: 10))
                        .foregroundStyle(.primary.opacity(0.7))
                    Spacer()
                    Text("из \(volume.totalFormatted)")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

// MARK: - Shared Components

struct StorageBar: View {
    let fraction: Double
    let gradient: LinearGradient

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.15))
                RoundedRectangle(cornerRadius: 4)
                    .fill(gradient)
                    .frame(width: max(0, geo.size.width * fraction))
            }
        }
    }
}

// MARK: - Widget Configuration

struct StorageWidget: Widget {
    let kind: String = "StorageWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StorageTimelineProvider()) { entry in
            StorageWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Хранилище")
        .description("Свободное место на дисках Mac.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct StorageWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: StorageEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct StorageWidgetBundle: WidgetBundle {
    var body: some Widget {
        StorageWidget()
    }
}

// MARK: - Preview

#Preview("Small", as: .systemSmall) {
    StorageWidget()
} timeline: {
    StorageEntry(date: Date(), volumes: StorageEntry.placeholder)
}

#Preview("Medium", as: .systemMedium) {
    StorageWidget()
} timeline: {
    StorageEntry(date: Date(), volumes: StorageEntry.placeholder)
}

#Preview("Large", as: .systemLarge) {
    StorageWidget()
} timeline: {
    StorageEntry(date: Date(), volumes: StorageEntry.placeholder)
}
