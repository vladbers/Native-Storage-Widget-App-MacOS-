import AppIntents
import WidgetKit

// MARK: - Refresh Intent (кнопка обновления)

struct RefreshStorageIntent: AppIntent {
    static var title: LocalizedStringResource = "Обновить хранилище"
    static var description: IntentDescription = "Обновить данные о дисках"

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "StorageWidget")
        return .result()
    }
}
