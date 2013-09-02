//
//  CoreDataConstants.h
//  CoreDataR&D
//
//  Created by Manish Rathi on 02/09/13.

#import <Foundation/Foundation.h>

@interface NSString (Helper)

-(NSString *)getPathOfUniqueFolder:(NSString*)folderName;
-(NSString *)urlencode;
-(NSString *)removeNull;
-(NSString *)trim;
-(NSNumber *)toNumber;
-(NSNumber *)toFloat;
-(NSInteger)toNSInteger;
-(NSURL *)toURL;
-(NSDate *)toDate;
@end
