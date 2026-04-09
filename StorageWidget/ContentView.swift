import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var volumes: [VolumeInfo] = []
    @State private var hiddenIDs: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Виджет свободного пространства")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: refresh) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.bottom, 4)

            Text("Добавьте виджет на рабочий стол или в Центр уведомлений.")
                .foregroundStyle(.secondary)
                .font(.callout)
                .padding(.bottom, 12)

            Divider()
                .padding(.bottom, 12)

            // Disk list with toggles
            Text("Отображение дисков в виджете")
                .font(.headline)
                .padding(.bottom, 8)

            if volumes.isEmpty {
                Text("Диски не найдены")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(volumes) { volume in
                    VolumeSettingsRow(
                        volume: volume,
                        isVisible: !hiddenIDs.contains(volume.id),
                        onToggle: {
                            toggleVolume(volume.id)
                        }
                    )
                    .padding(.bottom, 8)
                }
            }

            Spacer()

            Divider()
                .padding(.vertical, 8)

            Text("Автор: Vlad Bersenev (stasgalanin@ya.ru)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(minWidth: 380, minHeight: 300)
        .onAppear {
            volumes = DiskSpaceProvider.getVolumes()
            hiddenIDs = WidgetSettings.hiddenVolumeIDs()
        }
    }

    private func toggleVolume(_ id: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if hiddenIDs.contains(id) {
                hiddenIDs.remove(id)
            } else {
                hiddenIDs.insert(id)
            }
        }
        WidgetSettings.setHidden(hiddenIDs)
        WidgetCenter.shared.reloadTimelines(ofKind: "StorageWidget")
    }

    private func refresh() {
        volumes = DiskSpaceProvider.getVolumes()
        hiddenIDs = WidgetSettings.hiddenVolumeIDs()
        WidgetCenter.shared.reloadTimelines(ofKind: "StorageWidget")
    }
}

struct VolumeSettingsRow: View {
    let volume: VolumeInfo
    let isVisible: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: volume.icon)
                .font(.system(size: 16))
                .foregroundStyle(isVisible ? volume.usageGradient : LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing))
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(volume.name)
                        .fontWeight(.medium)
                        .foregroundStyle(isVisible ? .primary : .secondary)
                    Spacer()
                    Text("\(volume.freeFormatted) свободно из \(volume.totalFormatted)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if isVisible {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(volume.usageGradient)
                                .frame(width: geo.size.width * volume.usedFraction, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }

            Toggle("", isOn: Binding(
                get: { isVisible },
                set: { _ in onToggle() }
            ))
            .toggleStyle(.switch)
            .labelsHidden()
            .controlSize(.small)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(isVisible ? Color.clear : Color.gray.opacity(0.05)))
    }
}
