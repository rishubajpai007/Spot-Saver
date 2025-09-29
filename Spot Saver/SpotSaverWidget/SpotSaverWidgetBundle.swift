//
//  SpotSaverWidgetBundle.swift
//  SpotSaverWidget
//
//  Created by Rishu Bajpai on 29/09/25.
//

import WidgetKit
import SwiftUI

@main
struct SpotSaverWidgetBundle: WidgetBundle {
    var body: some Widget {
        SpotSaverWidget()
        SpotSaverWidgetControl()
        SpotSaverWidgetLiveActivity()
    }
}
