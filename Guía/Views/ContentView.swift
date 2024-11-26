import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var engine: DecisionEngine
    @State private var inputText = ""
    @State private var showingSecondOption = false
    @State private var animateAnalysis = false
    @State private var analysisOpacity = 0.0
    @State private var showingInsights = false
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(white: 0.1)]),
                         startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Minimal header
                HStack {
                    Text("guía")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 40)
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        mainInputArea
                        
                        if !inputText.isEmpty {
                            secondOptionArea
                        }
                        
                        if showingInsights {
                            insightsArea
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var mainInputArea: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What's your first option?")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.white)
                .opacity(inputText.isEmpty ? 1 : 0.4)
                .animation(.easeOut(duration: 0.2), value: inputText.isEmpty)
            
            TextField("", text: $inputText)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .tint(.white)
                .textFieldStyle(.plain)
                .onChange(of: inputText) { _ in
                    withAnimation(.easeOut(duration: 0.3)) {
                        showingSecondOption = !inputText.isEmpty
                    }
                }
        }
    }
    
    private var secondOptionArea: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Smart suggestions based on first input
            if !inputText.isEmpty {
                Text("Based on your first option, you might be deciding between:")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 12) {
                    ForEach(generateSuggestions(), id: \.self) { suggestion in
                        Button(action: { selectSuggestion(suggestion) }) {
                            Text(suggestion)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            // Real-time analysis
            if showingInsights {
                realTimeAnalysis
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    private var realTimeAnalysis: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .opacity(animateAnalysis ? 1 : 0.3)
                Text("Analyzing in real-time")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.8).repeatForever()) {
                    animateAnalysis.toggle()
                }
            }
        }
        .opacity(analysisOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                analysisOpacity = 1
            }
        }
    }
    
    private var insightsArea: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Insights")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
            
            // Dynamic insights cards
            ForEach(generateInsights(), id: \.self) { insight in
                InsightCard(insight: insight)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    private func generateSuggestions() -> [String] {
        // Implement smart suggestion logic based on first input
        ["Similar option", "Alternative approach", "Different strategy"]
    }
    
    private func selectSuggestion(_ suggestion: String) {
        withAnimation {
            showingInsights = true
        }
    }
    
    private func generateInsights() -> [String] {
        // Implement real insights generation
        ["Key difference: Speed vs Quality",
         "Historical success rate: Option A leads in 67% cases",
         "Risk assessment: Option B has lower uncertainty"]
    }
}

struct InsightCard: View {
    let insight: String
    
    var body: some View {
        HStack {
            Text(insight)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
                .padding(16)
            Spacer()
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .environmentObject(DecisionEngine())
}
