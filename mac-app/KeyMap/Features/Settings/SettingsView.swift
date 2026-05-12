import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var prefs: Preferences
    @ObservedObject private var catalog: LayoutCatalog = .shared
    @State private var isTrusted: Bool = Accessibility.isTrusted
    @State private var trustTimer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    accessibilityRow
                    layoutsSection
                    routingSection
                    Toggle("Show toast after conversion", isOn: $prefs.showToast)
                    Toggle("Launch at login", isOn: $prefs.launchAtLogin)
                }
                .padding(20)
            }

            Divider()
            footer
        }
        .frame(width: 500)
        .onAppear { startTrustWatcher() }
        .onDisappear { trustTimer?.invalidate() }
    }

    // MARK: - Sections

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.black)
                Text("K\u{0643}")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .frame(width: 32, height: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text("KeyMap Fix").font(.headline)
                Text("Convert mis-typed text. One hotkey.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
    }

    private var accessibilityRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: isTrusted ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(isTrusted ? Color.green : Color.orange)
                Text(isTrusted ? "Accessibility granted" : "Accessibility required")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if !isTrusted {
                    Button("Open Settings…") {
                        Accessibility.requestTrust()
                        Accessibility.openAccessibilityPane()
                    }
                    .controlSize(.small)
                }
            }
            Text("KeyMap reads the system keyboard layouts and the current selection — no network access is used.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var layoutsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Detected keyboard layouts")
                .font(.subheadline.weight(.semibold))

            if catalog.layouts.isEmpty {
                Text("No keyboard input sources detected.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 4) {
                    ForEach(catalog.layouts, id: \.id) { layout in
                        HStack {
                            Circle()
                                .fill(layout.isASCIICapable ? Color.blue.opacity(0.6) : Color.purple.opacity(0.7))
                                .frame(width: 6, height: 6)
                            Text(layout.localizedName).font(.callout)
                            Spacer()
                            Text(layout.primaryLanguage ?? "")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(nsColor: .controlBackgroundColor))
                        )
                    }
                }
            }

            Text("KeyMap converts between the layouts you have enabled in System Settings → Keyboard → Input Sources.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var routingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Direction").font(.subheadline.weight(.semibold))
                Spacer()
                Picker("", selection: $prefs.routingMode) {
                    ForEach(Preferences.RoutingMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 220)
            }

            if prefs.routingMode == .fixed {
                layoutPicker(title: "From", selection: $prefs.preferredSourceID)
                layoutPicker(title: "To",   selection: $prefs.preferredTargetID)
            } else {
                Text("In Auto mode, KeyMap picks the source/target based on the script of the selected text. The picks below are tie-breakers when multiple layouts share a script.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                layoutPicker(title: "Preferred Latin",  selection: $prefs.preferredSourceID, asciiOnly: true)
                layoutPicker(title: "Preferred Arabic", selection: $prefs.preferredTargetID, arabicOnly: true)
            }
        }
    }

    private func layoutPicker(
        title: String,
        selection: Binding<String?>,
        asciiOnly: Bool = false,
        arabicOnly: Bool = false
    ) -> some View {
        let options = catalog.layouts.filter { layout in
            if asciiOnly  { return layout.isASCIICapable }
            if arabicOnly { return layout.producesArabicScript }
            return true
        }
        return HStack {
            Text(title).font(.callout).frame(width: 120, alignment: .leading)
            Picker("", selection: selection) {
                Text("None").tag(String?.none)
                ForEach(options, id: \.id) { layout in
                    Text(layout.localizedName).tag(String?.some(layout.id))
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
        }
    }

    private var footer: some View {
        HStack {
            Text("v1.1 · Made in Tunis")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Refresh layouts") { catalog.refresh() }
                .controlSize(.small)
            Button("Quit KeyMap") { NSApp.terminate(nil) }
                .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func startTrustWatcher() {
        trustTimer?.invalidate()
        trustTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async { isTrusted = Accessibility.isTrusted }
        }
    }
}
