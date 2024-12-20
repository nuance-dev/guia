import SwiftUI

struct OptionEntryView: View {
    @Binding var firstOption: Option
    @Binding var secondOption: Option
    @Binding var thirdOption: Option
    @FocusState private var focusedField: Int?
    @State private var visibleFields = 1
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("Options")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text("What are your possible choices?")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Option Fields
            VStack(spacing: 16) {
                if visibleFields >= 1 {
                    optionField(
                        option: $firstOption,
                        placeholder: "First option",
                        fieldIndex: 0
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if visibleFields >= 2 {
                    optionField(
                        option: $secondOption,
                        placeholder: "Second option",
                        fieldIndex: 1
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if visibleFields >= 3 {
                    optionField(
                        option: $thirdOption,
                        placeholder: "Third option (optional)",
                        fieldIndex: 2
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .onChange(of: firstOption.name) { oldValue, newValue in
            handleOptionChange(fieldIndex: 0, value: newValue)
        }
        .onChange(of: secondOption.name) { oldValue, newValue in
            handleOptionChange(fieldIndex: 1, value: newValue)
        }
        .onAppear {
            focusedField = 0
        }
    }
    
    private func optionField(option: Binding<Option>, placeholder: String, fieldIndex: Int) -> some View {
        TextField(placeholder, text: option.name)
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(focusedField == fieldIndex ? 0.1 : 0.05), lineWidth: 1)
            )
            .focused($focusedField, equals: fieldIndex)
            .submitLabel(fieldIndex == 2 ? .done : .next)
            .onSubmit {
                handleOptionFieldSubmit(fieldIndex)
            }
    }
    
    private func handleOptionChange(fieldIndex: Int, value: String) {
        if !value.isEmpty && fieldIndex == visibleFields - 1 && visibleFields < 3 {
            withAnimation(.spring(response: 0.3)) {
                visibleFields += 1
            }
        }
        updateProgress()
    }
    
    private func updateProgress() {
        flowManager.updateProgressibility(!firstOption.name.isEmpty && !secondOption.name.isEmpty)
    }
    
    private func handleOptionFieldSubmit(_ fieldIndex: Int) {
        switch fieldIndex {
        case 0:
            if !firstOption.name.isEmpty {
                focusedField = 1
                if visibleFields < 2 {
                    withAnimation(.spring(response: 0.3)) {
                        visibleFields = 2
                    }
                }
            }
        case 1:
            if !secondOption.name.isEmpty {
                focusedField = 2
                if visibleFields < 3 {
                    withAnimation(.spring(response: 0.3)) {
                        visibleFields = 3
                    }
                }
            } else if !firstOption.name.isEmpty {
                flowManager.advanceStep()
            }
        case 2:
            if !firstOption.name.isEmpty && !secondOption.name.isEmpty {
                flowManager.advanceStep()
            }
        default:
            break
        }
        updateProgress()
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
