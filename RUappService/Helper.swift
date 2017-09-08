
extension Dictionary {
    func appPrepare() -> Data? {
        guard let
            jsonData = try? JSONSerialization.data(withJSONObject: self, options: []),
            let string = String(data: jsonData, encoding: String.Encoding.utf8) else {
                return nil
        }
        return ("requisitionData=" + string).data(using: String.Encoding.utf8)
    }
}
