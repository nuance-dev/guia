import SwiftUI

struct ContentView: View {
    @StateObject private var decisionContext = DecisionContext()
    @StateObject private var flowManager = DecisionFlowManager()
    @State private var showContextBar = false
    @State private var contentOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Floating context bar with enhanced animation
                if showContextBar && !decisionContext.mainDecision.isEmpty {
                    FloatingContextBar(decision: decisionContext.mainDecision)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(1)
                }
                
                HeaderView(progress: flowManager.progress)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                
                ScrollView {
                    VStack(spacing: 24) {
                        stepContent
                            .transition(
                                .asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                )
                            )
                            .opacity(flowManager.isTransitioning ? 0 : 1)
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
                .scrollDisabled(flowManager.currentStep == .initial)
            }
            .offset(y: contentOffset)
            
            // Subtle navigation hints
            NavigationHints(canGoBack: flowManager.canGoBack, canProgress: flowManager.canProgress)
                .opacity(0.8)
        }
        .onChange(of: flowManager.currentStep) { oldValue, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContextBar = newValue != .initial
                contentOffset = 0
            }
        }
        .environmentObject(flowManager)
        .environmentObject(decisionContext)
        .preferredColorScheme(.dark)
        .alert("Reset Decision", isPresented: $flowManager.showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                decisionContext.mainDecision = ""
                decisionContext.options = []
                flowManager.resetFlow()
            }
        } message: {
            Text("This will clear all your current progress. Are you sure?")
        }
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

// Enhanced Background
struct BackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.94)
            
            GeometryReader { proxy in
                Canvas { context, size in
                    context.addFilter(.blur(radius: 80))
                    context.drawLayer { ctx in
                        let colors: [(Color, CGFloat)] = [
                            (.accentColor.opacity(0.12), 0.8),
                            (.purple.opacity(0.06), 0.6),
                            (.blue.opacity(0.06), 0.4)
                        ]
                        
                        for (index, (color, scale)) in colors.enumerated() {
                            let center = CGPoint(
                                x: size.width * (0.3 + 0.1 * Double(index)),
                                y: size.height * (0.3 + 0.1 * Double(index))
                            )
                            let radius = min(size.width, size.height) * scale
                            
                            let path = Path { p in
                                p.addEllipse(in: CGRect(
                                    x: center.x - radius/2,
                                    y: center.y - radius/2,
                                    width: radius,
                                    height: radius
                                ))
                            }
                            ctx.fill(path, with: .color(color))
                        }
                    }
                }
            }
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.2)
        }
        .ignoresSafeArea()
    }
}

// Enhanced Floating Context Bar
struct FloatingContextBar: View {
    let decision: String
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
            
            Text(decision)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(height: 32)
        .padding(.horizontal, 16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(.white.opacity(0.06), lineWidth: 1)
                )
        }
        .padding(.top, 12)
    }
}

// Enhanced Navigation Hints
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
                        NavigationHintPill(icon: "chevron.left", text: "back")
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
                        NavigationHintPill(icon: "chevron.right", text: "continue")
                            .padding(.trailing, 16)
                            .padding(.bottom, 16)
                    }
                }
            }
        }
    }
}

struct NavigationHintPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .medium))
            Text(text)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.ultraThinMaterial.opacity(0.5))
        .cornerRadius(12)
    }
}

// Custom transition
extension AnyTransition {
    static func moving(edge: Edge) -> AnyTransition {
        AnyTransition.asymmetric(
            insertion: .modifier(
                active: MoveModifier(edge: edge, pct: 1),
                identity: MoveModifier(edge: edge, pct: 0)
            ),
            removal: .modifier(
                active: MoveModifier(edge: edge, pct: -1),
                identity: MoveModifier(edge: edge, pct: 0)
            )
        )
    }
}

struct MoveModifier: ViewModifier {
    let edge: Edge
    let pct: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(
                x: edge == .leading || edge == .trailing
                    ? pct * 30
                    : 0,
                y: edge == .top || edge == .bottom
                    ? pct * 30
                    : 0
            )
            .opacity(1 - abs(pct) * 0.3)
    }
}
