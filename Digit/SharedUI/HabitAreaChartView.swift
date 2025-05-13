import SwiftUI
import Charts

// MARK: - Chart Range Enum
enum HabitChartRange {
    case week
    case month
    case year
}

// MARK: - HabitAreaChartView
struct HabitAreaChartView: View {
    let data: [Int]
    let range: HabitChartRange
    private let maxY: Int = 10 // Adjust if your data can exceed 10
    private let yTickInterval: Int = 2
    private let areaColor: Color = Color.digitBrand.opacity(0.6)
    private let lineColor: Color = Color.digitBrand

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            chartView
        }
        .padding(.vertical, 8)
    }

    // MARK: - Chart View
    private var chartView: some View {
        let areaMarks = ForEach(data.indices, id: \ .self) { i in
            AreaMark(
                x: .value("Day", i + 1),
                y: .value("Habits", data[i])
            )
            .foregroundStyle(areaColor)
            .interpolationMethod(.catmullRom)
        }
        let lineMarks = ForEach(data.indices, id: \ .self) { i in
            LineMark(
                x: .value("Day", i + 1),
                y: .value("Habits", data[i])
            )
            .foregroundStyle(lineColor)
            .interpolationMethod(.catmullRom)
            .lineStyle(StrokeStyle(lineWidth: 2))
        }
        let pointMarks = ForEach(data.indices, id: \ .self) { i in
            PointMark(
                x: .value("Day", i + 1),
                y: .value("Habits", data[i])
            )
            .symbolSize(30)
            .foregroundStyle(lineColor)
        }
        let yAxisTicks = Array(stride(from: 0, through: maxY, by: yTickInterval))
        let (xAxisTicks, xAxisLabels): ([Int], [String]?) = {
            switch range {
            case .year:
                let months = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"]
                return (Array(1...12), months)
            case .week, .month:
                return (Array(1...data.count), nil)
            }
        }()
        return Chart {
            areaMarks
            lineMarks
            pointMarks
        }
        .chartXAxis {
            AxisMarks(values: xAxisTicks) { value in
                if let intValue = value.as(Int.self) {
                    switch range {
                    case .year:
                        if intValue >= 1 && intValue <= 12, let labels = xAxisLabels {
                            AxisValueLabel(labels[intValue - 1], centered: true)
                        }
                    case .week, .month:
                        if intValue % 2 == 1 || intValue == 1 || intValue == data.count {
                            AxisValueLabel("\(intValue)", centered: true)
                        }
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(values: yAxisTicks) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: []))
                    .foregroundStyle(Color.digitBrand.opacity(0.5))
                AxisTick(stroke: StrokeStyle(lineWidth: 2))
                    .foregroundStyle(Color.digitBrand)
                if let intValue = value.as(Int.self) {
                    AxisValueLabel("\(intValue)")
                }
            }
        }
        .chartYScale(domain: 0...maxY)
        .frame(height: 180)
        .padding(.trailing, 8)
        .padding(.bottom, 8)
        .background(Color.digitBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.digitBrand.opacity(0.15), lineWidth: 1)
        )
        .scrollClipDisabled()
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: range == .year ? 12 : 10)
    }
}

// MARK: - Preview
#if DEBUG
struct HabitAreaChartView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HabitAreaChartView(data: Array(repeating: 0, count: 12).enumerated().map { i, _ in Int.random(in: 2...10) }, range: .year)
                .padding()
                .background(Color.digitBackground)
            HabitAreaChartView(data: Array(repeating: 0, count: 30).enumerated().map { i, _ in Int.random(in: 2...10) }, range: .month)
                .padding()
                .background(Color.digitBackground)
        }
    }
}
#endif
