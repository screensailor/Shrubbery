extension CurrentValueSubject: ExpressibleByNilLiteral
where Output: ExpressibleByNilLiteral
{
    public convenience init(nilLiteral: ()) { self.init(nil) }
}
