#import "HTTPRequest.h"
#import "CreateJSON.h"
@interface HTTPRequest()<NSURLConnectionDelegate>
@property (nonatomic) NSMutableData *responseData;
@property (nonatomic) NSURLConnection *conn;

@end

@implementation HTTPRequest

-(void) sendAsyncHTTPSignUPRequestWithEmail:(NSString*)email AndPassword:(NSString*)password{
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    [dictionary setValue:email forKey:@"emailID"];
    [dictionary setValue:password forKey:@"password"];
//    [dictionary setValue:@"Ecommerce" forKey:@"type"];
    [self sendHTTPRequestWithData:dictionary withRequestType:@"SignUp"];
}

-(void) sendAsyncHTTPResetPasswordRequest: (NSString*)emailID {
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    [dictionary setValue:emailID forKey:@"emailID"];
    [self sendHTTPRequestWithData:dictionary withRequestType:@"ResetPassword"];
}

-(void) sendAsyncHTTPRequestResendActivationLink: (NSString*)emailID{
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    
    [dictionary setValue:emailID forKey:@"emailID"];
    
    [self sendHTTPRequestWithData:dictionary withRequestType:@"ResendActivationLink"];
}

-(void) sendHTTPRequestWithData: (NSMutableDictionary*)dictionary withRequestType:(NSString*)requestType {
    
    NSString *post = [CreateJSON getJSONStringFromDictionary:dictionary];
    NSLog(@"post req %@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString* url = [@"https://utils.securifi.com/" stringByAppendingString:requestType];
    NSLog(@"post req %@ reqType %@",post,url);
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPBody:postData];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
        if (error){
            NSLog(@"Error,%@", [error localizedDescription]);
        }
        else{
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
            NSLog(@"%@ is the HTTP response",response);
            if(response == NULL)
                return ;
            if([requestType isEqualToString:@"SignUp"])
                [[NSNotificationCenter defaultCenter] postNotificationName:SIGN_UP_NOTIFIER object:nil userInfo:response];
            else if([requestType isEqualToString:@"ResetPassword"])
                [[NSNotificationCenter defaultCenter] postNotificationName:RESET_PWD_RESPONSE_NOTIFIER object:nil userInfo:response];
            else if([requestType isEqualToString:@"ResendActivationLink"])
                [[NSNotificationCenter defaultCenter] postNotificationName:VALIDATE_RESPONSE_NOTIFIER object:nil userInfo:response];
        }
    }];
}

-(void)sendHttpRequest:(NSString *)post {// make it paramater CMAC AMAC StartTag EndTag
    //NSString *post = [NSString stringWithFormat: @"userName=%@&password=%@", self.userName, self.password];
    
    
    NSLog(@"post req = %@",post);
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:@"https://sitemonitoring.securifi.com:8081"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; [request setTimeoutInterval:20.0];
    [request setHTTPBody:postData];
    self.conn = [NSURLConnection connectionWithRequest:request delegate:self];
    
    
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response { _responseData = [[NSMutableData alloc] init];
    NSLog(@"didReceiveResponse");
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
    NSLog(@"didReceiveData");
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    NSLog(@"willCacheResponse");
    return nil;
}
- (NSDictionary*)parseJson:(NSString*)fileName{
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName
                                                         ofType:@"json"];
    NSData *dataFromFile = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:dataFromFile
                                                         options:kNilOptions
                                                           error:&error];
    
    
    if (error != nil) {
        //NSLog(@"Error: was not able to load json file: %@.",fileName);
    }
    return data;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //Now you can do what you want with the response string from the data
    if(_responseData == nil)
        return;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    [_responseData setLength:0];
    _responseData = nil;
    /*note get endidentifier from db */
    //dispatch_async(self.sendReqQueue,^(){
    if(dict == NULL)
        return;
    if(dict[@"Data"] == NULL)
        return;
    if(dict[@"AMAC"] == NULL || dict[@"CMAC"] == NULL)
        return;
    [self.delegate responseDict:dict];
}
-(void)cancleConnection{
    [self.conn cancel];
    self.conn = nil;
}

@end
