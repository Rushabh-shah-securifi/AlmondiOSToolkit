#import "HTTPRequest.h"
#import "CreateJSON.h"

@implementation HTTPRequest


-(void) sendAsyncHTTPSignUPRequestWithEmail:(NSString*)email AndPassword:(NSString*)password{
    
    NSMutableDictionary* dictionary = [NSMutableDictionary new];
    
    [dictionary setValue:email forKey:@"emailID"];
    [dictionary setValue:password forKey:@"password"];
    [dictionary setValue:@"Ecommerce" forKey:@"type"];
    
    NSLog(@"%@ signuprequest",dictionary);
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
    
    dispatch_queue_t sendReqQueue = dispatch_queue_create("send_req", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(sendReqQueue,^(){
        
        NSString *post = [CreateJSON getJSONStringfromDictionary:dictionary];
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        
        NSString* url = [@"https://utils.securifi.com/" stringByAppendingString:requestType];
        
        [request setURL:[NSURL URLWithString:url]];
        
        [request setHTTPMethod:@"POST"];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        [request setHTTPBody:postData];
        
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if(conn) {
            NSLog(@"Connection Successful");
        } else {
            NSLog(@"Connection could not be made");
        }
        
        NSError *error;
        NSURLResponse *res= Nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:&error];
        if (error){
            NSLog(@"Error,%@", [error localizedDescription]);
        }
        else{
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
            NSLog(@"%@ is the response for signup",response);
            if([requestType isEqualToString:@"SignUp"])
                [[NSNotificationCenter defaultCenter] postNotificationName:SIGN_UP_NOTIFIER object:nil userInfo:response];
            else if([requestType isEqualToString:@"ResetPassword"])
                [[NSNotificationCenter defaultCenter] postNotificationName:RESET_PWD_RESPONSE_NOTIFIER object:nil userInfo:response];
            else if([requestType isEqualToString:@"ResendActivationLink"])
                [[NSNotificationCenter defaultCenter] postNotificationName:VALIDATE_RESPONSE_NOTIFIER object:nil userInfo:response];
        }
    });
    
}

@end
