import Foundation

public protocol AWAirportsRepository {
    // Countries
    func getAllCountries() throws -> [AWCountry]
    func getCountry(by code: String) throws -> AWCountry?
    func getCountries(by continent: String) throws -> [AWCountry]

    // Regions
    func getAllRegions() throws -> [AWRegion]
    func getRegions(by countryCode: String) throws -> [AWRegion]
    func getRegion(by code: String) throws -> AWRegion?

    // Airports
    func getAllAirports() throws -> [AWAirport]
    func getAirport(id: Int64) throws -> AWAirport?
    func getAirport(ident: String) throws -> AWAirport?
    func getAirport(iataCode: String) throws -> AWAirport?
    func getAirport(icaoCode: String) throws -> AWAirport?
    func getAirports(countryCode: String) throws -> [AWAirport]
    func getAirports(regionCode: String) throws -> [AWAirport]
    func getAirports(type: AWAirportType) throws -> [AWAirport]
    func searchAirports(name: String) throws -> [AWAirport]
    
    func getAirportsNear(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        types: [String]
    ) throws -> [AWAirport]
    
    func getNearestAirport(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        types: [String]
    ) throws -> AWAirport?
    
    func getAirportsForLocation(
        latitude: Double,
        longitude: Double,
        rangeLatitude: Double,
        rangeLongitude: Double,
        types: [String]
    ) throws -> [AWAirport]
    
    func getAirportsForLocation(
        latitude: Double,
        longitude: Double,
        rangeInDegrees: Double,
        types: [String]
    ) throws -> [AWAirport]
    
    func getAirportsWithRunwaysNear(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        types: [String]
    ) throws -> [(airport: AWAirport, runways: [AWRunway])]
    
    func getNearestAirportWithRunways(
        latitude: Double,
        longitude: Double,
        types: [String]
    ) throws -> (airport: AWAirport, runways: [AWRunway])?
    
    func getNearestAirportWithRunways(
        latitude: Double,
        longitude: Double,
        radiusKm: Double,
        types: [String]
    ) throws -> (airport: AWAirport, runways: [AWRunway])?
    
    func getNearestAirportWithRunways(
        latitude: Double,
        longitude: Double,
        rangeLatitude: Double,
        rangeLongitude: Double,
        types: [String]
    ) throws -> (airport: AWAirport, runways: [AWRunway])?
    
    func getAirportsWithRunwaysForLocation(
        latitude: Double,
        longitude: Double,
        rangeLatitude: Double,
        rangeLongitude: Double,
        types: [String]
    ) throws -> [(airport: AWAirport, runways: [AWRunway])]
    
    func getAirportsWithRunwaysForLocation(
        latitude: Double,
        longitude: Double,
        rangeInDegrees: Double,
        types: [String]
    ) throws -> [(airport: AWAirport, runways: [AWRunway])]

    // Frequencies
    func getFrequencies(for airportId: Int64) throws -> [AWAirportFrequency]
    func getFrequencies(for airportIdent: String) throws -> [AWAirportFrequency]
    func getFrequencies(by type: String) throws -> [AWAirportFrequency]

    // Runways
    func getRunways(for airportId: Int64) throws -> [AWRunway]
    func getRunways(for airportIdent: String) throws -> [AWRunway]
    func getRunways(longerThan lengthFt: Int) throws -> [AWRunway]
    func getRunways(with surface: String) throws -> [AWRunway]

    // Navaids
    func getAllNavaids() throws -> [AWNavaid]
    func getNavaids(by countryCode: String) throws -> [AWNavaid]
    func getNavaids(by type: AWNavaidType) throws -> [AWNavaid]
    func getNavaids(for airportIdent: String) throws -> [AWNavaid]
    func searchNavaids(by name: String) throws -> [AWNavaid]

    // Complex / aggregates
    func getAirportWithDetails(by ident: String) throws -> (airport: AWAirport, country: AWCountry?, region: AWRegion?, frequencies: [AWAirportFrequency], runways: [AWRunway], navaids: [AWNavaid])?
    
    func getStatistics() throws -> (countries: Int, regions: Int, airports: Int, frequencies: Int, runways: Int, navaids: Int)
    
    func getTopCountriesByAirportCount(limit: Int) throws -> [(country: AWCountry, count: Int)]
    func getAirportTypesDistribution() throws -> [(type: AWAirportType?, count: Int)]

    // Airports with related data
    func getAirportWithRunways(id: Int64) throws -> (airport: AWAirport, runways: [AWRunway])?
    
    func getAirportsWithRunways(countryCode: String) throws -> [(airport: AWAirport, runways: [AWRunway])]
}
   
