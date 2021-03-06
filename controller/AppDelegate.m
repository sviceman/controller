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
@property (nonatomic, retain) NSMutableData *_responseData;

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

@synthesize responseData = _responseData;


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



/*
 - (void) CheckStatus:(NSString *)data
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
                        NSString *responseBody = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
                        NSError *jsonError;
                        NSLog(@"Response %@", responseBody);
                            
                        NSData* jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
                        NSLog(@"Status: %@", [[jsonObject objectForKey:@"result"] objectForKey:@"i2p.router.net.status"]);
                            NSDictionary *statusObject = [jsonObject objectForKey:@"result"];
                        int status_code = [[statusObject objectForKey:@"i2p.router.net.status"] intValue];
                        //NSLog(@"Code: %@", status_code);
                            NSString *Status;
                            switch (status_code) {
                                case 0:
                                    Status=@"OK";
                                    break;
                                case 1:
                                    Status=@"Testing";
                                    break;
                                case 2:
                                    Status=@"FIREWALLED";
                                    break;
                                case 3:
                                    Status=@"HIDDEN";
                                case 4:
                                    Status=@"WARN";
                                case 5:
                                    Status=@"WARN";
                                case 6:
                                    Status=@"WARN";
                                case 7:
                                    Status=@"WARN";
                                case 8:
                                    Status=@"ERROR";
                                case 9:
                                    Status=@"ERROR";
                                case 10:
                                    Status=@"ERROR";
                                case 11:
                                    Status=@"ERROR";
                                case 12:
                                    Status=@"ERROR";
                                case 13:
                                    Status=@"ERROR";
                                case 14:
                                    Status=@"ERROR";

                                default:
                                    Status=@"Connecting";
                            }
                            [[_statusMenu itemAtIndex:0]  setTitle:Status];
                        
                              [calledBy performSelector:successCallback withObject:result];
                              
                          }
                      }];
}
*/

/*
- (void) CheckStatus:(NSString *)data
            calledBy:(id)calledBy
         withSuccess:(SEL)successCallback
          andFailure:(SEL)failureCallback{
    int status_code = 0;
    while ( status_code != 1 )
    {

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
                              NSString *responseBody = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding];
                              NSError *jsonError;
                              NSLog(@"Response %@", responseBody);
                              
                              NSData* jsonData = [responseBody dataUsingEncoding:NSUTF8StringEncoding];
                              NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
                              NSLog(@"Status: %@", [[jsonObject objectForKey:@"result"] objectForKey:@"i2p.router.status"]);
                              NSDictionary *statusObject = [jsonObject objectForKey:@"result"];
                              int status_code = [[statusObject objectForKey:@"i2p.router.status"] intValue];
                              NSLog(@"Code: %@", status_code);
                              
                              
                              //[[_statusMenu itemAtIndex:0]  setTitle:Status];
                              
                              [calledBy performSelector:successCallback withObject:result];
                              
                          }
                      }];
        sleep(10);
        NSLog(@"status_code");
        NSImage *icon = [NSImage imageNamed:@"Connected"];
        self.statusItem.image = icon;

    }
}














*/
- (void)RequestEnd:(id)result{
    NSLog(@"ReuqestEnd:");

    
}

- (void)RequestFailure:(id)result{
    NSLog(@"RequestFailure:");
    // Do your actions
}





