import UIKit

protocol WKEditorToolbarExpandingViewDelegate: AnyObject {
    func toolbarExpandingViewDidTapFind(toolbarView: WKEditorToolbarExpandingView)
    func toolbarExpandingViewDidTapFormatText(toolbarView: WKEditorToolbarExpandingView)
    func toolbarExpandingViewDidTapFormatHeading(toolbarView: WKEditorToolbarExpandingView)
}

class WKEditorToolbarExpandingView: WKEditorToolbarView {
    
    // MARK: - Nested Types
    
    private enum ActionsType: CGFloat {
        case primary
        case secondary

        static func visible(rawValue: RawValue) -> ActionsType {
            if rawValue == 0 {
                return .primary
            } else {
                return .secondary
            }
        }

        static func next(rawValue: RawValue) -> ActionsType {
            if rawValue == 0 {
                return .secondary
            } else {
                return .primary
            }
        }
    }
    
    // MARK: - Properties
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var stackView: UIStackView!
    
    @IBOutlet private weak var formatTextButton: WKEditorToolbarButton!
    @IBOutlet private weak var formatHeadingButton: WKEditorToolbarButton!
    @IBOutlet private weak var citationButton: WKEditorToolbarButton!
    @IBOutlet private weak var linkButton: WKEditorToolbarButton!
    @IBOutlet private weak var templateButton: WKEditorToolbarButton!
    @IBOutlet private weak var mediaButton: WKEditorToolbarButton!
    @IBOutlet private weak var findInPageButton: WKEditorToolbarButton!
    
    @IBOutlet private weak var unorderedListButton: WKEditorToolbarButton!
    @IBOutlet private weak var orderedListButton: WKEditorToolbarButton!
    @IBOutlet private weak var decreaseIndentionButton: WKEditorToolbarButton!
    @IBOutlet private weak var increaseIndentionButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorUpButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorDownButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorLeftButton: WKEditorToolbarButton!
    @IBOutlet private weak var cursorRightButton: WKEditorToolbarButton!
    
    @IBOutlet private weak var expandButton: WKEditorToolbarNavigatorButton!
    
    weak var delegate: WKEditorToolbarExpandingViewDelegate?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        
        expandButton.isAccessibilityElement = false
        expandButton.setImage(WKSFSymbolIcon.for(symbol: .chevronRightCircle), for: .normal)
        expandButton.addTarget(self, action: #selector(tappedExpand), for: .touchUpInside)
        
        formatTextButton.setImage(WKIcon.formatText, for: .normal)
        formatTextButton.addTarget(self, action: #selector(tappedFormatText), for: .touchUpInside)
        
        formatHeadingButton.setImage(WKIcon.formatHeading, for: .normal)
        formatHeadingButton.addTarget(self, action: #selector(tappedFormatHeading), for: .touchUpInside)
        
        citationButton.setImage(WKSFSymbolIcon.for(symbol: .quoteOpening), for: .normal)
        citationButton.addTarget(self, action: #selector(tappedCitation), for: .touchUpInside)
        
        linkButton.setImage(WKSFSymbolIcon.for(symbol: .link), for: .normal)
        linkButton.addTarget(self, action: #selector(tappedLink), for: .touchUpInside)
        
        templateButton.setImage(WKSFSymbolIcon.for(symbol: .curlybraces), for: .normal)
        templateButton.addTarget(self, action: #selector(tappedTemplate), for: .touchUpInside)
        
        mediaButton.setImage(WKSFSymbolIcon.for(symbol: .photo), for: .normal)
        mediaButton.addTarget(self, action: #selector(tappedMedia), for: .touchUpInside)
        
        findInPageButton.setImage(WKSFSymbolIcon.for(symbol: .docTextMagnifyingGlass), for: .normal)
        findInPageButton.addTarget(self, action: #selector(tappedFindInPage), for: .touchUpInside)
        
        unorderedListButton.setImage(WKSFSymbolIcon.for(symbol: .listBullet), for: .normal)
        unorderedListButton.addTarget(self, action: #selector(tappedUnorderedList), for: .touchUpInside)
        
        orderedListButton.setImage(WKSFSymbolIcon.for(symbol: .listNumber), for: .normal)
        orderedListButton.addTarget(self, action: #selector(tappedOrderedList), for: .touchUpInside)
        
        decreaseIndentionButton.setImage(WKSFSymbolIcon.for(symbol: .decreaseIndent), for: .normal)
        decreaseIndentionButton.addTarget(self, action: #selector(tappedDecreaseIndentation), for: .touchUpInside)
        
        increaseIndentionButton.setImage(WKSFSymbolIcon.for(symbol: .increaseIndent), for: .normal)
        increaseIndentionButton.addTarget(self, action: #selector(tappedIncreaseIndentation), for: .touchUpInside)
        
        cursorUpButton.setImage(WKIcon.chevronUp, for: .normal)
        cursorUpButton.addTarget(self, action: #selector(tappedCursorUp), for: .touchUpInside)
        
        cursorDownButton.setImage(WKIcon.chevronDown, for: .normal)
        cursorDownButton.addTarget(self, action: #selector(tappedCursorDown), for: .touchUpInside)
        
        cursorLeftButton.setImage(WKIcon.chevronLeft, for: .normal)
        cursorLeftButton.addTarget(self, action: #selector(tappedCursorLeft), for: .touchUpInside)
        
        cursorRightButton.setImage(WKIcon.chevronRight, for: .normal)
        cursorRightButton.addTarget(self, action: #selector(tappedCursorRight), for: .touchUpInside)
    }

    // MARK: - Button Actions
    
    @objc private func tappedExpand() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        let offsetX = scrollView.contentOffset.x
        let actionsType = ActionsType.next(rawValue: offsetX)
        
        let transform = CGAffineTransform.identity
        let buttonTransform: () -> Void
        let newOffsetX: CGFloat
        
        let sender = expandButton

        switch actionsType {
        case .primary:
            buttonTransform = {
                sender?.transform = transform
            }
            newOffsetX = 0
        case .secondary:
            buttonTransform = {
                sender?.transform = transform.rotated(by: 180 * CGFloat.pi)
                sender?.transform = transform.rotated(by: -1 * CGFloat.pi)
            }
            newOffsetX = stackView.bounds.width / 2
        }

        let scrollViewContentOffsetChange = {
            self.scrollView.setContentOffset(CGPoint(x: newOffsetX , y: 0), animated: false)
        }

        let buttonAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.7, animations: buttonTransform)
        let scrollViewAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: scrollViewContentOffsetChange)

        buttonAnimator.startAnimation()
        scrollViewAnimator.startAnimation()
    }

    @objc private func tappedFormatText() {
        delegate?.toolbarExpandingViewDidTapFormatText(toolbarView: self)
    }
    
    @objc private func tappedFormatHeading() {
        delegate?.toolbarExpandingViewDidTapFormatHeading(toolbarView: self)
    }

    @objc private func tappedCitation() {
    }

    @objc private func tappedLink() {
    }

    @objc private func tappedUnorderedList() {
    }

    @objc private func tappedOrderedList() {
    }

    @objc private func tappedDecreaseIndentation() {
    }

    @objc private func tappedIncreaseIndentation() {
    }

    @objc private func tappedCursorUp() {
    }

    @objc private func tappedCursorDown() {
    }

    @objc private func tappedCursorLeft() {
    }

    @objc private func tappedCursorRight() {
    }

    @objc private func tappedTemplate() {
    }

    @objc private func tappedFindInPage() {
        delegate?.toolbarExpandingViewDidTapFind(toolbarView: self)
    }

    @objc private func tappedMedia() {
    }

}
