//
//  Bren.swift
//  Recordy
//
//  Created by Eric Florenzano on 1/24/23.
//

import Foundation
import simd

struct BrenRenderData: Codable {
    let orientation: UInt
    let fps: UInt
    let view_resolution_x: UInt
    let view_resolution_y: UInt
    let video_resolution_x: UInt
    let video_resolution_y: UInt
    
    init(orientation: UInt, fps: UInt, viewResolutionX: UInt, viewResolutionY: UInt, videoResolutionX: UInt, videoResolutionY: UInt) {
        self.orientation = orientation
        self.fps = fps
        self.view_resolution_x = viewResolutionX
        self.view_resolution_y = viewResolutionY
        self.video_resolution_x = videoResolutionX
        self.video_resolution_y = videoResolutionY
    }
}

struct BrenCameraFrames: Codable {
    let timestamps: [Float]
    let transforms: [[[Float]]]
    let datas: [[Float]]
    
    init(timestamps: [Float], transforms: [simd_float4x4], datas: [BrenLensData]) {
        self.timestamps = timestamps
        self.transforms = transforms.map(create_transform)
        self.datas = datas.map({ dat in dat.data })
    }
}

struct BrenPlane: Codable {
    let transform: [[Float]]
    let alignment: String
    
    init(transform: simd_float4x4, alignment: String) {
        self.transform = create_transform(transform: transform)
        self.alignment = alignment
    }
}

struct BrenWrapper: Codable {
    var version_major: Int = 1 // only mutable so that it serializes
    var version_minor: Int = 2 // only mutable so that it serializes
    let render_data: BrenRenderData
    let camera_frames: BrenCameraFrames
    let planes: [BrenPlane]
    let tracked_transforms: [[[Float]]]
    
    init(_ renderData: BrenRenderData, _ cameraFrames: BrenCameraFrames, _ planes: [BrenPlane], _ trackedTransforms: [simd_float4x4]) {
        render_data = renderData
        camera_frames = cameraFrames
        self.planes = planes
        tracked_transforms = trackedTransforms.map(create_transform)
    }
}

// Utility

func create_transform(transform tfm: simd_float4x4) -> [[Float]] {
    return [
        [tfm.columns.0.x, tfm.columns.1.x, tfm.columns.2.x, tfm.columns.3.x],
        [tfm.columns.0.y, tfm.columns.1.y, tfm.columns.2.y, tfm.columns.3.y],
        [tfm.columns.0.z, tfm.columns.1.z, tfm.columns.2.z, tfm.columns.3.z],
        [tfm.columns.0.w, tfm.columns.1.w, tfm.columns.2.w, tfm.columns.3.w]
    ]
}

struct BrenLensData: Codable {
    let data: [Float]
    
    var focalLength: Float { get { return data[0] } }
    var sensorHeight: Float { get { return data[1] } }
    
    init(focalLength: CGFloat,
         sensorHeight: CGFloat) {
        data = [
            Float(focalLength),
            Float(sensorHeight),
        ]
    }
}
