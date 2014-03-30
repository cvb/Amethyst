#import <Foundation/Foundation.h>

@class KbLayoutManager;

// Object for managing the windows across all screens and spaces.
@interface KbLayoutManager : NSObject

// Returns the screen manager responsible for the screen containing the
// currently focused window.
- (void) setInput;
- (CFStringRef) getInput;
- (BOOL) inEmacs;
- (void) toggleInput;
- (void) sync;

@end
