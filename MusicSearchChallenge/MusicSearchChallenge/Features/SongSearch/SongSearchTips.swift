//
//  SongSearchTips.swift
//  MusicSearchChallenge
//
//  Created by Codex on 12/04/26.
//

import SwiftUI
import TipKit

struct SearchStartTip: Tip {
    var title: Text {
        Text("search.tip.start.title")
    }

    var message: Text? {
        Text("search.tip.start.message")
    }

    var image: Image? {
        Image(systemName: "magnifyingglass")
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}

struct RecentPlayedDeleteTip: Tip {
    var title: Text {
        Text("recent_played.tip.delete.title")
    }

    var message: Text? {
        Text("recent_played.tip.delete.message")
    }

    var image: Image? {
        Image(systemName: "hand.draw")
    }

    var options: [any TipOption] {
        Tips.MaxDisplayCount(1)
    }
}
