//
//  TrainingWidget.swift
//  TrainingWidget
//
//  Created by Ondrej Kondek on 18/03/2021.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), running: false, actualSport: 0, reset: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), running: false, actualSport: 0, reset: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        var entries: [SimpleEntry] = []

        // get all the info from main App via UserDefaults
        let info = UserDefaultsManager.shared.getWidgetTrainingInfo()
        var sport = 0
        var running = false
        var reset = true
        var startTime = Date()
        
        if let infoSport = info.0 {
            sport = infoSport
            if let infoRunning = info.1 {
                running = infoRunning
                if let infoReset = info.2 {
                    reset = infoReset
                    if let infoTime = info.3 {
                        startTime = infoTime
                    }
                }
            }
        }

        let entry = SimpleEntry(date: startTime, running: running, actualSport: sport, reset: reset)
        entries.append(entry)

        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let running: Bool
    let actualSport: Int
    let reset: Bool
}

struct TrainingWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        
        HStack{
            Spacer()
            VStack{
                Image(uiImage: UIImage(named: "logoclean")!)
                    .resizable().scaledToFill()
                    .frame(width: 70, height: 70, alignment: .center)
            }.padding(10)

            VStack{
                Spacer()
                HStack{
                    if (entry.running){
                        Text("Started:").font(.title3).colorInvert()
                        Text(entry.date, style: .time).font(Font.title.bold()).colorInvert()
                    }
                    else{
                        if (entry.reset){
                            Text("Start a new training").font(.title3).colorInvert()
                        }
                        else{
                            Text("Paused").font(.title3).colorInvert()
                        }
                    }
                }
                Spacer()
                HStack{
                    Spacer()
                    if (entry.running){
                        Link("  ", destination: URL(string: "training://start")!)
                            .background(Image(uiImage: UIImage(named: "pause")!)
                                            .resizable().scaledToFill()
                                            .frame(width: 45, height: 45, alignment: .center))
                    }
                    else {
                        Link("  ", destination: URL(string: "training://start")!)
                            .background(Image(uiImage: UIImage(named: "play")!)
                                            .resizable().scaledToFill()
                                            .frame(width: 45, height: 45, alignment: .center))
                    }
                    
                    Spacer()
                    Link("  ", destination: URL(string: "training://reset")!)
                        .background(Image(uiImage: UIImage(named: "reset")!)
                                        .resizable().scaledToFill()
                                        .frame(width: 45, height: 45, alignment: .center))

                    Spacer()
                    Link("  ", destination: URL(string: "training://choose")!)
                        .background(Image(uiImage: SportType.sportsArray[entry.actualSport].image)
                                        .resizable().scaledToFill()
                                        .frame(width: 45, height: 45, alignment: .center))
                    Spacer()
                }
                Spacer()
            }
            Spacer()
        }.background(Image(uiImage: UIImage(named: "widgetbackground")!).resizable().scaledToFill())
    }
}

@main
struct TrainingWidget: Widget {
    let kind: String = "TrainingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TrainingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tajmer widget")
        .description("Widget makes using Tajmer simple.")
        .supportedFamilies([.systemMedium])
    }
}

struct TrainingWidget_Previews: PreviewProvider {
    static var previews: some View {
        TrainingWidgetEntryView(entry: SimpleEntry(date: Date(), running: false, actualSport: 0, reset: true))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
