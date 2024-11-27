import SwiftUI

struct ContentView: View {
    @StateObject private var decisionContext = DecisionContext()
    @StateObject private var flowManager = DecisionFlowManager()
    @State private var showContextBar = false
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Floating context bar
                if showContextBar && !decisionContext.mainDecision.isEmpty {
                    FloatingContextBar(decision: decisionContext.mainDecision)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                HeaderView(progress: flowManager.progress)
                    .padding(.horizontal, 24)
                
                ScrollView {
                    VStack(spacing: 32) {
                        stepContent
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    }
                    .padding(24)
                }
            }
            
            // Navigation hints with enhanced styling
            NavigationHints(canGoBack: flowManager.canGoBack, canProgress: flowManager.canProgress)
        }
        .onChange(of: flowManager.currentStep, initial: false) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                showContextBar = newValue != .initial
            }
        }
        .environmentObject(flowManager)
        .environmentObject(decisionContext)
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch flowManager.currentStep {
        case .initial:
            InitialPromptView()
        case .optionEntry:
            // Initialize with empty options if needed
            let firstOption = decisionContext.options.first ?? Option(name: "", factors: [], timeframe: .immediate, riskLevel: .medium)
            let secondOption = decisionContext.options.count > 1 ? decisionContext.options[1] : Option(name: "", factors: [], timeframe: .immediate, riskLevel: .medium)
            let thirdOption = decisionContext.options.count > 2 ? decisionContext.options[2] : Option(name: "", factors: [], timeframe: .immediate, riskLevel: .medium)
            
            OptionEntryView(
                firstOption: Binding(
                    get: { firstOption },
                    set: { newValue in
                        if decisionContext.options.isEmpty {
                            decisionContext.options.append(newValue)
                        } else {
                            decisionContext.options[0] = newValue
                        }
                    }
                ),
                secondOption: Binding(
                    get: { secondOption },
                    set: { newValue in
                        if decisionContext.options.count < 2 {
                            decisionContext.options.append(newValue)
                        } else {
                            decisionContext.options[1] = newValue
                        }
                    }
                ),
                thirdOption: Binding(
                    get: { thirdOption },
                    set: { newValue in
                        if decisionContext.options.count < 3 {
                            decisionContext.options.append(newValue)
                        } else {
                            decisionContext.options[2] = newValue
                        }
                    }
                )
            )
        case .factorCollection:
            if let firstOption = decisionContext.options.first {
                FactorCollectionView(factors: .init(
                    get: { firstOption.factors },
                    set: { newValue in
                        if var option = decisionContext.options.first {
                            option.factors = newValue
                            decisionContext.options[0] = option
                        }
                    }
                ))
            }
        case .weighting:
            if let firstOption = decisionContext.options.first {
                WeightingView(factors: .init(
                    get: { firstOption.factors },
                    set: { newValue in
                        if var option = decisionContext.options.first {
                            option.factors = newValue
                            decisionContext.options[0] = option
                        }
                    }
                ))
            }
        case .scoring:
            FactorScoringView(options: .init(
                get: { decisionContext.options },
                set: { decisionContext.options = $0 }
            ))
        case .analysis:
            if let firstOption = decisionContext.options.first {
                AnalysisView(
                    options: decisionContext.options,
                    factors: firstOption.factors
                )
            }
        }
    }
}

// Supporting Views
struct BackgroundView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.92)
            
            // Subtle gradient elements with glass effect
            GeometryReader { proxy in
                Canvas { context, size in
                    context.addFilter(.blur(radius: 60))
                    context.drawLayer { ctx in
                        let colors: [Color] = [
                            .accentColor.opacity(0.15),
                            .purple.opacity(0.08),
                            .blue.opacity(0.08)
                        ]
                        
                        for (index, color) in colors.enumerated() {
                            let rect = CGRect(
                                x: size.width * 0.1 * CGFloat(index),
                                y: size.height * 0.1 * CGFloat(index),
                                width: size.width * 0.5,
                                height: size.height * 0.5
                            )
                            ctx.fill(Path(ellipseIn: rect), with: .color(color))
                        }
                    }
                }
            }
            
            // Glass effect overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.3)
        }
        .ignoresSafeArea()
    }
}

// New Components
struct FloatingContextBar: View {
    let decision: String
    
    var body: some View {
        HStack {
            Text("Deciding: ")
                .foregroundColor(.gray)
            +
            Text(decision)
                .foregroundColor(.white)
        }
        .font(.system(size: 14, weight: .medium))
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        }
        .padding(.top, 16)
    }
}

struct NavigationHints: View {
    let canGoBack: Bool
    let canProgress: Bool
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    var body: some View {
        ZStack {
            if canGoBack {
                VStack {
                    Spacer()
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "escape")
                                .font(.system(size: 10))
                            Text("back")
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                        Spacer()
                    }
                }
            }
            
            if canProgress {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Text(navigationHint)
                            Image(systemName: navigationIcon)
                                .font(.system(size: 10))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
        .font(.system(size: 12))
        .foregroundColor(.white.opacity(0.5))
        .transition(.opacity)
    }
    
    private var navigationHint: String {
        switch flowManager.currentStep {
        case .optionEntry:
            return "⌘ + return to continue"
        case .scoring:
            return "return for next"
        default:
            return "continue"
        }
    }
    
    private var navigationIcon: String {
        switch flowManager.currentStep {
        case .optionEntry:
            return "arrow.right"
        case .scoring:
            return "chevron.right"
        default:
            return "return"
        }
    }
}
