import XCTest
@testable import KeyMap

final class LayoutsTests: XCTestCase {

    func testEnToArHelloPhrase() {
        let result = Layouts.convert("hgsghl ugd;l", direction: .en2ar)
        XCTAssertEqual(result, "السلام عليكم")
    }

    func testEnToArThankYou() {
        XCTAssertEqual(Layouts.convert("a;vh", direction: .en2ar), "شكرا")
    }

    func testRoundTripArEn() {
        let original = "hgsghl"
        let arabic = Layouts.convert(original, direction: .en2ar)
        let back = Layouts.convert(arabic, direction: .ar2en)
        XCTAssertEqual(back, original)
    }

    func testEnToFr() {
        // User typed on AZERTY-shaped keyboard while input source was QWERTY:
        // they intended "azerty", their machine produced "qwerty". Convert back.
        XCTAssertEqual(Layouts.convert("qwerty", direction: .en2fr), "azerty")
    }

    func testDetectArabic() {
        XCTAssertEqual(Layouts.detect("شكرا", azertyEnabled: true), .ar2en)
    }

    func testDetectAzertyOnlyWhenEnabled() {
        XCTAssertEqual(Layouts.detect("café", azertyEnabled: true), .fr2en)
        XCTAssertEqual(Layouts.detect("café", azertyEnabled: false), .en2ar)
    }

    func testPunctuationPassthrough() {
        XCTAssertEqual(Layouts.convert("123 abc", direction: .en2ar).hasPrefix("123 "), true)
    }
}
