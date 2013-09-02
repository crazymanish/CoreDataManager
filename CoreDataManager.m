//
//  CoreDataConstants.h
//  CoreDataR&D
//
//  Created by Manish Rathi on 02/09/13.

#import "CoreDataManager.h"
#include <sys/xattr.h>

#define kObjectID @"objectID"
#define kDBName @"ProejctName.sqlite"

static CoreDataManager *instance = nil;
@interface CoreDataManager ()

@end

@implementation CoreDataManager
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectContext_background = __managedObjectContext_background;
#pragma mark- Singleton Class
+(CoreDataManager *) instance{
    @synchronized(self)
	{
		if(!instance)
		{
			instance = [[super alloc] init];
		}
	}
	return instance;
}

-(id)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextChanged:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

#pragma mark - managedObjectContext Changed-Handler
- (void) contextChanged:(NSNotification *)notification {
    NSManagedObjectContext *savedContext =[notification object];

    if (savedContext.persistentStoreCoordinator != __managedObjectContext.persistentStoreCoordinator){
        return;  // that's another database   
    }
        
    if( ! [NSThread isMainThread] ){
        [self performSelectorOnMainThread:@selector(contextChanged:) withObject:notification waitUntilDone:YES];
        return;
    }
    
    if(savedContext==__managedObjectContext){
        [self merge_managedObjContext:__managedObjectContext_background WithNotification:notification];
    }else if(savedContext==__managedObjectContext_background){
        [self merge_managedObjContext:__managedObjectContext WithNotification:notification];
    }
}

-(void)merge_managedObjContext:(NSManagedObjectContext *) managedObjContext WithNotification:(NSNotification *)notification{
    //Merge the Data Here
    [managedObjContext mergeChangesFromContextDidSaveNotification:notification];
    
//    if(managedObjContext==__managedObjectContext){
//    }    
}

#pragma mark - managedObjectContext
//#pragma mark - managedObjectContext for Server-to-iPAD SYNC
-(NSManagedObjectContext *) managedObjectContext_background{
    if (__managedObjectContext_background != nil) {
        return __managedObjectContext_background;
    }
    __managedObjectContext_background = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext_background setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return __managedObjectContext_background;
}

//#pragma mark - managedObjectContext for User-Operations
-(NSManagedObjectContext *) managedObjectContext{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    return __managedObjectContext;
}

#pragma mark - CoreData Model
-(NSManagedObjectModel *) managedObjectModel{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    NSURL *momdUrl = [[NSBundle mainBundle] URLForResource:@"ProejctName" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momdUrl];
    return __managedObjectModel;
}


-(NSPersistentStoreCoordinator *) persistentStoreCoordinator{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeUrl = [ self getTheUrlForSqllite ];
    NSLog(@"\n\ncoreData UrlForSqllite : %@\n\n",[storeUrl absoluteString]);
    
    NSDictionary *options =
    [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption,
     [NSNumber numberWithBool:YES],NSInferMappingModelAutomaticallyOption, nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:nil]) {
        NSLog(@"\n\n Core-Data Error!! delete app start once again.\n\n");
        [self clearCoreData];
        [self managedObjectContext];
        abort();
        //return nil;
    }
    [self addSkipBackupAttributeToItemAtURL:storeUrl];
    return __persistentStoreCoordinator;
}
#pragma mark - SQLLite directory
- (NSURL *)getTheUrlForSqllite
{
    return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:[NSString stringWithFormat:kDBName]];
}

#pragma mark - Reset-All ManagedObjectContext
-(BOOL)resetCoreDataManager{
    __persistentStoreCoordinator=nil;
    __managedObjectContext=nil;
    __managedObjectContext_background=nil;
    __managedObjectModel=nil;
    return YES;
}

#pragma mark - Rollback ManagedObjectContext-operations
-(BOOL)rollback_withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    if ([managedObjContext hasChanges]) {
        [managedObjContext rollback];
    }
    return [self saveConext_withManageObjectContext:managedObjContext];
}

#pragma mark- Save operation
-(BOOL)saveConext_withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    if ([managedObjContext hasChanges]) {
        NSError *error = [[NSError alloc] init];
        if (![managedObjContext save:&error]) {
            NSLog(@"Unresolved error while saving, %@",[error userInfo]);
            return NO;
        }
    }
    return YES;
}

#pragma mark - Delete Operations
//#pragma mark- Delete object operation
-(BOOL)deleteObject :(NSManagedObject *) mangedObject WithInstantUpdate :(BOOL) needToSaveNow withManageObjectContext:(NSManagedObjectContext *) managedObjContext {
    if (mangedObject==nil) {
        return NO;
    }
    [managedObjContext deleteObject:mangedObject];
    if (needToSaveNow) {
        return [self saveConext_withManageObjectContext:managedObjContext];
    }
    return YES;
}

