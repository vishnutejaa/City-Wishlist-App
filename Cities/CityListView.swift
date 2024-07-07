//
//  CityListView.swift
//  Cities
//
//  Created by Vishnu Tejaa on 3/19/24.
//

import SwiftUI
import CoreLocation


struct CityListView: View {
    @State private var cities: [City] = [
        City(name: "New York", description: "The city that never sleeps.", imageName: "newYork", latitude: 40.7128, longitude: -74.0060),
        City(name: "Tokyo", description: "The heart of Japan.", imageName: "tokyo", latitude: 35.6895, longitude: 139.6917)
    ]
    @State private var showingAddCityView = false

    
    var body: some View {
        NavigationView {
            List {
                ForEach(cities) { city in
                    NavigationLink(destination: CityDetailView(city: city)) {
                        HStack {
                            Image(city.imageName)
                                .resizable()
                                .frame(width: 50, height: 50).edgesIgnoringSafeArea(.all)
                            VStack(alignment: .leading) {
                                Text(city.name).font(.headline)
                                Text(city.description).font(.subheadline)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteCity)
            }
            .navigationTitle("Favorite Cities")
            .toolbar {
                Button(action: {
                    // Present an interface to add a new city
                    showingAddCityView = true
                }) {
                    Image(systemName: "plus")
                }
                .sheet(isPresented: $showingAddCityView) {
                    AddCityView(cities: $cities)
                }
            }
        }
    }
    
    func deleteCity(at offsets: IndexSet) {
        cities.remove(atOffsets: offsets)
    }
}

struct AddCityView: View {
    @Binding var cities: [City]
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var imageName: String = "default"
    @State private var latitude: String = ""
    @State private var longitude: String = ""


    var body: some View {
        NavigationView {
            Form {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
//                    TextField("Image Name", text: $imageName)
//                    TextField("Latitude", text: $latitude)
//                    TextField("Longitude", text: $longitude)
            }
            .navigationTitle("Add New City")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        geocodeCityName(name) { latitude, longitude in
                            let newCity = City(name: name, description: description, imageName: "default", latitude: latitude, longitude: longitude)
                            cities.append(newCity)
                            dismiss()
                        }
                    }

                }
            }
        }
    }
    
    func geocodeCityName(_ cityName: String, completion: @escaping (Double, Double) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                print("No location found for \(cityName)")
                return
            }
            completion(location.coordinate.latitude, location.coordinate.longitude)
        }
    }

}



#Preview {
    CityListView()
}
