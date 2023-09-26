import SwiftUI

public struct CustomLayout: Layout {
    public struct Cache {
        var lineWidth: CGFloat = 0
        var firstLineItemSize: CGSize = .zero
        var nextLineItemSize: CGSize = .zero
    }

    private let itemAspectRatio: CGSize
    private let itemSpacing: CGFloat
    private let firstLineItemsCount: Int
    private let nextLineItemsCount: Int
    private let diffItemsCount: Int

    public init(itemAspectRatio: CGSize, itemSpacing: CGFloat = 0, firstLineItemsCount: Int = 1, nextLineItemsCount: Int = 1) {
        guard firstLineItemsCount <= nextLineItemsCount else { preconditionFailure() }

        self.itemAspectRatio = itemAspectRatio
        self.itemSpacing = itemSpacing
        self.firstLineItemsCount = firstLineItemsCount
        self.nextLineItemsCount = nextLineItemsCount
        self.diffItemsCount = nextLineItemsCount - firstLineItemsCount
    }

    public func makeCache(subviews _: Subviews) -> Cache {
        return Cache()
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        guard let width = proposal.width else { return .zero }
        if cache.lineWidth != width {
            cache.firstLineItemSize = .zero
            cache.nextLineItemSize = .zero
            cache.lineWidth = width
        }

        let height = calculateMaxY(width: width, maxIndex: subviews.endIndex, cache: &cache)
        return CGSize(width: width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        for index in subviews.indices {
            var size: CGSize
            var point: CGPoint

            if index < firstLineItemsCount {
                let x = CGFloat(index % firstLineItemsCount) * (cache.firstLineItemSize.width + itemSpacing)
                point = CGPoint(x: x, y: 0)
                size = cache.firstLineItemSize
            } else {
                let lineIndex = (index + diffItemsCount) / nextLineItemsCount
                let x = CGFloat((index + diffItemsCount) % nextLineItemsCount) * (cache.nextLineItemSize.width + itemSpacing)
                let y = cache.firstLineItemSize.height + CGFloat(lineIndex) * itemSpacing + CGFloat(lineIndex - 1) * cache.nextLineItemSize.height
                point = CGPoint(x: x, y: ceil(y))
                size = cache.nextLineItemSize
            }

            point.x += bounds.origin.x
            point.y += bounds.origin.y

            subviews[index].place(at: point, anchor: .topLeading, proposal: ProposedViewSize(width: size.width, height: size.height))
        }
    }

    private func calculateMaxY(width: CGFloat, maxIndex: Int, cache: inout Cache) -> CGFloat {
        guard maxIndex > 0 else { return 0 }

        if cache.firstLineItemSize == .zero {
            cache.firstLineItemSize = lineItemSize(width: width, itemsCount: firstLineItemsCount)
        }

        if cache.nextLineItemSize == .zero {
            cache.nextLineItemSize = lineItemSize(width: width, itemsCount: nextLineItemsCount)
        }

        let linesCount = ceil(Double(maxIndex + diffItemsCount) / Double(nextLineItemsCount))
        return cache.firstLineItemSize.height + CGFloat(linesCount - 1) * itemSpacing + CGFloat(linesCount - 1) * cache.nextLineItemSize.height
    }

    private func lineItemSize(width: CGFloat, itemsCount: Int) -> CGSize {
        let width = (width - CGFloat(itemsCount - 1) * itemSpacing) / CGFloat(itemsCount)
        let height = ceil((itemAspectRatio.height / itemAspectRatio.width) * width)
        return CGSize(width: width, height: height)
    }
}


