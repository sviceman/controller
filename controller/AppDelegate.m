//
//  AppDelegate.m
//  controller
//
//  Created by Serghey Vice on 1/23/17.
//  Copyright © 2017 Serghey Vice. All rights reserved.
//

#import "AppDelegate.h"
#import "sys/socket.h"

@interface AppDelegate ()

@end


@interface NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
@end

@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}
@end

@implementation AppDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge

{
    
    [challenge.sender useCredential:challenge.proposedCredential forAuthenticationChallenge:challenge];

    
}



-(void)placePostRequestWithURL:(NSString *)action data:(NSString *)data withHandler:(void (^)(NSURLResponse *response, NSData *data, NSError *error))ourBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@", action];
    NSLog(@"%@", urlString);
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSError *error;
    
    //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataToSend options:0 error:&error];
    
    NSString *jsonString;
    if (! data) {
        NSLog(@"Got an error: %@", error);
    } else {
        
        //NSString *data = @"{\"id\":\"1\", \"method\":\"RouterManager\",\"params\":{\"Shutdown\":\"\"},\"jsonrpc\":\"2.0\"}";
        NSData *postData = [data dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody: postData];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:ourBlock];
    }
}

- (void) SendRequest:(NSString *)data
      calledBy:(id)calledBy
   withSuccess:(SEL)successCallback
    andFailure:(SEL)failureCallback{
    [self placePostRequestWithURL:@"https://localhost:7650/jsonrpc"
                         data:data
                      withHandler:^(NSURLResponse *response, NSData *rawData, NSError *error) {
                          NSString *string = data;
                          
                          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                          NSInteger code = [httpResponse statusCode];
                          NSLog(@"%ld", (long)code);
                          
                          if (!(code >= 200 && code < 300)) {
                              NSLog(@"ERROR (%ld): %@", (long)code, string);
                              [calledBy performSelector:failureCallback withObject:string];
                          } else {
                              NSLog(@"OK");
                              
                              NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      string, @"result",
                                                      nil];
                              [calledBy performSelector:successCallback withObject:result];
                          }
                      }];
}
- (void)RequestEnd:(id)result{
    NSLog(@"ReuqestEnd:");
    // Do your actions
}

- (void)RequestFailure:(id)result{
    NSLog(@"RequestFailure:");
    // Do your actions
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    //[self.statusItem setTitle:@"I2PD"];
    NSImage *icon = [NSImage imageNamed:@"AppIcon"];
    icon.template = YES;
    self.statusItem.image = icon;
    
    [self.statusItem setHighlightMode:YES];
    //CFBundleRef mainBundle;
    
    
    //NSString *dir=[[NSFileManager defaultManager] currentDirectoryPath];
    //[[NSAlert alertWithMessageText:@"dir"
    //                 defaultButton:@"OK"
    //               alternateButton:nil
    //                   otherButton:nil
    //     informativeTextWithFormat:dir] runModal];
    // Get the main bundle for the app
    
    //mainBundle = CFBundleGetMainBundle();

    
    

}


- (IBAction)StartI2PD:(id)sender {
    NSBundle *myBundle = [NSBundle mainBundle];
    NSString *absPath= [myBundle pathForResource:@"i2pd" ofType:@""];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:absPath];
    [task setArguments:@[ @"--i2pcontrol.enabled=1", @"--loglevel=error"]];
    [task launch];
    [_statusItem setTarget:nil];
    
}
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return [menuItem isEnabled];
}
- (IBAction)StopI2PD:(id)sender {
    //NSDictionary *dataToSend = [NSDictionary dictionaryWithObjectsAndKeys:
    //                            @"id" , @"1",
    //                            @"method", @"RouterManager",
    //                            @"param",@"{\"Shutdown\":\"\"}",
    //                            @"jsonrpc", @"2.0",
    //                            nil];
    NSString *dataSend = @"{\"id\":\"1\", \"method\":\"RouterManager\",\"params\":{\"Shutdown\":\"\"},\"jsonrpc\":\"2.0\"}";
    
    [self SendRequest:dataSend
       calledBy:self
    withSuccess:@selector(RequestEnd:)
     andFailure:@selector(RequestFailure:)];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
