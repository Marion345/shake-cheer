import XCTest
@testable import ShakeCheer

final class SoundCatalogTests: XCTestCase {
    func testBuiltInSoundIDsAreUnique() {
        let ids = SoundCatalog.allSounds.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testFreeAndProSoundsPartitionCatalog() {
        XCTAssertEqual(SoundCatalog.freeSounds.count, 3)
        XCTAssertEqual(SoundCatalog.proSounds.count, 5)
        XCTAssertEqual(
            Set(SoundCatalog.freeSounds + SoundCatalog.proSounds),
            Set(SoundCatalog.allSounds)
        )
    }

    func testEveryBuiltInSoundHasAudioMetadata() {
        for sound in SoundCatalog.allSounds {
            XCTAssertFalse(sound.fileName.isEmpty)
            XCTAssertFalse(sound.fileExtension.isEmpty)
        }
    }

    func testCatalogCanFilterByCategory() {
        XCTAssertTrue(SoundCatalog.sounds(in: .sports).contains(SoundCatalog.bell))
        XCTAssertTrue(SoundCatalog.sounds(in: .party).contains(SoundCatalog.drum))
        XCTAssertTrue(SoundCatalog.sounds(in: .custom).isEmpty)
    }

    func testSustainedPlaybackMetadata() {
        XCTAssertEqual(SoundCatalog.bell.playbackMode, .impact)
        XCTAssertEqual(SoundCatalog.cheer.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.drum.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.stadiumHorn.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.drum.loopEndTime, 4.69)
        XCTAssertEqual(SoundCatalog.stadiumHorn.loopEndTime, 2.10)
        XCTAssertEqual(SoundCatalog.airHorn.category, .party)
        XCTAssertEqual(SoundCatalog.sadTrumpet.category, .funny)
    }
}
