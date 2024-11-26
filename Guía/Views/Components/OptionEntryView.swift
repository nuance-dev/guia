import SwiftUI

struct OptionEntryView: View {
    @Binding var firstOption: Option
    @Binding var secondOption: Option
    @State private var currentOption = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text("What are your options?")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                
                Text("Enter each option you're considering")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Options list
            VStack(spacing: 16) {
                optionField(option: $firstOption, placeholder: "First option")
                optionField(option: $secondOption, placeholder: "Second option")
            }
        }
        .onAppear { isFocused = true }
    }
    
    private func optionField(option: Binding<Option>, placeholder: String) -> some View {
        TextField("", text: option.name)
            .textFieldStyle(.plain)
            .font(.system(size: 15))
            .foregroundColor(.white)
            .focused($isFocused)
            .placeholder(when: option.wrappedValue.name.isEmpty, placeholder: placeholder)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.03))
            .cornerRadius(8)
    }
} 