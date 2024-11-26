import SwiftUI

struct OptionEntryView: View {
    @Binding var firstOption: Option
    @Binding var secondOption: Option
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    @FocusState private var focusedField: Int?
    @State private var activeField = 0
    @State private var showComparison = false
    @State private var optionsComplete = false
    @State private var showThirdOption = false
    @State private var thirdOption = Option(name: "", factors: [], timeframe: .immediate, riskLevel: .medium)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(headerText)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subheaderText)
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Option Fields
            VStack(spacing: 16) {
                optionField(
                    text: $firstOption.name,
                    placeholder: "e.g. Stay at current job",
                    fieldIndex: 0
                )
                .opacity(activeField >= 0 ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: activeField)
                
                if activeField >= 1 {
                    optionField(
                        text: $secondOption.name,
                        placeholder: "e.g. Accept new job offer",
                        fieldIndex: 1
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if showThirdOption {
                    optionField(
                        text: $thirdOption.name,
                        placeholder: "e.g. Start my own business",
                        fieldIndex: 2
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            
            // Add Option Button
            if optionsComplete && !showThirdOption && activeField >= 1 {
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showThirdOption = true
                        flowManager.keyboardHandler?.updateState(step: .optionEntry, canProgress: true, canAddMore: false)
                    }
                }) {
                    Label("Add another option", systemImage: "plus.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.6))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
                .transition(.opacity)
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
            flowManager.keyboardHandler?.updateState(step: .optionEntry, canProgress: false, canAddMore: true)
        }
    }
    
    private var headerText: String {
        switch activeField {
        case 0: return "What's your first option?"
        case 1: return "And the alternative?"
        default: return "Any other option?"
        }
    }
    
    private var subheaderText: String {
        switch activeField {
        case 0: return "Enter your primary choice"
        case 1: return "Enter the option you're comparing against"
        default: return "Add another option (optional)"
        }
    }
    
    private func validateAndProgress(_ value: String, isFirstOption: Bool) {
        guard !value.isEmpty else { return }
        
        if isFirstOption && activeField == 0 && value.count >= 3 {
            withAnimation(.spring(response: 0.3)) {
                activeField = 1
                focusedField = 1
                flowManager.keyboardHandler?.updateState(
                    step: .optionEntry,
                    canProgress: false,
                    canAddMore: true
                )
            }
        } else if !isFirstOption && value.count >= 3 {
            withAnimation(.spring(response: 0.3)) {
                showComparison = true
                optionsComplete = true
                flowManager.keyboardHandler?.updateState(
                    step: .optionEntry,
                    canProgress: true,
                    canAddMore: true
                )
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
                .onChange(of: text.wrappedValue) { _, newValue in
                    if newValue.count >= 3 {
                        handleSubmit(fieldIndex)
                    }
                }
            
            InputValidationIndicator(isValid: text.wrappedValue.count >= 3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.white.opacity(focusedField == fieldIndex ? 0.05 : 0.02))
        .cornerRadius(8)
    }
    
    private func handleSubmit(_ fieldIndex: Int) {
        if fieldIndex == 0 && firstOption.name.count >= 3 {
            withAnimation(.spring(response: 0.3)) {
                activeField = 1
                focusedField = 1
                flowManager.keyboardHandler?.updateState(
                    step: .optionEntry,
                    canProgress: false,
                    canAddMore: true
                )
            }
        } else if fieldIndex == 1 && secondOption.name.count >= 3 {
            withAnimation(.spring(response: 0.3)) {
                showComparison = true
                optionsComplete = true
                flowManager.keyboardHandler?.updateState(
                    step: .optionEntry,
                    canProgress: true,
                    canAddMore: true
                )
            }
        } else if fieldIndex == 2 && thirdOption.name.count >= 3 {
            withAnimation(.spring(response: 0.3)) {
                flowManager.keyboardHandler?.updateState(
                    step: .optionEntry,
                    canProgress: true,
                    canAddMore: false
                )
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
