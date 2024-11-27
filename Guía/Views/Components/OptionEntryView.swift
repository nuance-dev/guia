import SwiftUI

struct OptionEntryView: View {
    @Binding var firstOption: Option
    @Binding var secondOption: Option
    @Binding var thirdOption: Option
    @State private var showThirdOption = false
    @FocusState private var focusedField: Int?
    @State private var activeField = 0
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    private var optionsComplete: Bool {
        !firstOption.name.isEmpty && !secondOption.name.isEmpty
    }
    
    private var subheaderText: String {
        "What are your options?"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("Options")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subheaderText)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Progressive Option Fields
            VStack(spacing: 24) {
                if activeField >= 0 {
                    optionField(
                        option: $firstOption,
                        placeholder: "First option",
                        fieldIndex: 0
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if activeField >= 1 && !firstOption.name.isEmpty {
                    optionField(
                        option: $secondOption,
                        placeholder: "Second option",
                        fieldIndex: 1
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if activeField >= 2 && !secondOption.name.isEmpty && showThirdOption {
                    optionField(
                        option: $thirdOption,
                        placeholder: "Third option (optional)",
                        fieldIndex: 2
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            // Add third option button
            if !showThirdOption && optionsComplete {
                Button(action: { 
                    withAnimation(.spring()) {
                        showThirdOption = true
                        activeField = 2
                        focusedField = 2
                    }
                }) {
                    Label("Add another option", systemImage: "plus.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                }
                .buttonStyle(.plain)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)
            }
        }
        .onChange(of: focusedField, initial: false) { oldValue, newValue in
            if let field = newValue {
                withAnimation(.spring()) {
                    activeField = field
                }
            }
        }
        .onChange(of: firstOption.name, initial: false) { oldValue, newValue in
            if !newValue.isEmpty && activeField == 0 {
                withAnimation(.spring()) {
                    activeField = 1
                    focusedField = 1
                }
            }
            updateProgress()
        }
        .onChange(of: secondOption.name, initial: false) { oldValue, newValue in
            if !newValue.isEmpty && activeField == 1 {
                withAnimation(.spring()) {
                    activeField = 2
                }
            }
            updateProgress()
        }
        .onChange(of: thirdOption.name, initial: false) { oldValue, newValue in
            updateProgress()
        }
    }
    
    private func optionField(option: Binding<Option>, placeholder: String, fieldIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField(placeholder, text: option.name)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .opacity(0.5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(focusedField == fieldIndex ? 0.1 : 0.05), lineWidth: 1)
                )
                .focused($focusedField, equals: fieldIndex)
                .onSubmit {
                    if !option.wrappedValue.name.isEmpty {
                        withAnimation(.spring()) {
                            if fieldIndex < 2 {
                                activeField = fieldIndex + 1
                                focusedField = fieldIndex + 1
                            }
                        }
                    }
                }
        }
    }
    
    private func updateProgress() {
        flowManager.updateProgressibility(!firstOption.name.isEmpty && !secondOption.name.isEmpty)
    }
}

struct ComparisonPill: View {
    let text: String
    let isActive: Bool
    
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.white.opacity(isActive ? 1 : 0.6))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
    }
} 
