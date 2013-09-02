//
//  CoreDataConstants.h
//  CoreDataR&D
//
//  Created by Manish Rathi on 02/09/13.

#import <Foundation/Foundation.h>
@interface CoreDataManager : NSObject
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,strong) NSManagedObjectContext *managedObjectContext_background;
@property (readonly, nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic,strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(CoreDataManager *)instance;

-(BOOL)resetCoreDataManager;

-(BOOL)rollback_withManageObjectContext:(NSManagedObjectContext *) managedObjContext;

-(BOOL)saveConext_withManageObjectContext:(NSManagedObjectContext *) managedObjContext;

-(NSManagedObject *)setDataForEntity:(NSString*)entityName entityData:(NSDictionary *)data withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow;

-(NSArray *)getDataForEntity:(NSString*)entityName Predicate :(NSPredicate *) predicate AndArrayOfSortDescription :(NSArray *) sortDescriptions withManageObjectContext:(NSManagedObjectContext *) managedObjContext;
-(NSMutableArray *)getData_In_Dictionary_Format_ForEntity:(NSString*)entityName Predicate :(NSPredicate *) predicate AndArrayOfSortDescription :(NSArray *) sortDescriptions withManageObjectContext:(NSManagedObjectContext *) managedObjContext;

-(BOOL)updateManagedObject:(NSManagedObject *)objectDetails entityData:(NSDictionary *)data withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow;
-(BOOL)updateManagedObject_withObjectID:(NSString *)objectID entityData:(NSDictionary *)data withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow;

-(void)clearCoreData;
-(void)clearTableDataInfoForEntity:(NSString *)entityName withManageObjectContext:(NSManagedObjectContext *) managedObjContext;
-(void)clearTableDataInfoForEntities:(NSArray *)entityNames withManageObjectContext:(NSManagedObjectContext *) managedObjContext;

-(BOOL)deleteObject :(NSManagedObject *) mangedObject WithInstantUpdate :(BOOL) needToSaveNow withManageObjectContext:(NSManagedObjectContext *) managedObjContext;
-(BOOL)deleteObject_basedOn_ObjectID:(NSString *)ObjectId WithInstantUpdate:(BOOL)needToSaveNow withManageObjectContext:(NSManagedObjectContext *) managedObjContext;
-(BOOL)deleteAllObjectsForEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate withManageObjectContext:(NSManagedObjectContext *) managedObjContext WithInstantUpdate:(BOOL)needToSaveNow;

-(NSManagedObject *)getManagedobjectWithURI:(NSURL *)uri withManageObjectContext:(NSManagedObjectContext *) managedObjContext;
-(NSMutableDictionary *)getData_of_ObjectID:(NSString *)ObjectId withManageObjectContext:(NSManagedObjectContext *) managedObjContext;
-(NSMutableArray *)getObjectIDData_ofNSSet:(NSSet *)set withManageObjectContext:(NSManagedObjectContext *) managedObjContext;

-(NSMutableDictionary*)convertNSManageObject_To_Dictionary:(NSManagedObject *)managedobject;

@end
