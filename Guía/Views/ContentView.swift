import SwiftUI

struct ContentView: View {
    @State private var firstOption = ""
    @State private var secondOption = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var isAnalyzing = false
    
    // Computed properties for progressive disclosure
    private var showSecondOption: Bool { firstOption.count > 2 }
    private var showInsights: Bool { showSecondOption && secondOption.count > 2 }
    
    var body: some View {
        ZStack {
            // Subtle animated background
            Color.black
                .overlay(
                    Canvas { context, size in
                        context.addFilter(.blur(radius: 60))
                        context.drawLayer { ctx in
                            for i in 0..<3 {
                                let rect = CGRect(x: size.width * 0.1 * CGFloat(i),
                                                y: size.height * 0.2 * CGFloat(i),
                                                width: size.width * 0.3,
                                                height: size.height * 0.3)
                                ctx.fill(Path(ellipseIn: rect),
                                       with: .color(Color(white: 0.1 + Double(i) * 0.05)))
                            }
                        }
                    }
                )
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Minimal header that fades on scroll
                    Text("guía")
                    
                    mainInputArea
                    
                    if showSecondOption {
                        secondInputArea
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    if showInsights {
                        insightsArea
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 20)
                .background(GeometryReader { geo in
                    Color.clear.preference(key: ScrollOffsetKey.self,
                                        value: geo.frame(in: .named("scroll")).minY)
                })
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
            }
        }
    }
    
    private var mainInputArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text("I'm deciding between")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16, weight: .medium))
                
                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.5)
                        .tint(.white.opacity(0.6))
                }
            }
            
            TextField("", text: $firstOption)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .tint(.white)
                .textFieldStyle(.plain)
                .placeholder(when: firstOption.isEmpty) {
                    Text("First option")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 32, weight: .medium))
                }
                .onChange(of: firstOption) { oldValue, newValue in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isAnalyzing = newValue.count > 2
                    }
                }
        }
    }
    
    private var secondInputArea: some View {
        VStack(alignment: .leading, spacing: 24) {
            TextField("", text: $secondOption)
                .font(.system(size: 32, weight: .medium))
                .foregroundColor(.white)
                .tint(.white)
                .textFieldStyle(.plain)
                .placeholder(when: secondOption.isEmpty) {
                    Text("and...")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 32, weight: .medium))
                }
            
            // Smart suggestions
            if !secondOption.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(generateSmartSuggestions(), id: \.self) { suggestion in
                            SuggestionPill(text: suggestion) {
                                withAnimation {
                                    secondOption = suggestion
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var insightsArea: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(generateInsights(), id: \.self) { insight in
                InsightCard(insight: insight)
            }
        }
    }
    
    private func generateSmartSuggestions() -> [String] {
        // TODO: Implement AI-powered suggestions based on first option
        ["Similar but faster", "Alternative approach", "Hybrid solution"]
    }
    
    private func generateInsights() -> [String] {
        // TODO: Implement real-time AI analysis
        [
            "Based on your context, \(firstOption) might be more suitable for immediate results",
            "Historical data suggests \(secondOption) has better long-term outcomes",
            "Key trade-off: Speed vs. Quality"
        ]
    }
}

// MARK: - Supporting Views

struct InsightCard: View {
    let insight: String
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Text(insight)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .padding(16)
            Spacer()
        }
        .background(Color.white.opacity(isHovered ? 0.08 : 0.05))
        .cornerRadius(12)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct SuggestionPill: View {
    let text: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(isHovered ? 0.15 : 0.1))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Supporting Types

struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
