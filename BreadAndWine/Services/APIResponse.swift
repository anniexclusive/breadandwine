//
//  APIResponse.swift
//  BreadAndWine
//
//  Created by Anne Ezurike on 31.03.25.
//


struct APIResponse<T: Codable>: Codable {
    let status: String
    let data: [T]
}