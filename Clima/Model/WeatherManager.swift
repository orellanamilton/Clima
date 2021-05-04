//
//  WeatherManager.swift
//  Clima
//
//  Created by Milton Orellana on 02/05/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let URLWeather = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=b57debb3568e90a633e8c1072d82a9da"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let URLString = "\(URLWeather)&q=\(cityName)"
        performRequest(with: URLString)
    }
    
    func fetchWeather(latitude: Double , longitude: Double) {
        let URLString = "\(URLWeather)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: URLString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, respose, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let cityName = decodeData.name
            
            let weather = WeatherModel(conditionID: id, cityName: cityName, temparature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
