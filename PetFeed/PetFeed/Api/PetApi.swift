//
//  PetApiProtocol.swift
//  PetFeed
//
//  Created by Danko, Radoslav on 03/09/2020.
//  Copyright © 2020 Danko, Radoslav. All rights reserved.
//

import Foundation
import Combine
import CoreData

/// Data Repository interfaces
protocol PetRepository {
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure>
    func download(_ imageUrl: URL) -> AnyPublisher<Data, PetFailure>
    func fetchFavourites(page: Int) -> AnyPublisher<[DisplayablePet], PetFailure>
    func setPet(_ pet: Pet, image: Data?, favourite: Bool) -> AnyPublisher<Pet, PetFailure>
    func selectPet(_ pet: Pet) -> AnyPublisher<Pet, PetFailure>
}

/// Pet API
struct PetApi: PetRepository {
    private let sessionConfiguration: URLSessionConfiguration
    private let managedObjectContext: NSManagedObjectContext
    private let host: String = "https://shibe.online/api/"
    init(sessionConfiguration: URLSessionConfiguration = .default,
         managedObjectContext: NSManagedObjectContext) {
        self.sessionConfiguration = sessionConfiguration
        self.managedObjectContext = managedObjectContext
    }
    
    /// Helper function to fetch Favourite Pet ids
    /// - Returns: Favorite Pet Ids
    func fetchFavouritesIds() -> [String] {
        let fetchRequest =
            NSFetchRequest<NSDictionary>(entityName: "FavouritePet")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.propertiesToFetch = ["url"]
        
        do {
            let petsNSDict = try managedObjectContext.fetch(fetchRequest)
            return petsNSDict
                .map { $0.allValues}
                .flatMap{$0}
                .compactMap{ String(describing: $0)}            
        } catch let error as NSError {
            Log.data().error(message: "Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
    
    /// Select Pet - if it is stored in Faviourites Pets then change its flag accordingly
    /// - Parameter pet: Pet to select
    /// - Returns: Selected Pet
    func selectPet(_ pet: Pet) -> AnyPublisher<Pet, PetFailure> {
        
        let fetchRequest =
            NSFetchRequest<NSFetchRequestResult>(entityName: "FavouritePet")
        fetchRequest.predicate = NSPredicate(format: "url = %@", pet.url)
        
        do {
            if let petsMO = try managedObjectContext.fetch(fetchRequest) as? [FavouritePet] {
                if let favPet = petsMO.first {
                    return .future(Pet(favPet.url ?? "", isFavourite: true))
                }
            }
            return .future(Pet(pet.url, isFavourite: false))
        } catch let error as NSError {
            Log.data().error(message: "Could not fetch. \(error), \(error.userInfo)")
            return .fail(.databaseError(error: error))
            }
        
    }
    
    /// Fetch stored - favourite - Pet Images
    /// - Parameter page: Paging
    /// - Returns: Favourite Publisher
    func fetchFavourites(page: Int = -1) -> AnyPublisher<[DisplayablePet], PetFailure> {
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "FavouritePet")
        do {
            if let petsMO = try managedObjectContext.fetch(fetchRequest) as? [FavouritePet] {
                let pets = petsMO.compactMap { (pet) -> DisplayablePet? in
                    let id = pet.url ?? ""
                    if let imageData = pet.value(forKeyPath: "image") as? Data {
                        if let image = imageData.asImage() {
                            return DisplayablePet(id: id, image: image)
                        }
                    }
                    return nil
                }
                return .future(pets)
            }
            return .future([])
        } catch let error as NSError {
            Log.data().error(message: "Could not fetch. \(error), \(error.userInfo)")
            return .fail(.databaseError(error: error))
        }
    }

    /// Fetches Pets information
    /// - Parameter request: Request details for fetching pets
    /// - Returns: Pets details publisher
    func fetch(_ request: PetRequest) -> AnyPublisher<[Pet], PetFailure> {
        guard let url = URL(string: host + request.api() + "?" + "count=\(request.count)") else {
                return .fail(.invalidRequest)
        }

        let session = URLSession(configuration: sessionConfiguration)
        let urlRequest = URLRequest(url: url)
        let publisher = session.petPublisher(for: urlRequest)
        let favouriteIds = fetchFavouritesIds()
        //Unwrap Array of Strings from the Json
        let result: AnyPublisher<[String], PetFailure> = publisher.unwrap(with: JsonWrapper())
            .eraseToAnyPublisher()

        //Transform Array of string into Pet structures
        let transformed: AnyPublisher<[Pet], PetFailure> =
            result.flatMap { (urls) ->  AnyPublisher<[Pet], PetFailure> in
                let pets = urls.map {Pet.init($0, isFavourite: favouriteIds.contains($0))}
            return .future(pets)
        }.eraseToAnyPublisher()

        return transformed
    }

    /// Download image from URL
    /// - Parameter imageUrl: URL of the Image
    /// - Returns: Image Data Publisher
    public func download(_ imageUrl: URL) -> AnyPublisher<Data, PetFailure> {
        let session = URLSession(configuration: sessionConfiguration)
        let urlRequest = URLRequest(url: imageUrl)
        let publisher = session.petPublisher(for: urlRequest)

        return publisher
    }

    /// Update the Pet
    /// - Parameters:
    ///   - pet: Pet to update
    ///   - image: Optional Image to save
    ///   - favourite: Is Favourite
    /// - Returns: Updated Pet
    func setPet(_ pet: Pet,
                image: Data? = nil,
                favourite: Bool) -> AnyPublisher<Pet, PetFailure> {

        let modifiedPet = Pet(pet.url, isFavourite: favourite)
        if favourite {
            if let entity = NSEntityDescription.entity(forEntityName: "FavouritePet",
                                                       in: managedObjectContext) {

                if let favPet = NSManagedObject(entity: entity,
                                                insertInto: managedObjectContext) as? FavouritePet {
                    favPet.url = pet.url
                    favPet.image = image
                }
            }
        } else {
            let fetchRequest =
                NSFetchRequest<NSFetchRequestResult>(entityName: "FavouritePet")
            fetchRequest.predicate = NSPredicate(format: "url = %@", pet.url)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try managedObjectContext.execute(deleteRequest)
            } catch let error as NSError {
                Log.data().error(message: "Could not fetch. \(error), \(error.userInfo)")
                return .fail(.databaseError(error: error))
            }
        }

        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            Log.data().error(message: "Could not save. \(error), \(error.userInfo)")
            return .fail(.databaseError(error: error))
        }
        return .future(modifiedPet)
    }
}
