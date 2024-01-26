import Foundation

struct WKFindAndReplaceViewModel {

    enum Configuration {
        case findOnly
        case findAndReplace
    }
    
    var currentMatchInfo: String?
    var matchCount: Int = 0
    var nextPrevButtonsAreEnabled: Bool = false
    var replaceButtonIsEnabled: Bool = false
    
    let configuration: Configuration = .findAndReplace
    
    mutating func reset() {
        currentMatchInfo = nil
        nextPrevButtonsAreEnabled = false
    }
}
