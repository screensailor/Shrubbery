import Foundation

public typealias JSON = Shrub<String, JSONFragment>

public protocol JSONFragment {}

extension NSNull: JSONFragment {}
extension Bool: JSONFragment {}
extension Double: JSONFragment {}
extension String: JSONFragment {}
