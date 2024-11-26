import SwiftUI

struct OptionEntryView: View {
    @Binding var firstOption: Option
    @Binding var secondOption: Option
    @EnvironmentObject private var flowManager: DecisionFlowManager
    @State private var activeField = 0
    @FocusState private var focusedField: Int?
    @State private var showComparison = false
    @State private var optionsComplete = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(activeField == 0 ? "What's your first option?" : "And the alternative?")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .transition(.opacity)
                
                Text(activeField == 0 ? "Enter your primary choice" : "Enter the option you're comparing against")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .transition(.opacity)
            }
            
            // Options stack
            VStack(spacing: 16) {
                if activeField >= 0 {
                    optionField(
                        text: $firstOption.name,
                        placeholder: "First option",
                        fieldIndex: 0
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if activeField >= 1 {
                    optionField(
                        text: $secondOption.name,
                        placeholder: "Second option",
                        fieldIndex: 1
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            if showComparison {
                // Visual comparison indicator
                HStack(spacing: 24) {
                    ComparisonPill(text: firstOption.name, isActive: true)
                    ComparisonPill(text: secondOption.name, isActive: true)
                }
                .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
        }
        .onChange(of: firstOption.name) { _, newValue in
            validateAndProgress(newValue, isFirstOption: true)
        }
        .onChange(of: secondOption.name) { _, newValue in
            validateAndProgress(newValue, isFirstOption: false)
        }
        .onAppear {
            focusedField = 0
        }
    }
    
    private func validateAndProgress(_ value: String, isFirstOption: Bool) {
        guard !value.isEmpty else { return }
        
        if isFirstOption && activeField == 0 {
            withAnimation(.spring(response: 0.3)) {
                activeField = 1
                focusedField = 1
            }
        } else if !isFirstOption && value.count >= 3 {
            withAnimation(.spring(response: 0.3)) {
                showComparison = true
                optionsComplete = true
                flowManager.updateProgressibility(true)
            }
        }
    }
    
    private func optionField(text: Binding<String>, placeholder: String, fieldIndex: Int) -> some View {
        HStack {
            TextField("", text: text)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .textFieldStyle(.plain)
                .focused($focusedField, equals: fieldIndex)
                .placeholder(when: text.wrappedValue.isEmpty, placeholder: placeholder)
                .onSubmit {
                    if !text.wrappedValue.isEmpty {
                        handleSubmit(fieldIndex)
                    }
                }
                .keyboardShortcut(.return, modifiers: [.command])
            
            InputValidationIndicator(isValid: text.wrappedValue.count >= 3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(focusedField == fieldIndex ? 0.05 : 0.02))
        .cornerRadius(8)
    }
    
    private func handleSubmit(_ fieldIndex: Int) {
        if fieldIndex == 0 && !firstOption.name.isEmpty {
            withAnimation(.spring(response: 0.3)) {
                activeField = 1
                focusedField = 1
            }
        } else if fieldIndex == 1 && !secondOption.name.isEmpty {
            withAnimation(.spring(response: 0.3)) {
                showComparison = true
                optionsComplete = true
                flowManager.updateProgressibility(true)
            }
        }
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