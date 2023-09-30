//
//  ContentView.swift
//  BetterRest
//
//  Created by Godwin IE on 25/09/2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeup = defaultWakeTime {
        didSet {
            calculateBedtime()
        }
    }
    @State private var sleepAmount = 8.0 {
        didSet {
            calculateBedtime()
        }
    }
    @State private var coffeeAmount = 1 {
        didSet {
            calculateBedtime()
        }
    }
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    
    
    static var defaultWakeTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
     var recommendedBedTime : Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }

    var body: some View {
        NavigationView {
            Form {
                
                Section{
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("Pick a date", selection: $wakeup, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section {
                    Text("How long do you want to sleep?")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section {
                    Picker ("Daily coffee intake", selection: $coffeeAmount) {
                        ForEach(1..<11) { coffee in
                            Text (coffee == 1 ? "1 cup" : "\(coffee) cups")
                        }
                    }
                    
                }
                
                VStack (alignment: .center, spacing: 8) {
                    Text("Ideal bed time")
                        .font(.body)
                        .foregroundColor(.gray)
                    Text(alertMessage)
                        .font(.largeTitle)
                        .foregroundColor(.green)
                } // Vstack
                .frame(maxWidth: .infinity)
                .padding()

                
                } //Form
            .navigationTitle("Better Rest")
            .onAppear {
                           // Call calculateBedtime when the view appears
                           calculateBedtime()
                       }
            .onChange(of: wakeup, perform: { _ in
                            calculateBedtime()
                        })
                        .onChange(of: sleepAmount, perform: { _ in
                            calculateBedtime()
                        })
                        .onChange(of: coffeeAmount, perform: { _ in
                            calculateBedtime()
                        })
//            .toolbar {
//                Button("Calculate", action: calculateBedtime)
//            }
//            .alert(alertTitle, isPresented: $showAlert) {
//                Button("OK") { }
//            } message: {
//                Text(alertMessage)
//            }
            
        } //Nav View
    }
    
    func calculateBedtime () {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeup)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeup - prediction.actualSleep
            
            alertTitle = "🎑 Your ideal bedtime is ..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)

        } catch {
            alertTitle = "Error"
            alertTitle = "Sorry, there was an error while calculating your bedtime"
        }
        
        showAlert = true
    } //calculateBedtime function
    
    
    //get recommended time
    func getTimeStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // Use the desired time format
        return dateFormatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
