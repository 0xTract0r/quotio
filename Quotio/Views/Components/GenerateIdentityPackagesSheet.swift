//
//  GenerateIdentityPackagesSheet.swift
//  Quotio
//

import SwiftUI

struct GenerateIdentityPackagesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onGenerate: (Int, String?) -> Void

    @State private var count = 5
    @State private var namePrefix = "Identity Package"

    private var trimmedPrefix: String {
        namePrefix.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Batch Generate Identity Packages")
                .font(.title2.weight(.semibold))

            Text("Generate multiple local identity packages at once. Quotio will create draft packages with generated UA/TLS profiles; you can fill in proxy details later.")
                .font(.callout)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                TextField("Name Prefix", text: $namePrefix)
                    .textFieldStyle(.roundedBorder)

                Stepper(value: $count, in: 1...100) {
                    HStack {
                        Text("Count")
                        Spacer()
                        Text("\(count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Text("Example names: \(exampleNames)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))

            HStack {
                Spacer()

                Button("Cancel") {
                    dismiss()
                }

                Button("Generate") {
                    onGenerate(count, trimmedPrefix.isEmpty ? nil : trimmedPrefix)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 460, height: 240)
    }

    private var exampleNames: String {
        let prefix = trimmedPrefix.isEmpty ? "Identity Package" : trimmedPrefix
        return "\(prefix) 01, \(prefix) 02, \(prefix) 03"
    }
}
