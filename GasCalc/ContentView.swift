//
//  ContentView.swift
//  GasCalc
//
//  Created by Mattheus Wolff on 11/3/22.
//
import CoreData
import SwiftSoup
import SwiftUI

struct ContentView: View {
    @State private var dist: String = ""
    @State private var cost: String = "0.00"
    @State private var us_state: String = ""
    @State private var year: String = ""
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var mpg_dict: [String: [String: String]] = [:]
    
    func populateMpg() {
        let fileURL = Bundle.main.url(forResource:"Data/\(year)", withExtension: "json")!
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            mpg_dict = try decoder.decode([String: [String: String]].self, from: data)
        } catch {
            print(error)
        }
    }
    
    func calcGas() {
        cost = ""
        let url = URL(string: "https://gasprices.aaa.com/?state=" + (state_abbreviations[us_state]!))!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                cost = "Error, try again."
                return
            }
            guard let data = data else {
                print("Invalid data")
                cost = "Error, try again."
                return
            }
            let raw_html = String(data: data, encoding: .utf8) ?? ""
            var dolPerGal: Double = 0
            do {
                let doc: Document = try SwiftSoup.parse(raw_html)
                let price_table = try doc.select("table").first()!
                dolPerGal = try Double(price_table.getElementsByTag("td").get(1).text().suffix(5))!
            } catch Exception.Error(_, let message) {
                print(message)
                cost = "Error, try again."
            } catch {
                print("Error")
                cost = "Error, try again."
            }
            let distNum: Double = Double(dist) ?? 0
            let galPerDist: Double = 1 / Double(mpg_dict[make]![model]!)!
            let newCost = distNum * galPerDist * dolPerGal
            let roundedCost: Double = round(newCost * 100) / 100.0
            var costStrs = String(roundedCost).components(separatedBy: ".")
            if (costStrs[1].count == 1) {
                costStrs[1] += "0"
            }
            cost = costStrs[0] + "." + costStrs[1]
        }.resume()
    }
    
    func canConvertToDouble(string: String) -> Bool {
        return Double(string) != nil
    }
    
    var body: some View {
        let years: Array = (1984 ... 2023).reversed().map{String($0)}
        Form {
            Text("GasCalc ⛽️")
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.title)
            Section(header: Text("Vehicle")) {
                Picker("Year", selection: $year) {
                    Text("").tag("")
                    ForEach(years, id:\.self) {
                        Text(String($0))
                    }
                }.onChange(of: year) { _ in
                    make = ""
                    model = ""
                    if !year.isEmpty {
                        populateMpg()
                    }
                }
                Picker("Make", selection: $make) {
                    Text("").tag("")
                    ForEach(Array(mpg_dict.keys).sorted(), id:\.self) {
                        Text($0)
                    }
                }.onChange(of: make) { _ in
                    model = ""
                }
                Picker("Model", selection: $model) {
                    Text("").tag("")
                    if !make.isEmpty {
                        ForEach(Array(mpg_dict[make]!.keys).sorted(), id:\.self) {
                            Text($0)
                        }
                    }
                }
            }
            Section(header: Text("Trip")) {
                Picker("State", selection: $us_state) {
                    Text("").tag("")
                    ForEach(Array(state_abbreviations.keys).sorted(), id:\.self) {
                        Text($0)
                    }
                }
                TextField(
                    "Miles Traveled",
                    text: $dist
                )
            }
            Section {
                Button(
                    action: {
                        calcGas()
                    }
                ) {
                    Label("Get Gas Cost", systemImage: "fuelpump")
                }
                .disabled(year.isEmpty || make.isEmpty || model.isEmpty || us_state.isEmpty || !canConvertToDouble(string: dist))
                if !cost.isEmpty {
                    Text("Cost: $" + String(cost))
                }
                else {
                    ProgressView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
