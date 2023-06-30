//
//  Post.swift
//  SailsDayJournal
//
//  Created by joe on 2023/06/30.
//

import Foundation

struct Post: Decodable {
    let id: Int
    let title, body: String
}
