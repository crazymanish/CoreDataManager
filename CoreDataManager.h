//
//  CoreDataManager.h
//  Version 0.1
//  Created by Manish Rathi on 3.9.13.
//
// Copyright (c) 2013 Manish Rathi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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
