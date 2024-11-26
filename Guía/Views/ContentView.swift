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
                            .transition(.opacity.combined(with: .move(edge: .trailing)))
                        
                        if flowManager.showActionButton {
                            ActionButton(title: flowManager.actionButtonTitle) {
                                withAnimation(.spring(response: 0.3)) {
                                    flowManager.advanceStep()
                                    updateDecisionContext()
                                }
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch flowManager.currentStep {
        case .initial:
            InitialPromptView()
        case .optionEntry:
            OptionEntryView(
                firstOption: $decisionContext.firstOption,
                secondOption: $decisionContext.secondOption
            )
        case .factorCollection:
            FactorCollectionView(factors: $decisionContext.firstOption.factors)
        case .weighting:
            WeightingView(factors: $decisionContext.firstOption.factors)
        case .analysis:
            AnalysisView(
                options: [decisionContext.firstOption, decisionContext.secondOption],
                factors: decisionContext.firstOption.factors
            )
        }
    }
    
    private func updateDecisionContext() {
        switch flowManager.currentStep {
        case .initial:
            decisionContext.currentStep = .firstOption
        case .optionEntry:
            decisionContext.currentStep = .secondOption
        case .factorCollection:
            decisionContext.currentStep = .factorInput
        case .weighting:
            decisionContext.currentStep = .factorWeighting
        case .analysis:
            decisionContext.currentStep = .review
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
