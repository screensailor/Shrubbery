class Multicast™: Hopes {
    
    func test() throws {
        
        let s = CurrentValueSubject<Int, Never>(0)
        
        
        
        Just(5).multicast(subject: s)
    }
}
