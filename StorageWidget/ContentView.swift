import SwiftUI

struct ContentView: View {
    @State private var volumes: [VolumeInfo] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Storage Widget")
                .font(.title2)
                .fontWeight(.bold)

            Text("Добавьте виджет на рабочий стол или в Центр уведомлений.")
                .foregroundStyle(.secondary)
                .font(.body)

            Divider()

            if volumes.isEmpty {
                Text("Диски не найдены")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(volumes) { volume in
                    VolumeRowView(volume: volume)
                }
            }

            Spacer()

            Divider()

            Text("Автор: Vlad Bersenev (stasgalanin@ya.ru)")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(minWidth: 350, minHeight: 250)
        .onAppear {
            volumes = DiskSpaceProvider.getVolumes()
        }
    }
}

struct VolumeRowView: View {
    let volume: VolumeInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: volume.icon)
                Text(volume.name)
                    .fontWeight(.medium)
                Spacer()
                Text(volume.freeFormatted + " свободно")
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(volume.usageGradient)
                        .frame(width: geo.size.width * volume.usedFraction, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
