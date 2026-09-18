import Analytics
import Catalog
import DesignSystem
import SwiftUI

/// The reader's preferences.
public struct SettingsView: View {
    private let settings: CatalogSettings
    private let analytics: Analytics

    public init(settings: CatalogSettings, analytics: Analytics) {
        self.settings = settings
        self.analytics = analytics
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
        .trackScreenView("Settings", track: analytics.trackScreenView)
    }
}
