
// Handles hide/display of article table of contents
// Manages a stack view and the associated constraints

protocol ArticleTableOfContentsDisplayControllerDelegate : TableOfContentsViewControllerDelegate {
    func tableOfContentsDisplayControllerDidRecreateTableOfContentsViewController()
}

class ArticleTableOfContentsDisplayController: Themeable {
    
    weak var delegate: ArticleTableOfContentsDisplayControllerDelegate?
    
    lazy var viewController: TableOfContentsViewController = {
        return recreateTableOfContentsViewController()
    }()
    
    var theme: Theme = .standard
    func apply(theme: Theme) {
        self.theme = theme
        separatorView.backgroundColor = theme.colors.baseBackground
        stackView.backgroundColor = theme.colors.paperBackground
        inlineContainerView.backgroundColor = theme.colors.midBackground
        viewController.apply(theme: theme)
    }
    
    func recreateTableOfContentsViewController() -> TableOfContentsViewController {
        let displaySide: TableOfContentsDisplaySide = stackView.semanticContentAttribute == .forceRightToLeft ? .right : .left
        return TableOfContentsViewController(delegate: delegate, theme: theme, displaySide: displaySide)
    }
    
    init (articleView: UIView, delegate: ArticleTableOfContentsDisplayControllerDelegate, theme: Theme) {
        self.delegate = delegate
        self.theme = theme
        stackView.semanticContentAttribute = delegate.tableOfContentsSemanticContentAttribute
        stackView.addArrangedSubview(inlineContainerView)
        stackView.addArrangedSubview(separatorView)
        stackView.addArrangedSubview(articleView)
        NSLayoutConstraint.activate([separatorWidthConstraint])
    }

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()

    lazy var separatorView: UIView = {
        let sv = UIView(frame: .zero)
        sv.isHidden = true
        return sv
    }()
    
    lazy var inlineContainerView: UIView = {
        let cv = UIView(frame: .zero)
        cv.isHidden = true
        return cv
    }()
    
    lazy var separatorWidthConstraint: NSLayoutConstraint = {
        return separatorView.widthAnchor.constraint(equalToConstant: 1)
    }()

    func show(animated: Bool) {
        switch viewController.displayMode {
        case .inline:
            showInline()
        case .modal:
            showModal(animated: animated)
        }
    }
    
    func hide(animated: Bool) {
       switch viewController.displayMode {
       case .inline:
           hideInline()
       case .modal:
           hideModal(animated: animated)
       }
    }
    
    func showModal(animated: Bool) {
        viewController.isVisible = true
        guard delegate?.presentedViewController == nil else {
            return
        }
        delegate?.present(viewController, animated: animated)
    }
    
    func hideModal(animated: Bool) {
        viewController.isVisible = false
        delegate?.dismiss(animated: animated)
    }
    
    func showInline() {
        viewController.isVisible = true
        UserDefaults.wmf.wmf_setTableOfContentsIsVisibleInline(true)
        inlineContainerView.isHidden = false
        separatorView.isHidden = false
    }
    
    func hideInline() {
        viewController.isVisible = false
        UserDefaults.wmf.wmf_setTableOfContentsIsVisibleInline(false)
        inlineContainerView.isHidden = true
        separatorView.isHidden = true
    }
    
    func update(with traitCollection: UITraitCollection) {
        let isCompact = traitCollection.horizontalSizeClass == .compact
        viewController.displayMode = isCompact ? .modal : .inline
        setupTableOfContentsViewController()
    }
    
    func setupTableOfContentsViewController() {
        switch viewController.displayMode {
        case .inline:
            guard viewController.parent != delegate else {
                return
            }
            let wasVisible = viewController.isVisible
            if wasVisible {
                hideModal(animated: false)
            }
            viewController = recreateTableOfContentsViewController()
            viewController.displayMode = .inline
            delegate?.addChild(viewController)
            inlineContainerView.wmf_addSubviewWithConstraintsToEdges(viewController.view)
            viewController.didMove(toParent: delegate)
            if wasVisible {
                showInline()
            }
            delegate?.tableOfContentsDisplayControllerDidRecreateTableOfContentsViewController()
        case .modal:
            guard viewController.parent == delegate else {
                return
            }
            let wasVisible = viewController.isVisible
            viewController.displayMode = .modal
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
            viewController = recreateTableOfContentsViewController()
            if wasVisible {
                hideInline()
                showModal(animated: false)
            }
            delegate?.tableOfContentsDisplayControllerDidRecreateTableOfContentsViewController()
        }
    }

}
