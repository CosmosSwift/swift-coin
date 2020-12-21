extension String {
    public var isAlphaNumeric: Bool {
        for character in self {
            guard character.isNumber || character.isLetter else {
                return false
            }
        }
        
        return true
    }
}
