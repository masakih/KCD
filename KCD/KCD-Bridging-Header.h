//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//


// Other

#import <Foundation/Foundation.h>

@interface NSFileManager (KCDExtension)
- (nonnull NSString *)_web_pathWithUniqueFilenameForPath:(nonnull NSString *)path;
@end

