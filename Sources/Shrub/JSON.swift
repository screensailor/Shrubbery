import Foundation

public typealias JSON = Shrub<String, JSONFragment>
public typealias JSONIndex = Fork<String>
public typealias JSONRoute = Route<String>

public protocol JSONFragment {}

extension NSNull: JSONFragment {}
extension Bool: JSONFragment {}
extension Double: JSONFragment {}
extension String: JSONFragment {}