-(BOOL)deleteObject_basedOn_ObjectID:(NSString *)ObjectId WithInstantUpdate:(BOOL)needToSaveNow withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    NSManagedObject *obj=[self getManagedobjectWithURI:[NSURL URLWithString:ObjectId] withManageObjectContext:managedObjContext];
    if (obj!=nil) {
        return [self deleteObject:obj WithInstantUpdate:needToSaveNow withManageObjectContext:managedObjContext];
    }
    return YES;
}

//#pragma mark- Delete object for entity operation
-(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow
{
    // Create fetch request
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjContext];
    [request setEntity:entity];
    
    // Ignore property values for maximum performance
    [request setIncludesPropertyValues:NO];
    
    // If a predicate was specified then use it in the request
    if (predicate != nil)
        [request setPredicate:predicate];
    
    // Execute the count request
    NSError *error = nil;
    NSArray *fetchResults = [managedObjContext executeFetchRequest:request error:&error];
    // Delete the objects returned if the results weren't nil
    if (fetchResults != nil) {
        for (NSManagedObject *manObj in fetchResults) {
            [managedObjContext deleteObject:manObj];
        }
    } else {
        NSLog(@"Couldn't delete objects for entity %@", entityName);
        return NO;
    }
    
    if (needToSaveNow) {
        return [self saveConext_withManageObjectContext:managedObjContext];
    }
    
    return YES;
}


#pragma mark - FLUSH Core data
-(void) clearCoreData{
    [[NSFileManager defaultManager] removeItemAtURL:[self getTheUrlForSqllite] error:nil];
}

//#pragma mark - FLUSH Core data Table (single Table)
-(void)clearTableDataInfoForEntity:(NSString *)entityName withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    NSArray *clearTableData = [self fetchDataForEntity:entityName Predicate:nil AndArrayOfSortDescription:nil withManageObject:managedObjContext];
    NSLog(@"%@",clearTableData);
    
    for(NSManagedObject *mangedObject in clearTableData){
        [managedObjContext deleteObject:mangedObject];
    }
    
    [self saveConext_withManageObjectContext:managedObjContext];
}

//#pragma mark - FLUSH Core data Table (multiple tables)
-(void)clearTableDataInfoForEntities:(NSArray *)entityNames withManageObjectContext:(NSManagedObjectContext *) managedObjContext
{
	for (int i = 0; i < [entityNames count]; i++)
	{
		NSEntityDescription *entity = [NSEntityDescription entityForName:[entityNames objectAtIndex:i] inManagedObjectContext:managedObjContext];
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:entity];
		NSError *error;
		NSArray *result = nil;
 		result = [managedObjContext executeFetchRequest:request error:&error];
		if(result != nil)
		{
			for (int j = 0; j < [result count]; j++)
				[managedObjContext deleteObject:[result objectAtIndex:j]];
		}
	}
	if (![self saveConext_withManageObjectContext:managedObjContext])
	{
        // Handle the error.
		NSLog(@"Failed to save to data store");
	}
	
}

#pragma mark - SET Data into Core data Table
-(NSManagedObject *)setDataForEntity:(NSString*)entityName entityData:(NSDictionary *)data withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow
{
	NSManagedObject *objectDetails = (NSManagedObject *)[NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:managedObjContext];
   
    if ([self updateManagedObject:objectDetails entityData:data withManageObjectContext:managedObjContext WithInstantUpdate:needToSaveNow]) {
        return objectDetails;
    }
    
    return nil;
}

