import Foundation

public typealias DeltaJSON = DeltaShrub<String> // TODO:❗️DeltaHedge<String, JSONFragment>

public typealias JSON = Shrub<String> // TODO:❗️Hedge<String, JSONFragment>

extension JSON {
    public typealias Fragment = JSONFragment
}

public protocol JSONFragment {}

extension NSNull: JSON.Fragment {}
extension Bool: JSON.Fragment {}
extension Double: JSON.Fragment {}
extension String: JSON.Fragment {}
