import XCTest
@testable import ShakeCheer

final class SoundCatalogTests: XCTestCase {
    func testBuiltInSoundIDsAreUnique() {
        let ids = SoundCatalog.allSounds.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testFreeAndProSoundsPartitionCatalog() {
        XCTAssertEqual(SoundCatalog.freeSounds.count, 3)
        XCTAssertEqual(SoundCatalog.proSounds.count, 20)
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
        XCTAssertEqual(
            SoundCatalog.sounds(in: .basic),
            [SoundCatalog.bell, SoundCatalog.applause, SoundCatalog.noisemaker]
        )
        XCTAssertTrue(SoundCatalog.sounds(in: .sports).contains(SoundCatalog.cheer))
        XCTAssertTrue(SoundCatalog.sounds(in: .sports).contains(SoundCatalog.drum))
        XCTAssertTrue(SoundCatalog.sounds(in: .sports).contains(SoundCatalog.refereeWhistle))
        XCTAssertEqual(SoundCatalog.sounds(in: .sports).count, 5)
        XCTAssertEqual(SoundCatalog.sounds(in: .party).count, 5)
        XCTAssertTrue(SoundCatalog.sounds(in: .party).contains(SoundCatalog.airHorn))
        XCTAssertTrue(SoundCatalog.sounds(in: .party).contains(SoundCatalog.champagnePops))
        XCTAssertEqual(SoundCatalog.sounds(in: .gaming).count, 5)
        XCTAssertTrue(SoundCatalog.sounds(in: .gaming).contains(SoundCatalog.victory))
        XCTAssertTrue(SoundCatalog.sounds(in: .gaming).contains(SoundCatalog.gameOver))
        XCTAssertTrue(SoundCatalog.sounds(in: .funny).contains(SoundCatalog.laughTrack))
        XCTAssertTrue(SoundCatalog.sounds(in: .custom).isEmpty)
    }

    func testSelectableCategoriesPrepareFreeAndProAccess() {
        XCTAssertEqual(SoundCatalog.selectableCategories.first, .basic)
        XCTAssertFalse(SoundCatalog.selectableCategories.contains(.custom))
        XCTAssertEqual(SoundCategory.basic.accessLevel, .free)
        XCTAssertEqual(
            Set(SoundCatalog.freeSounds),
            Set([SoundCatalog.bell, SoundCatalog.applause, SoundCatalog.noisemaker])
        )
        XCTAssertEqual(SoundCatalog.cheer.accessLevel, .pro)
        XCTAssertEqual(SoundCatalog.drum.accessLevel, .pro)
        XCTAssertTrue(
            SoundCatalog.selectableCategories
                .filter { $0 != .basic }
                .allSatisfy { $0.accessLevel == .pro }
        )
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
        XCTAssertEqual(SoundCatalog.boo.category, .funny)
        XCTAssertEqual(SoundCatalog.boo.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.boo.fileName, "boo")
        XCTAssertEqual(SoundCatalog.boo.loopEndTime, 3.90)
        XCTAssertEqual(SoundCatalog.crowdDisappointment.category, .funny)
        XCTAssertEqual(SoundCatalog.crowdDisappointment.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.crowdDisappointment.fileName, "boo-crowd")
        XCTAssertEqual(SoundCatalog.crickets.category, .funny)
        XCTAssertEqual(SoundCatalog.crickets.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.crickets.loopEndTime, 9.30)
        XCTAssertEqual(SoundCatalog.sadTrumpet.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.sadTrumpet.loopEndTime, 2.30)
        XCTAssertEqual(SoundCatalog.sadTrumpet.volumeMultiplier, 1.55)
        XCTAssertEqual(SoundCatalog.refereeWhistle.playbackMode, .impact)
        XCTAssertEqual(SoundCatalog.coin.playbackMode, .impact)
        XCTAssertEqual(SoundCatalog.levelUp.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.podium.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.victory.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.laughTrack.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.crowdHey.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.partyBlower.playbackMode, .sustained)
        XCTAssertEqual(SoundCatalog.djScratch.playbackMode, .impact)
        XCTAssertEqual(SoundCatalog.champagnePops.playbackMode, .impact)
        XCTAssertEqual(SoundCatalog.failBuzzer.playbackMode, .impact)
        XCTAssertEqual(SoundCatalog.gameOver.playbackMode, .impact)
    }
}
