import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var prefs: Preferences
    @State private var isTrusted: Bool = Accessibility.isTrusted

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    accessibilityRow
                    hotkeyRow
                    directionRow
                    Toggle("Show toast after conversion", isOn: $prefs.showToast)
                    Toggle("Enable AZERTY (French) directions", isOn: $prefs.azertyEnabled)
                    Toggle("Launch at login", isOn: $prefs.launchAtLogin)
                }
                .padding(20)
            }

            Divider()
            footer
        }
        .frame(width: 460)
        .onAppear { refreshTrust() }
    }

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
            Text("KeyMap needs Accessibility access to read your selection and paste the converted text.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private var hotkeyRow: some View {
        HStack {
            Text("Hotkey").font(.subheadline.weight(.medium))
            Spacer()
            Text(GlobalHotkey.Combo.defaultCombo.displayString)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.3))
                )
        }
    }

    private var directionRow: some View {
        HStack {
            Text("Default direction").font(.subheadline.weight(.medium))
            Spacer()
            Picker("", selection: $prefs.defaultDirection) {
                ForEach(Preferences.DefaultDirection.allCases) { d in
                    Text(d.label).tag(d)
                }
            }
            .labelsHidden()
            .pickerStyle(.menu)
            .fixedSize()
        }
    }

    private var footer: some View {
        HStack {
            Text("v1.0 · Made in Tunis")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Quit KeyMap") {
                NSApp.terminate(nil)
            }
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func refreshTrust() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async { isTrusted = Accessibility.isTrusted }
        }
    }
}
