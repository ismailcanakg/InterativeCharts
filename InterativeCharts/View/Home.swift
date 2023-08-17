//
//  Home.swift
//  InterativeCharts
//
//  Created by İsmail Can Akgün on 17.08.2023.
//

import SwiftUI
import Charts

struct Home: View {
    // View Properties
    @State private var graphType: GraphType = .donut
    // Char Selection
    @State private var barSelection: String?
    @State private var pieSelection: Double?
    var body: some View {
        VStack {
            // Segmneted Picker
            Picker("", selection: $graphType) {
                ForEach(GraphType.allCases, id: \.rawValue) { type in
                    Text(type.rawValue)
                        .tag(type)
                    
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
           
            ZStack {
                
                if let highestDownloads = appDownloads.max(by: {
                    $1.downloads > $0.downloads
                }) {
                    if graphType == .bar {
                        ChartPopOverView(highestDownloads.downloads, highestDownloads.month, true)
                            .opacity(barSelection == nil ? 1 : 0)
                    } else {
                        if let barSelection, let selectedDownloads =
                            appDownloads.findDownloads(barSelection) {
                            ChartPopOverView(selectedDownloads, barSelection, true, true)
                        } else {
                            ChartPopOverView(highestDownloads.downloads, highestDownloads.month, true)
                        }
                    }
                }
            }
            .padding(.vertical)
            
            // Charts
            Chart {
                ForEach(appDownloads.sorted(by: { graphType == .bar ? false: $0.downloads > $1.downloads })) { download in
                    if graphType == .bar {
                        // Bar Chart
                        BarMark(
                            x: .value("Month", download.month),
                            y: .value("Downloads", download.downloads)
                        )
                        .cornerRadius(8)
                        .foregroundStyle(by: .value("Month", download.month))
                        
                    } else {
                        // NEW API
                        // Pie/Donut Chart
                        SectorMark(
                            angle: .value("Downloads", download.downloads),
                            innerRadius: .ratio(graphType == .donut ? 0.61 : 0),
                            angularInset: graphType == .donut ? 6 : 1
                        )
                        .cornerRadius(8)
                        .foregroundStyle(by: .value("Month", download.month))
                        // Fading Out All other Content, expect for the curren selection
                        .opacity(barSelection == nil ? 1 : (barSelection == download.month ? 1 : 0.4))
                    }
                }
                if let barSelection {
                    RuleMark(x: .value("Month", barSelection))
                        .foregroundStyle(.gray.opacity(0.35))
                        .zIndex(-10)
                        .offset(yStart: -10)
                        .annotation(position: .top,
                                    spacing: 0,
                                    overflowResolution: . init(x: .fit, y: .disabled)) {
                                        if let downloads = appDownloads.findDownloads(barSelection)
                                            {
                                            ChartPopOverView(downloads, barSelection, false)
                            }
                            
                        }
                }
            }
            .chartXSelection(value: $barSelection)
            .chartAngleSelection(value: $pieSelection)
            .chartLegend(position: .bottom, alignment: graphType == .bar ? .leading: .center, spacing: 25)
            .frame(height: 300)
            .padding(.top, 15)
            
            // Adding Animation
            .animation(graphType == .bar ? .none : .snappy, value: graphType)
            
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
        }
        .padding()
        .onChange(of: pieSelection, initial: false) { oldValue, newValue in
            if let newValue {
               findDownload(newValue)
            } else {
                barSelection = nil
            }
            
        }
    }
    // Char Popover View
    @ViewBuilder
    func ChartPopOverView(_ downloads: Double,_ months: String,_ isTitleView: Bool = false,_ isSelection: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(isTitleView && !isSelection ? "Highest": "App") Downloads")
                .font(.title3)
                .foregroundStyle(.black).opacity(0.5)
                
            
            HStack(spacing:4) {
                Text(String(format: "%.0f", downloads))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Text(months)
                    .font(.title3)
                    .textScale(.secondary)
            }
        }
        .padding(isTitleView ? [.horizontal] : [.all] )
        .background(Color(.white).opacity(isTitleView ? 0 : 1), in:.rect(cornerRadius: 10))
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: isTitleView ? .leading : .center)
    }
    
    func findDownload(_ rangeValue: Double) {
        // Converting Download Model intro Array of Tuples
        var initalValue: Double = 0.0
        let convertedArray = appDownloads
            .sorted(by: {$0.downloads > $1.downloads})
            .compactMap { download -> (String,Range<Double>) in
            let rangeEnd = initalValue + download.downloads
            let tuple = (download.month, initalValue..<rangeEnd)
            // Updating Initial Value fot next Iteration
            initalValue = rangeEnd
            return tuple
        }
        
        // Now Finding the Value lies in the Range
        if let dowload = convertedArray.first(where: {
            $0.1.contains(rangeValue)
        }) {
            // Updating Selection
            barSelection = dowload.0
        }
    }
  }


#Preview {
    ContentView()
}
