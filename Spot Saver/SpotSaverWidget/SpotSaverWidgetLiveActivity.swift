//
//  SpotSaverWidgetLiveActivity.swift
//  SpotSaverWidget
//
//  Created by Rishu Bajpai on 29/09/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct SpotSaverWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct SpotSaverWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SpotSaverWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension SpotSaverWidgetAttributes {
    fileprivate static var preview: SpotSaverWidgetAttributes {
        SpotSaverWidgetAttributes(name: "World")
    }
}

extension SpotSaverWidgetAttributes.ContentState {
    fileprivate static var smiley: SpotSaverWidgetAttributes.ContentState {
        SpotSaverWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: SpotSaverWidgetAttributes.ContentState {
         SpotSaverWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: SpotSaverWidgetAttributes.preview) {
   SpotSaverWidgetLiveActivity()
} contentStates: {
    SpotSaverWidgetAttributes.ContentState.smiley
    SpotSaverWidgetAttributes.ContentState.starEyes
}
