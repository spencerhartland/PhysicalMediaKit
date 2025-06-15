//
//  EntityExtension.swift
//  TestingModel3D
//
//  Created by Spencer Hartland on 5/4/25.
//

import RealityKit

extension Entity {
    func modifyMaterials(_ closure: (RealityFoundation.Material) throws -> RealityFoundation.Material) rethrows {
        try children.forEach { try $0.modifyMaterials(closure) }
        
        guard var comp = components[ModelComponent.self] else { return }
        comp.materials = try comp.materials.map { try closure($0) }
        components[ModelComponent.self] = comp
    }
}
