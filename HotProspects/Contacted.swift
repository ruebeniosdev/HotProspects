//
//  Contacted.swift
//  HotProspects
//
//  Created by RUEBEN on 11/09/2022.
//

import SwiftUI

struct Contacted: View {
    var iscontacted: Bool
    var body: some View {
        Image(systemName:  iscontacted ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.fill.badge.xmark" )
            .imageScale(.large)
            .font(.headline)
            .foregroundColor(iscontacted ?  Color.blue : .gray)
    }
}

