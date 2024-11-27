import SwiftUI

struct HeaderView: View {
    let progress: Double
    @EnvironmentObject private var flowManager: DecisionFlowManager
    
    private var currentStep: Step {
        switch flowManager.currentStep {
        case .initial: return .initial
        case .optionEntry: return .optionEntry
        case .factorCollection: return .factorCollection
        case .weighting: return .weighting
        case .scoring: return .scoring
        case .analysis: return .analysis
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 2)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 2)
                }
            }
            .frame(height: 2)
            .padding(.bottom, 20)
            
            // Interactive step indicators
            HStack(spacing: 0) {
                ForEach(Step.allCases, id: \.self) { step in
                    let stepProgress = step.progressValue
                    let isActive = progress >= stepProgress
                    let isCurrent = currentStep == step
                    
                    Button(action: { navigateToStep(step) }) {
                        VStack(spacing: 8) {
                            Text(step.title)
                                .font(.system(size: 13, weight: isActive ? .medium : .regular))
                                .foregroundStyle(isActive ? .primary : .secondary)
                                .opacity(isActive ? 1 : 0.6)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 4, height: 4)
                                .opacity(isCurrent ? 1 : 0)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .disabled(!canNavigateToStep(step))
                }
            }
        }
    }
    
    private func canNavigateToStep(_ step: Step) -> Bool {
        let currentIndex = Step.allCases.firstIndex(of: currentStep) ?? 0
        let targetIndex = Step.allCases.firstIndex(of: step) ?? 0
        return targetIndex <= currentIndex + 1
    }
    
    private func navigateToStep(_ step: Step) {
        guard canNavigateToStep(step) else { return }
        withAnimation(.spring(response: 0.3)) {
            flowManager.currentStep = step.flowStep
        }
    }
}