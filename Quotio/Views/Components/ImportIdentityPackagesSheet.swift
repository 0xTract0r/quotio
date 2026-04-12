//
//  ImportIdentityPackagesSheet.swift
//  Quotio
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportIdentityPackagesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onImport: (String) -> Void

    @State private var rawText = ""
    @State private var showFileImporter = false
    @State private var importErrorMessage: String?

    private var canImport: Bool {
        !rawText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Import Proxies")
                .font(.title2.weight(.semibold))

            Text("Paste one proxy URL per line, or load a text file. Supported examples: `socks5://user:pass@host:1080`, `http://host:8080`, `https://user:pass@host:443`.")
                .font(.callout)
                .foregroundStyle(.secondary)

            TextEditor(text: $rawText)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 220)
                .padding(10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack {
                Button("Load From File") {
                    showFileImporter = true
                }

                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Import") {
                    onImport(rawText)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!canImport)
            }
        }
        .padding(20)
        .frame(width: 620, height: 420)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.plainText, .text, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let url = try result.get().first else { return }
                let content = try String(contentsOf: url, encoding: .utf8)
                rawText = content
            } catch {
                importErrorMessage = error.localizedDescription
            }
        }
        .alert(
            "Import File Failed",
            isPresented: Binding(
                get: { importErrorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        importErrorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(importErrorMessage ?? "")
        }
    }
}
