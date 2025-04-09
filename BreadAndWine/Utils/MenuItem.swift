//
//  MenuItem.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 04.04.25.
//


enum MenuItem: String, CaseIterable, Identifiable {
    case devotions
    case settings
    var id: String { rawValue }
}
