//
// This source file is part of the NutriSight project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import AVFoundation
import CoreImage
import ImageIO
import Testing


@Suite("Mock camera media")
struct MockCameraMediaTests {
    @Test("Matches glasses media formats and on-screen framing")
    func matchesGlassesMediaAndFraming() async throws {
        let photoURL = try #require(Bundle.main.url(forResource: "CheeseSpaetzle", withExtension: "jpg"))
        let videoURL = try #require(Bundle.main.url(forResource: "CheeseSpaetzleFeed", withExtension: "mov"))
        let photoSource = try #require(CGImageSourceCreateWithURL(photoURL as CFURL, nil))
        let photo = try #require(CGImageSourceCreateImageAtIndex(photoSource, 0, nil))

        #expect(photo.width == 3024)
        #expect(photo.height == 4032)
        #expect(photo.width * 4 == photo.height * 3)

        let asset = AVURLAsset(url: videoURL)
        let track = try #require(await asset.loadTracks(withMediaType: .video).first)
        let naturalSize = try await track.load(.naturalSize)
        let transform = try await track.load(.preferredTransform)
        let displayedSize = naturalSize.applying(transform)
        let width = Int(abs(displayedSize.width))
        let height = Int(abs(displayedSize.height))
        let frameRate = try await track.load(.nominalFrameRate)
        let duration = try await asset.load(.duration)
        let formatDescriptions = try await track.load(.formatDescriptions)
        let codec = formatDescriptions.first.map(CMFormatDescriptionGetMediaSubType)

        #expect(width == 540)
        #expect(height == 960)
        #expect(width * 16 == height * 9)
        #expect(frameRate == 24)
        #expect(CMTimeGetSeconds(duration) == 5)
        #expect(codec == FourCharCode(0x68766331)) // hvc1

        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let videoFrame = try await generator.image(at: CMTime(seconds: 2.5, preferredTimescale: 600)).image
        let photoPixels = normalizedPixels(for: CIImage(cgImage: photo))
        let videoPixels = normalizedPixels(for: CIImage(cgImage: videoFrame))

        #expect(meanAbsoluteDifference(photoPixels, videoPixels) < 0.06)
    }

    private func normalizedPixels(for image: CIImage) -> [UInt8] {
        let outputWidth = 54
        let outputHeight = 96
        let scale = max(
            Double(outputWidth) / image.extent.width,
            Double(outputHeight) / image.extent.height
        )
        let scaled = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let xOffset = (scaled.extent.width - Double(outputWidth)) / 2
        let yOffset = (scaled.extent.height - Double(outputHeight)) / 2
        let normalized = scaled
            .transformed(by: CGAffineTransform(translationX: -xOffset, y: -yOffset))
            .cropped(to: CGRect(x: 0, y: 0, width: outputWidth, height: outputHeight))

        var pixels = [UInt8](repeating: 0, count: outputWidth * outputHeight * 4)
        unsafe CIContext().render(
            normalized,
            toBitmap: &pixels,
            rowBytes: outputWidth * 4,
            bounds: normalized.extent,
            format: .RGBA8,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB)
        )
        return pixels
    }

    private func meanAbsoluteDifference(_ lhs: [UInt8], _ rhs: [UInt8]) -> Double {
        precondition(lhs.count == rhs.count)
        var totalDifference = 0
        var comparedValues = 0
        for index in lhs.indices where index % 4 != 3 {
            totalDifference += abs(Int(lhs[index]) - Int(rhs[index]))
            comparedValues += 1
        }
        return Double(totalDifference) / Double(comparedValues) / 255
    }
}
