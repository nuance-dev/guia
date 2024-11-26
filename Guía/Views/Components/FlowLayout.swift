import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 4
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, line) in result.lines.enumerated() {
            let y = bounds.minY + result.lineOffsets[index]
            var x = bounds.minX
            
            for item in line {
                let size = item.sizeThatFits(.unspecified)
                item.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += size.width + spacing
            }
        }
    }
    
    struct FlowResult {
        var lines: [[LayoutSubview]] = [[]]
        var lineOffsets: [CGFloat] = [0]
        var size: CGSize = .zero
        
        init(in width: CGFloat, subviews: LayoutSubviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            var line: [LayoutSubview] = []
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && !line.isEmpty {
                    lines.append(line)
                    lineOffsets.append(y)
                    y += lineHeight + spacing
                    x = 0
                    line = []
                    lineHeight = 0
                }
                
                line.append(subview)
                x += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            if !line.isEmpty {
                lines.append(line)
                lineOffsets.append(y)
                y += lineHeight
            }
            
            size = CGSize(width: width, height: y)
        }
    }
} 