- (void)load {
    self.responseData = [NSMutableData data];
    NSURL *myURL = [NSURL URLWithString:@"https://localhost:7650/jsonrpc"];
     NSString *dataSend = @"{\"id\":\"1\", \"method\":\"RouterInfo\",\"params\":{\"i2p.router.status\":\"\"},\"jsonrpc\":\"2.0\"}";
    NSData *postData = [dataSend dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

    NSLog(@"%@", dataSend);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[dataSend length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: postData];
    
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(load) userInfo:nil repeats:NO];
    //[self load];

    NSLog(@"Connection failed: %@", [error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Getting your response string
    
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    self.responseData = nil;
    NSLog(@"%@", responseString);
    NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *statusObject = [json objectForKey:@"result"];

    NSString *status_code = [statusObject objectForKey:@"i2p.router.status"];
    if (![status_code isEqual:@"1"]) {
        
    
    NSLog(@"Code: %@", status_code);
        //sleep(3);
        //[self performSelector:@selector(load:) withObject:nil afterDelay:5.0];
            [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(load) userInfo:nil repeats:NO];
        //[NSThread detachNewThreadSelector:@selector(load) toTarget:self withObject:nil];
    }else{
    NSImage *icon = [NSImage imageNamed:@"Connected"];
    self.statusItem.image = icon;
    }
    }






















- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    //[self.statusItem setTitle:@"I2PD"];
    NSImage *icon = [NSImage imageNamed:@"AppIcon"];
    //icon.template = YES;
    self.statusItem.image = icon;
    
    [self.statusItem setHighlightMode:YES];
    //[[_statusMenu itemAtIndex:0]  setEnabled:NO];

    
    

}


- (IBAction)StartI2PD:(id)sender {
    NSBundle *myBundle = [NSBundle mainBundle];
    NSString *absPath= [myBundle pathForResource:@"i2pd" ofType:@""];
    NSString *confPath = [myBundle pathForResource:@"tunnel" ofType:@"conf"];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:absPath];
    NSMutableString* tunnConf = [NSMutableString stringWithString: @"--tunconf="];
    [tunnConf appendString:confPath];
    [task setArguments:@[ @"--i2pcontrol.enabled=1",tunnConf,@"--loglevel=error"]];
    [task launch];
    //[_statusMenu isEnabled:false];
    //[_statusItem.enabled:0];
    [[_statusMenu itemAtIndex:2]  setEnabled:NO];
    [[_statusMenu itemAtIndex:3]  setEnabled:YES];

    NSImage *icon = [NSImage imageNamed:@"Connecting"];
    self.statusItem.image = icon;
    //[NSThread detachNewThreadSelector:@selector(load) toTarget:self withObject:nil];
        [NSTimer scheduledTimerWithTimeInterval:.16 target:self selector:@selector(load) userInfo:nil repeats:NO];
    //[self load];
    /*
    NSString *dataSend = @"{\"id\":\"1\", \"method\":\"RouterInfo\",\"params\":{\"i2p.router.net.status\":\"\"},\"jsonrpc\":\"2.0\"}";
    
    [self CheckStatus:dataSend
             calledBy:self
          withSuccess:@selector(RequestEnd:)
           andFailure:@selector(RequestFailure:)];
*/
}
    
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    return [menuItem isEnabled];
}

- (IBAction)StopI2PD:(id)sender {
    NSString *dataSend = @"{\"id\":\"1\", \"method\":\"RouterManager\",\"params\":{\"Shutdown\":\"\"},\"jsonrpc\":\"2.0\"}";
    
    [self SendRequest:dataSend
       calledBy:self
    withSuccess:@selector(RequestEnd:)
     andFailure:@selector(RequestFailure:)];
    [[_statusMenu itemAtIndex:3]  setEnabled:NO];
    NSImage *icon = [NSImage imageNamed:@"AppIcon"];
    self.statusItem.image = icon;
    [[_statusMenu itemAtIndex:2]  setEnabled:YES];


}
- (IBAction)ShowWin:(id)sender {
    NSWindowController *controllerWindow = [[NSWindowController alloc] initWithWindowNibName:@"Controller"];
    [controllerWindow showWindow:self];
}
- (IBAction)ExitApp:(id)sender {
    NSString *dataSend = @"{\"id\":\"1\", \"method\":\"RouterManager\",\"params\":{\"Shutdown\":\"\"},\"jsonrpc\":\"2.0\"}";
    
    [self SendRequest:dataSend
             calledBy:self
          withSuccess:@selector(RequestEnd:)
           andFailure:@selector(RequestFailure:)];

    for (NSWindow *window in [NSApplication sharedApplication].windows) {
        [window close];
    }
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(terminate:self:) userInfo:nil repeats:NO];
    //[NSApp terminate:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    //    usleep(3000000);
}


@end
