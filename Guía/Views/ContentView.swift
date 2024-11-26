import SwiftUI

struct ContentView: View {
    @StateObject private var decisionContext = DecisionContext()
    @StateObject private var flowManager = DecisionFlowManager()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
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
            
            // Navigation hints
            ZStack {
                // Back hint
                if flowManager.canGoBack {
                    VStack {
                        Spacer()
                        HStack {
                            Text("← press esc to go back")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.leading, 16)
                                .padding(.bottom, 16)
                            Spacer()
                        }
                    }
                }
                
                // Progress hint
                if flowManager.canProgress {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("press enter ⏎")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(.trailing, 16)
                                .padding(.bottom, 16)
                        }
                    }
                }
            }
            .transition(.opacity)
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
            
            // Subtle gradient elements
            GeometryReader { proxy in
                Canvas { context, size in
                    context.addFilter(.blur(radius: 70))
                    context.drawLayer { ctx in
                        let colors: [Color] = [
                            .accentColor.opacity(0.2),
                            .purple.opacity(0.1),
                            .blue.opacity(0.1)
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
        }
        .ignoresSafeArea()
    }
}
