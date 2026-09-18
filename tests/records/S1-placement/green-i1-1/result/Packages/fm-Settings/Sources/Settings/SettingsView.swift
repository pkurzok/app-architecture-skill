import Catalog
import DesignSystem
import SwiftUI

/// The reader's preferences.
public struct SettingsView: View {
    private let settings: CatalogSettings

    public init(settings: CatalogSettings) {
        self.settings = settings
    }

    public var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                Picker("Sort books by", selection: $settings.sortOrder) {
                    ForEach(BookSortOrder.allCases, id: \.self) { order in
                        Text(order.label).tag(order)
                    }
                }
            }
            .padding(.top, Spacing.small)
            .navigationTitle("Settings")
        }
        .trackScreen("Settings")
    }
}
