#import "KbLayout.h"

@interface KbLayoutManager ()
@property CFStringRef kbLayout;
@property CFStringRef RU;
@property CFStringRef US;
@end

@implementation KbLayoutManager

- (id)init {
  self = [super init];
  if (self) {

    self.kbLayout =
      TISGetInputSourceProperty(TISCopyCurrentKeyboardLayoutInputSource(),
                                kTISPropertyInputSourceID);

    self.RU = CFSTR("com.apple.keylayout.Russian");
    self.US = CFSTR("com.apple.keylayout.US");

  }
  return self;
}

- (void) setInput: (CFStringRef) name {
  TISInputSourceRef inputSource = NULL;
  CFArrayRef allInputs = TISCreateInputSourceList(NULL, true);
  NSUInteger count = CFArrayGetCount(allInputs);
  for (int i = 0; i < count; i++) {
    inputSource = (TISInputSourceRef)CFArrayGetValueAtIndex(allInputs, i);
    CFStringRef sid =
      TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    if (!CFStringCompare(name, sid, 0)) {
      TISEnableInputSource(inputSource);
      TISSelectInputSource(inputSource);

    }
  }
  CFRelease(allInputs);
}

- (CFStringRef) getInput {
  return TISGetInputSourceProperty(TISCopyCurrentKeyboardLayoutInputSource(),
                            kTISPropertyInputSourceID);
}

- (BOOL) inEmacs {
  SIWindow *w = [SIWindow focusedWindow];
  SIApplication *application =
    [self applicationWithProcessIdentifier:w.processIdentifier];
  NSString *name = [application stringForKey:kAXTitleAttribute];
  if ([name isEqual:@"Emacs"])
    return YES;
  else
    return NO;
}

- (void) updateInner {
  self.kbLayout =
    TISGetInputSourceProperty(TISCopyCurrentKeyboardLayoutInputSource(),
                              kTISPropertyInputSourceID);
  return;
}

- (void) toggleInput {
  if (!CFStringCompare([self getInput], self.RU, 0)) {
    [self setInput:self.US];
    [self updateInner];
  } else if ([self inEmacs]) {
    [self setInput:self.US];
    [self toggleEmacsLayout];
  } else {
    [self setInput:self.RU];
    [self updateInner];
  }
}

- (void) toggleEmacsLayout {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setArguments:@[ @"-c", @"/usr/local/bin/emacsclient -e \
                                   '(with-current-buffer \
                                        (other-buffer :visible-ok t) \
                                      (toggle-input-method))'"
                          ]];
    [task launch];
}

- (void) sync {
  if (!CFStringCompare([self getInput], self.RU, 0) && [self inEmacs]) {
    [self setInput:self.US];
    [self toggleEmacsLayout];
  } else if (CFStringCompare([self getInput], self.kbLayout, 0)){
    [self setInput:self.kbLayout];
  }
}

- (SIApplication *)applicationWithProcessIdentifier:(pid_t)processIdentifier {
    for (SIApplication *application in [SIApplication runningApplications]) {
        if (application.processIdentifier == processIdentifier) {
            return application;
        }
    }
    return nil;
}

@end
