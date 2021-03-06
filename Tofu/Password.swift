import Foundation

final class Password {
  var algorithm: Algorithm = .SHA1
  var counter = 0
  var digits = 6
  var period = 30
  var secret = NSData()
  var timeBased = false

  func valueForDate(date: NSDate) -> String {
    let counter = timeBased ?
      Int64(date.timeIntervalSince1970) / Int64(period) : Int64(self.counter)
    var input = counter.bigEndian
    let digest = UnsafeMutablePointer<UInt8>.alloc(algorithm.digestLength)
    defer { digest.destroy() }
    CCHmac(algorithm.hmacAlgorithm, secret.bytes, secret.length, &input, sizeofValue(input), digest)
    let bytes = UnsafePointer<UInt8>(digest)
    let offset = bytes[algorithm.digestLength - 1] & 0x0f
    let number = UInt32(bigEndian: UnsafePointer<UInt32>(bytes + Int(offset)).memory) & 0x7fffffff
    return String(format: "%0\(digits)d", number % UInt32(pow(10, Float(digits))))
  }

  func progressForDate(date: NSDate) -> Double {
    return timeIntervalRemainingForDate(date) / Double(period)
  }

  func timeIntervalRemainingForDate(date: NSDate) -> Double {
    let period = Double(self.period)
    return period - (date.timeIntervalSince1970 % period)
  }
}
