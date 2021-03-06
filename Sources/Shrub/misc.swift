extension Collection {
    
    var ifNotEmpty: Self? { isEmpty ? nil : self }
    
    var array: [Element] { Array(self) }
}
