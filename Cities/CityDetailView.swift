//
//  CityDetailView.swift
//  Cities
//
//  Created by Vishnu Tejaa on 3/19/24.
//

class IdentifiablePointAnnotation: MKPointAnnotation, Identifiable {
    var id = UUID()
}

import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct CityDetailView: View {
    var city: City
    @State private var region: MKCoordinateRegion
    @State private var annotations: [IdentifiablePointAnnotation] = []
    @State private var searchResults: [IdentifiablePointAnnotation] = []
    @State private var searchQuery: String = ""

    init(city: City) {
        self.city = city
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
        
        let cityAnnotation = IdentifiablePointAnnotation()
        cityAnnotation.title = city.name
        cityAnnotation.coordinate = CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude)
        _annotations = State(initialValue: [cityAnnotation])
    }

    var body: some View {
        VStack {
            TextField("Search...", text: $searchQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .foregroundColor(.black) // Changes the text color
                .font(.system(size: 16, weight: .medium, design: .rounded)) // Customizes the font
                .background(Color(.systemGray6)) // Sets the background color
                .cornerRadius(15) // Rounds the corners of the background
                .onChange(of: searchQuery) { newValue in
                    performSearch(query: newValue)
                }
            Spacer().frame(height: 20)
            
            Map(coordinateRegion: $region, annotationItems: annotations + searchResults) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    CustomAnnotationView(name: annotation.title ?? "Unknown")
                }
            }
            .edgesIgnoringSafeArea(.top)
            .frame(height: 500)

            HStack {
                Text("Latitude: \(city.latitude)").bold().fontDesign(.serif)
                Text("|Longitude: \(city.longitude)").bold().fontDesign(.serif)
            }.padding()

            Spacer()
        }
        .navigationTitle(city.name)
    }
    
    func performSearch(query: String) {
        searchPlaces(in: city, query: query) { results in
            searchResults = results
        }
    }
}

struct CustomAnnotationView: View {
    var name: String

    var body: some View {
        VStack(spacing: 0) {
            Text(name)
                .font(.caption)
                .padding(5)
                .background(Color.black.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(5)
                .fixedSize()

            Image(systemName: "mappin.circle.fill")
                .font(.title2)
                .foregroundColor(.red)
                .offset(y: -10) // Adjust so the pin appears to connect to the text bubble
        }
    }
}

func searchPlaces(in city: City, query: String, completion: @escaping ([IdentifiablePointAnnotation]) -> Void) {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = query
    request.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    let search = MKLocalSearch(request: request)
    search.start { response, _ in
        guard let response = response else {
            completion([])
            return
        }
        
        let annotations = response.mapItems.compactMap { item -> IdentifiablePointAnnotation? in
            let annotation = IdentifiablePointAnnotation()
            annotation.title = item.name
            annotation.coordinate = item.placemark.coordinate
            return annotation
        }
        completion(annotations)
    }
}




#Preview {
    CityDetailView(city: City(name: "New York", description: "Description of New York", imageName: "newYorkImage", latitude: 40.7128, longitude: -74.0060))
}
