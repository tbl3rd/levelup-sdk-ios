#import "LUCoreDataStack.h"
#import "LUCoreDataStore.h"
#import "NSArray+LUAdditions.h"

@implementation LUCoreDataStack

#pragma mark - Public Methods (Managed Object Context)

+ (NSManagedObjectContext *)managedObjectContext {
  NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
  managedObjectContext.persistentStoreCoordinator = [self persistentStoreCoordinator];

  return managedObjectContext;
}

#pragma mark - Public Methods (Metadata Access)

+ (NSString *)metadataStringForKey:(NSString *)key {
  NSManagedObjectContext *moc = [self managedObjectContext];
  return [self metadataForObjectContext:moc][key];
}

+ (void)setMetadataString:(NSString *)string forKey:(NSString *)key {
  NSManagedObjectContext *moc = [self managedObjectContext];
  NSMutableDictionary *metadata = [[self metadataForObjectContext:moc] mutableCopy];
  metadata[key] = string;
  [self setMetadata:metadata forObjectContext:moc];
}

#pragma mark - Private Methods (Store Access)

+ (NSDictionary *)metadataForObjectContext:(NSManagedObjectContext *)moc {
  return [[moc.persistentStoreCoordinator.persistentStores firstObject] metadata];
}

+ (void)setMetadata:(NSDictionary *)metadata forObjectContext:(NSManagedObjectContext *)moc {
  [[moc.persistentStoreCoordinator.persistentStores firstObject] setMetadata:metadata];
  [moc save:nil];
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  NSManagedObjectModel *mom = [NSManagedObjectModel mergedModelFromBundles:nil];
  NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];

  NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES};
  NSError *error;
  if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                configuration:nil
                                                          URL:[LUCoreDataStore storeURL]
                                                      options:options
                                                        error:&error]) {
    NSLog(@"Error while creating persistent store coordinator: %@, %@", error, [error userInfo]);
    abort();
  }

  return persistentStoreCoordinator;
}

@end
