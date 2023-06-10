//
//  RemembrWidget.swift
//  RemembrWidget
//
//  Created by Fabiola Villatoro on 6/7/23.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> DayEntry  {
        DayEntry (date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (DayEntry ) -> ()) {
        let entry = DayEntry (date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry ] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate )
            let entry = DayEntry (date: startOfDate , configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry : TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct RemembrWidgetEntryView : View {
    var entry: DayEntry
    var config: MonthConfig

    init(entry: DayEntry)  {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(config.backgroundColor.gradient)
            
            VStack{
                HStack(spacing: 2){
                    Spacer()
                    Text(config.emojiText )
                        .font(.title )
                    Text(entry.date.weekdayDisplayFormat )
                        .font(.title3)
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.6 )
                        .foregroundColor(config.weekdayTextColor)
                    Spacer()
                }
                Text(entry.date.dayDisplayFormat)
                    .font(.system(size:80, weight: .heavy))
                    .foregroundColor(config.dayTextColor)
            }
            .padding()
        }
    }
}

struct RemembrWidget: Widget {
    let kind: String = "RemembrWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            RemembrWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Monthly Style Widget")
        .description("Theme of widget changes")
        .supportedFamilies([.systemSmall ])
    }
}

struct RemembrWidget_Previews: PreviewProvider {
    static var previews: some View {
        RemembrWidgetEntryView(entry: DayEntry (date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
    
    static func dateToDisplay(month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: Calendar.current,
                                        year: 2023, month: month, day: day)
        return Calendar.current.date(from: components)!
    }
}


extension Date{
    var weekdayDisplayFormat: String {
        self.formatted(.dateTime.weekday(.wide ))
    }
    
    var dayDisplayFormat : String {
        self.formatted(.dateTime.day( ))
    }
}
