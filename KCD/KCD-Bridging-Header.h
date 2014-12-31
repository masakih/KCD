//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "HMAppDelegate.h"
#import "HMUserDefaults.h"

#import "HMServerDataStore.h"
#import "HMLocalDataStore.h"
#import "HMTemporaryDataStore.h"

#import "HMKCManagedObject.h"
#import "HMKCShipObject+Extensions.h"

#import "HMMissionStatus.h"
#import "HMNyukyoDockStatus.h"
#import "HMKenzoDockStatus.h"
#import "HMFleetInformation.h"


@interface NSFileManager (KCDExtension)
- (NSString *)_web_pathWithUniqueFilenameForPath:(NSString *)path;
@end