#pragma mark - Update Data into Core data Table
-(BOOL)updateManagedObject:(NSManagedObject *)objectDetails entityData:(NSDictionary *)data withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow{

    if (objectDetails==nil) {
        NSLog(@"Data not saved");
        return NO;
    }
    
    NSArray* keys = nil;
    NSDictionary *attributes = [[objectDetails entity] attributesByName];
    keys=[[[objectDetails entity] attributesByName] allKeys];
    
	for (int i = 0; i < [keys count]; i++) {
		NSString* key = [keys objectAtIndex:i];
        //NSLog(@"Key: %@ ", key);
		if ([self isEmptyObject:[data valueForKey:key]]==NO) {
            if (((NSAttributeDescription *)[attributes valueForKey:key]).attributeType == NSInteger16AttributeType
                && ([[data valueForKey:key] isKindOfClass:[NSString class]])) {
                [objectDetails setValue:[[data valueForKey:key] toNumber] forKey:key];
            }else if (((NSAttributeDescription *)[attributes valueForKey:key]).attributeType == NSFloatAttributeType
                      && ([[data valueForKey:key] isKindOfClass:[NSString class]])) {
                [objectDetails setValue:[[data valueForKey:key] toFloat] forKey:key];
            }else if (((NSAttributeDescription *)[attributes valueForKey:key]).attributeType == NSDateAttributeType
                      && ([[data valueForKey:key] isKindOfClass:[NSString class]])) {
                [objectDetails setValue:[[data valueForKey:key] toDate] forKey:key];
            }else if (((NSAttributeDescription *)[attributes valueForKey:key]).attributeType == NSDecimalAttributeType
                      && ([[data valueForKey:key] isKindOfClass:[NSString class]])){
                [objectDetails setValue:[[data valueForKey:key] toFloat] forKey:key];
            }else if (((NSAttributeDescription *)[attributes valueForKey:key]).attributeType == NSInteger32AttributeType
                 && ([[data valueForKey:key] isKindOfClass:[NSString class]])) {
                [objectDetails setValue:[[data valueForKey:key] toNumber] forKey:key];
            }else{
                [objectDetails setValue:[data valueForKey:key] forKey:key];
            }
		}
	}
    
   // NSLog(@"Managed-objectDetails: %@ ", objectDetails);
    
    if (needToSaveNow) {
        if (![self saveConext_withManageObjectContext:managedObjContext]){
            NSLog(@"Failed to save to data store: ");
            return NO;
        }else{
             NSLog(@"saveConext Called & Data saved For Table == %@",[[objectDetails entity] name]);
        }
    }
    return YES;
}

-(BOOL)updateManagedObject_withObjectID:(NSString *)objectID entityData:(NSDictionary *)data withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow{
    NSManagedObject *objectDetails =[self getManagedobjectWithURI:[objectID toURL] withManageObjectContext:managedObjContext];
    
    return [self updateManagedObject:objectDetails entityData:data withManageObjectContext:managedObjContext WithInstantUpdate:needToSaveNow];
}

#pragma mark- GET Core-data Operations
//#pragma mark- GET Data(Return array of NSManagedObject)
-(NSArray *) fetchDataForEntity :(NSString *)entityName Predicate :(NSPredicate *) predicate AndArrayOfSortDescription :(NSArray *) sortDescriptions withManageObject:(NSManagedObjectContext *) managedObjContext{
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptions];
    [fetchRequest setFetchBatchSize:20];
    
    
    return  [managedObjContext executeFetchRequest:fetchRequest error:nil];
}

//#pragma mark - GET Data(Return array of NSManageObject)
-(NSArray *)getDataForEntity:(NSString*)entityName Predicate :(NSPredicate *) predicate AndArrayOfSortDescription :(NSArray *) sortDescriptions withManageObjectContext:(NSManagedObjectContext *) managedObjContext
{
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:managedObjContext];
	NSFetchRequest *request = [[NSFetchRequest alloc] init] ;
	[request setEntity:entityDescription];
	[request setPredicate:predicate];
    [request setSortDescriptors:sortDescriptions];
    [request setFetchBatchSize:20];
    
	NSError *error = nil;
	NSArray *data = nil;
	data = [managedObjContext executeFetchRequest:request error:&error];
	if (error)
	{
        // Handle the error.
		NSLog(@"Failed to get data from store");
		return nil;
	}
	return data;
}

//#pragma mark - GET Data(Return array of NSMutableDictionary)
-(NSMutableArray *)getData_In_Dictionary_Format_ForEntity:(NSString*)entityName Predicate :(NSPredicate *) predicate AndArrayOfSortDescription :(NSArray *) sortDescriptions withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    NSArray *data=[self getDataForEntity:entityName Predicate:predicate AndArrayOfSortDescription:sortDescriptions withManageObjectContext:managedObjContext];
    
    NSMutableArray *dicArray=[[NSMutableArray alloc] init];
    
    for (NSManagedObject *manageObj in data) {
        NSMutableDictionary *dic=[self convertNSManageObject_To_Dictionary:manageObj];
        if (dic!=nil) {
            [dicArray addObject:dic];
        }
    }
    
    return dicArray;
}

