//
//  CoreDataConstants.h
//  CoreDataR&D
//
//  Created by Manish Rathi on 02/09/13.

#import "NSString+Helper.h"
#define kDateTimeFormatter @"yyyy-MM-dd HH:mm"
@implementation NSString (Helper)

-(NSString *)getPathOfUniqueFolder:(NSString*)folderName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:folderName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return dataPath;
}

- (NSString *)urlencode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

-(NSString *)removeNull{
    if ([self length]==0 || self==nil || [self isEqual:[NSNull null]]) {
        return @"";
    }
    return self;
}

-(NSString *)trim{
    return [self stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(NSNumber *)toNumber{
    return [NSNumber numberWithInteger:[self integerValue]];
}

-(NSNumber *)toFloat{
    return [NSNumber numberWithFloat:[self floatValue]];
}

-(NSInteger)toNSInteger{
    return [self integerValue];
}

-(NSURL *)toURL{
    return [NSURL URLWithString:self];
}

-(NSDate *)toDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormatter];
    return [formatter dateFromString:self];
}

@end
