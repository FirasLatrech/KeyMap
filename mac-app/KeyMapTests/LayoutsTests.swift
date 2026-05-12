import XCTest
@testable import KeyMap

final class LayoutMapperTableTests: XCTestCase {

    /// Build a synthetic `Table` and verify the converter walks scalars correctly.
    func testScalarMapping() {
        let table = LayoutMapper.Table(
            scalarToString: [
                Unicode.Scalar("h"): "ا",
                Unicode.Scalar("g"): "ل",
                Unicode.Scalar("s"): "س",
                Unicode.Scalar("l"): "م",
                Unicode.Scalar(" "): " ",
                Unicode.Scalar("u"): "ع",
                Unicode.Scalar("d"): "ي",
                Unicode.Scalar(";"): "ك",
            ],
            isStrictlyScalarMap: true
        )
        XCTAssertEqual(table.convert("hgsghl ugd;l"), "السلام عليكم")
    }

    func testIdentityForUnmappedChars() {
        let table = LayoutMapper.Table(
            scalarToString: [Unicode.Scalar("a"): "q"],
            isStrictlyScalarMap: true
        )
        XCTAssertEqual(table.convert("abc 123"), "qbc 123")
    }

    func testNFCNormalizationBeforeLookup() {
        // Decomposed "é" (U+0065 U+0301) should be normalized to U+00E9 before lookup.
        let composed = Unicode.Scalar(0x00E9)!
        let table = LayoutMapper.Table(
            scalarToString: [composed: "X"],
            isStrictlyScalarMap: true
        )
        let decomposed = "e\u{0301}"
        XCTAssertEqual(table.convert(decomposed), "X")
    }
}