//#pragma mark - GET Managedobject using Object-ID(URI)
-(NSManagedObject *)getManagedobjectWithURI:(NSURL *)uri withManageObjectContext:(NSManagedObjectContext *) managedObjContext
{
    NSURL *objectIDURI=nil;
    
    //@Manish (Just chk URI is String or NSURL), because i do lots of mistakes. :)
    if ([uri isKindOfClass:[NSString class]]) {
        objectIDURI=[(NSString *)uri toURL];
    }else if([uri isKindOfClass:[NSURL class]]){
        objectIDURI=uri;
    }
    
   // NSLog(@"\n getting Managedobject WithURI  %@\n",objectIDURI);
    
    NSManagedObjectID *objectID =
    [[self persistentStoreCoordinator]
     managedObjectIDForURIRepresentation:objectIDURI];
    
    if (!objectID){
        return nil;
    }
    
    NSManagedObject *objectForID = [managedObjContext objectWithID:objectID];
    if (![objectForID isFault]){
        return objectForID;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[objectID entity]];
    
    // Equivalent to
    // predicate = [NSPredicate predicateWithFormat:@"SELF = %@", objectForID];
    NSPredicate *predicate =
    [NSComparisonPredicate
     predicateWithLeftExpression:
     [NSExpression expressionForEvaluatedObject]
     rightExpression:
     [NSExpression expressionForConstantValue:objectForID]
     modifier:NSDirectPredicateModifier
     type:NSEqualToPredicateOperatorType
     options:0];
    [request setPredicate:predicate];
    
    NSArray *results = [managedObjContext executeFetchRequest:request error:nil];
    if ([results count] > 0 ){
        return [results objectAtIndex:0];
    }
    
    return nil;
}

//#pragma mark - GET NSMutableDictionary using Object-ID(NSString)
-(NSMutableDictionary *)getData_of_ObjectID:(NSString *)ObjectId withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    NSManagedObject *Obj=[self getManagedobjectWithURI:[ObjectId toURL] withManageObjectContext:managedObjContext];
    if (Obj==nil) {
        return nil;
    }
     return [self convertNSManageObject_To_Dictionary:Obj];
}

-(NSMutableArray *)getObjectIDData_ofNSSet:(NSSet *)set withManageObjectContext:(NSManagedObjectContext *) managedObjContext{
    NSArray *setDataArray = [set allObjects];
    NSMutableArray *returnData=[[NSMutableArray alloc] init];
    for (NSManagedObject* info in setDataArray) {
       NSMutableDictionary *data=[self getData_of_ObjectID:[[[info objectID] URIRepresentation] absoluteString]withManageObjectContext:managedObjContext];
        if (data!=nil) {
            [returnData addObject:data];
        }
    }
    return returnData;
}

#pragma mark - Convert Managedobject To NSDictionary
-(NSMutableDictionary*)convertNSManageObject_To_Dictionary:(NSManagedObject *)managedobject
{
    if (managedobject==nil) {
        return nil;
    }
    
    NSArray* attributes = [[[managedobject entity] attributesByName] allKeys];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue:[[[managedobject objectID] URIRepresentation] absoluteString] forKey:kObjectID];
    
    for (NSString* attr in attributes) {
        id value = [managedobject valueForKey:attr];
        
      //  NSLog(@"Key= %@  Value= %@",attr,value);
        
        if ([self isEmptyObject:value]==NO) {
            [dict setValue:value forKey:attr];
        }
    }
    
    return dict;
}

#pragma mark - Helpers
- (BOOL)addSkipBackupAttributeToItemAtURL :(NSURL *)url
{
    // First ensure the file actually exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        NSLog(@"File %@ doesn't exist!",[url path]);
        return NO;
    }
    
    const char* filePath = [[url path] fileSystemRepresentation];
    const char* attrName = "com.apple.MobileBackup";
    if (&NSURLIsExcludedFromBackupKey == nil) {
        // iOS 5.0.1 and lower
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
    else {
        // First try and remove the extended attribute if it is present
        int result = getxattr(filePath, attrName, NULL, sizeof(u_int8_t), 0, 0);
        if (result != -1) {
            // The attribute exists, we need to remove it
            int removeResult = removexattr(filePath, attrName, 0);
            if (removeResult == 0) {
                NSLog(@"Removed extended attribute on file %@", url);
            }
        }
        
        // Set the new key
        NSError *error = nil;
        BOOL success = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        NSLog(@"succes: %i",success);
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
        
        return success;
    }
}

- (BOOL) isEmptyObject :(id) object {
    if (object == nil) {
        return YES;
    }
    if((NSNull *)object == [NSNull null]){
		return YES;
    }
    if ([object isEqual:[NSNull null]]) {
        return YES;
    }
    //    if ([object respondsToSelector:@selector(isEqualToString:)]) {
    //        if ([object isEqualToString:@""]) {
    //            return YES;
    //        }
    //        return NO;
    //    }
    if ([object isKindOfClass:[NSNumber class]]) {
        return object == 0;
    }
    if ([object respondsToSelector:@selector(count)]) {
        return [object count] == 0;
    }
    //    if ([object respondsToSelector:@selector(length)]) {
    //        return [object length] == 0;
    //    }
    return NO;
}
@end