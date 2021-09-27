import Foundation

enum HTTPMethod: String {
    case `get`, post
    
    var allCaps: String {
        rawValue.uppercased()
    }
}
