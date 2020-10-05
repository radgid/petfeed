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
protocol LocalPetRepository {
    func fetchFavourites(page: Int) -> AnyPublisher<[DisplayablePet], PetFailure>
    func setPet(_ pet: Pet, image: Data?, favourite: Bool) -> AnyPublisher<Pet, PetFailure>
    func selectPet(_ pet: Pet) -> AnyPublisher<Pet, PetFailure>
    func fetchFavouritesIds() -> [String]
}

/// Pet API
struct LocalPetApi: LocalPetRepository {
    
    private let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
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
