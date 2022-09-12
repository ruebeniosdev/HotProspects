//
//  ProspectsView.swift
//  HotProspects
//
//  Created by RUEBEN on 09/09/2022.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    @State private var showsort = false
    @State private var isShowingScanner = false
    
    @State private var sortType: SortType = .name
    
    enum SortType {
        case name, recent
    }
    
   
    
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    @EnvironmentObject var prospects: Prospects
    
    let filter: FilterType
    
    
    
    
    let random = ["Victor\nvictorbruce.dev", "Ruebeniosdev\nruebeniosdev.com", "Brian\nbrown.b.com", "Alisson\nwood.com", "evan\neveanking.com", "Alfred\nalfrednewman.com"]
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        Contacted(iscontacted: prospect.isContacted
                        )
                        VStack(alignment:.leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                    
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                            
                        } else {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark contacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.green)
                            
                            Button{
                                adNotification(for: prospect)
                            } label: {
                                Label("Remind Me", systemImage: "bell")
                            }
                            .tint(.orange)
                        }
                }
                }
               
            }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                           isShowingScanner = true
                        } label: {
                            Label("Scan", systemImage: "qrcode.viewfinder")
                        }
                    }
                    
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showsort = true
                        } label: {
                           Label("Sort", systemImage: "arrow.up.arrow.down.square.fill")
                        }
                        
                    }
                    
//                    PaulHudson\npaul@hackingwithswift.com
                    
                }
                .sheet(isPresented: $isShowingScanner) {
                    CodeScannerView(codeTypes: [.qr], simulatedData: self.random.randomElement()!, completion: handlerScan)
                }
                
                .confirmationDialog("Sort Users", isPresented: $showsort) {
//                    Button {
//                        self.sortType = .recent
//                    } label: {
//                        Text("Most Recent\(checkBox(fortype: .recent))")
//
//                    }
                    Button {
                        self.sortType = .recent
                     
                    } label: {
                        Text((self.sortType == .recent ? "✅" : "") + "Most Recent")
                    }

                    Button {
                        self.sortType = .name
                  
                    } label: {
                        Text((self.sortType == .name ?  "✅" : "") + "Name")
                       
                    }


                } message: {
                    Text("Sort Users")
                        .font(.headline)
                }

            
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted People"
        case .uncontacted:
            return "Uncontacted People"
        }
    }
    
    var sortsProspect: [Prospect] {
        switch sortType {
        case .name:
            return filteredProspects.sorted {$0.name < $1.name}
            
        case .recent:
            return filteredProspects.sorted{$0.recent > $1.recent}
            
        }
        
        
       
        
    }
    
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted}
        case .uncontacted:
            return prospects.people.filter {!$0.isContacted}
        }
    }
    
    func handlerScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {return}
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            person.recent = Date()
            prospects.add(person)
            
            
        case .failure(let error):
            print("Scanning failed \(error.localizedDescription)")
        
        }
    }
    
    func adNotification (for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            ///MAIN CODE FOR SHIPPING APP
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            
            //// USE THIS CODE FOR TESTING
            let trigger = UNTimeIntervalNotificationTrigger( timeInterval: 5, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()

            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("Failed ")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
