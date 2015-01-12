//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "HMAppDelegate.h"

#import "HMKCManagedObject.h"

#import "HMFleetInformation.h"


#import "HMJSONCommand.h"
#import "HMCompositCommand.h"

#import "HMMemberShipCommand.h"
#import "HMMemberSlotItemCommand.h"
#import "HMKenzoMarkCommand.h"
#import "HMRealDestroyShipCommand.h"
#import "HMMemberMaterialCommand.h"

@interface NSFileManager (KCDExtension)
- (NSString *)_web_pathWithUniqueFilenameForPath:(NSString *)path;
@end
