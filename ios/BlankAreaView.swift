import Foundation
import UIKit


/*
 Container for all RecyclerListView children. This will automatically remove all gaps and overlaps for GridLayouts with flexible spans.
 Note: This cannot work for masonry layouts i.e, pinterest like layout
 */
@objc class BlankAreaView: UIView {
    // private var horizontal = false
    // private var scrollOffset: CGFloat = 0
    // private var windowSize: CGFloat = 0
    // private var renderAheadOffset: CGFloat = 0
    // private var enableInstrumentation = false
    
    // var blankOffsetTop: CGFloat = 0 // Tracks blank area from the top
    // var blankOffsetBottom: CGFloat = 0 // Tracks blank area from the bottom
    
    // private var lastMaxBound: CGFloat = 0 // Tracks where the last pixel is drawn in the visible window
    // private var lastMinBound: CGFloat = 0 // Tracks where first pixel is drawn in the visible window
    
    // @objc func setHorizontal(_ horizontal: Bool) {
    //     self.horizontal = horizontal
    // }
    
    // @objc func setScrollOffset(_ scrollOffset: Int) {
    //     self.scrollOffset = CGFloat(scrollOffset)
    // }
    
    // @objc func setWindowSize(_ windowSize: Int) {
    //     self.windowSize = CGFloat(windowSize)
    // }
    
    // @objc func setRenderAheadOffset(_ renderAheadOffset: Int) {
    //     self.renderAheadOffset = CGFloat(renderAheadOffset)
    // }
    
    // @objc func setEnableInstrumentation(_ enableInstrumentation: Bool) {
    //     self.enableInstrumentation = enableInstrumentation
    // }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var observation: NSKeyValueObservation?
    private var didSet = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSet {
            let scrollView = subviews.first!.subviews.first! as! UIScrollView
            observation = scrollView.observe(\.contentOffset, changeHandler: { [weak self] scrollView, _ in
                guard let self = self else { return }
                // subviews.first!.subviews.first!.subviews.first!.subviews
//                print(scrollView.contentOffset)
                let scrollView = self.subviews.first!.subviews.first! as! UIScrollView
                let scrollY = scrollView.contentOffset.y
//                print("Scroll offset Native: \(scrollY)")
                
                let blank = self.computeBlankFromGivenOffset(scrollY)
//                print("Blank offset: \(blank)")
                
                BlankAreaEventEmitter.INSTANCE?.onBlankArea(offset: blank) ?? assertionFailure("BlankAreaEventEmitter.INSTANCE was not initialized")
            })
            didSet = true
        }
        backgroundColor = .red
    }
    
    func computeBlankFromGivenOffset(_ actualScrollOffset: CGFloat) -> CGFloat {
        let scrollView = subviews.first!.subviews.first! as! UIScrollView
        let cells = subviews.first!.subviews.first!.subviews.first!.subviews
        guard
            let firstCell = cells.first(where: { isWithinBounds($0, scrollOffset: actualScrollOffset) && !$0.subviews.isEmpty }),
            let lastCell = cells.last(where: { isWithinBounds($0, scrollOffset: actualScrollOffset) && !$0.subviews.isEmpty }),
            firstCell != lastCell
        else {
            return !cells.isEmpty ? scrollView.frame.size.height : 0
        }
        let blankOffsetTop = firstCell.frame.minY - actualScrollOffset
        let blankOffsetBottom = actualScrollOffset + scrollView.frame.height - lastCell.frame.maxY
        return max(0, max(blankOffsetTop, blankOffsetBottom)) // one of the values is negative, we look for the positive one
    }
    
    func isWithinBounds(
        _ cellView: UIView,
        scrollOffset: CGFloat
    ) -> Bool {
        let scrollView = subviews.first!.subviews.first! as! UIScrollView
        let boundsStart = scrollOffset
        let boundsEnd = scrollOffset + scrollView.frame.height
        let cellFrame = cellView.frame
        
//        if isHorizontal {
//            print("Horizontal")
//            return (cellFrame.minX >= boundsStart || cellFrame.maxX >= boundsStart) && (cellFrame.minX <= boundsEnd || cellFrame.maxX <= boundsEnd)
//        } else {
//            print("Vertical")
            return (cellFrame.minY >= boundsStart || cellFrame.maxY >= boundsStart) && (cellFrame.minY <= boundsEnd || cellFrame.maxY <= boundsEnd)
//        }
    }
}
