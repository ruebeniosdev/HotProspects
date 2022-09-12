//
//  Prospect.swift
//  HotProspects
//
//  Created by RUEBEN on 09/09/2022.
//

import SwiftUI


class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false
    var recent = Date()
}

@MainActor class Prospects: ObservableObject {
    
    @Published private(set) var people: [Prospect]

    let saveKey = "SavedData"
    
    
    
    init() {
        //
        //        if let data = UserDefaults.standard.data(forKey: saveKey) {
        //            if let decoded = try? JSONDecoder().decode([Prospect].self,from: data) {
        //
        //                people = decoded
        //                return
        //            }
        //        }
        self.people = []
        
        
        
        ///challenge 2 decoding data
        if let data = loadFile() {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return
            }
        }
        
        
        //        let url = getDocumentsDirectory().appendingPathComponent(saveKey)
        //        do {
        //            let data = try Data(contentsOf: url)
        //            let people = try JSONDecoder().decode([Prospect].self, from: data)
        //            self.people = people
        //
        //        } catch {
        //            print("Unable to save data")
        //            self.people = []
        //        }
        
        ////////else empty array
        //        people = []
    }
    
    func add(_ prospect: Prospect) {
        people.append(prospect)
        Save()
       
    }
    
    private func Save() {
        if let encoded = try? JSONEncoder().encode(people) {
//            UserDefaults.standard.set(encoded, forKey: saveKey)
            save2(data: encoded)
        }
    }
    
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        Save()
      
    }
    
    
    ///challenge 2 saving
    private func save2(data: Data) {
        let filename = getDocumentsDirectory().appendingPathComponent(saveKey)
        do {
            let data = try JSONEncoder().encode(people)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save")
        }
    }
    
    private func loadFile() -> Data? {
        let filename = getDocumentsDirectory().appendingPathComponent(self.saveKey)
        if let data = try? Data(contentsOf: filename) {
            return data
        }
        return nil
    }
    
    ///challenge 2 Documents directory
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
}


