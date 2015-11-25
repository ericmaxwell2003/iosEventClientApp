
#import "EventService.h"

#import "AFNetworking.h"
#import "EventDto.h"
#import "LoginDto.h"
#import "RegistrationDto.h"
#import "OauthTokenDto.h"

@interface EventService()

@property (nonatomic, strong) OauthTokenDto *oauthTokenDto;

@end

@implementation EventService

+ (EventService *)sharedInstance
{
    __strong static EventService *_sharedObject = nil;
    static dispatch_once_t pred=0;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)loginUsingLoginDto:(LoginDto *)loginDto
{
    NSString *urlString = [BASE_URL stringByAppendingString:LOGIN];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
             requestWithMethod:@"POST"
                     URLString:urlString
                    parameters:@{@"username":loginDto.username, @"password":loginDto.password}
                         error:&error];
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
   
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             OauthTokenDto *token = [[OauthTokenDto alloc] init];
             token.accessToken = [responseObject objectForKey:@"access_token"];
             token.refreshToken = [responseObject objectForKey:@"refresh_token"];
             token.scope = [responseObject objectForKey:@"scope"];
             token.tokenType = [responseObject objectForKey:@"token_type"];
             token.expiresIn = [[responseObject objectForKey:@"expires_in"] longValue];
             self.oauthTokenDto = token;
             [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_CALL_COMPLETED_WITH_RESULT object:nil];
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_CALL_FAILED_WITH_ERROR object:error];
        }];

    [manager.operationQueue addOperation:operation];
}

- (void)registerWithRegistrationDto:(RegistrationDto *)registrationDto
{
    NSString *urlString = [BASE_URL stringByAppendingString:REGISTER];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer]
                                    requestWithMethod:@"POST"
                                    URLString:urlString
                                    parameters:@{@"fullName":registrationDto.name,
                                                    @"email":registrationDto.email,
                                                 @"username":registrationDto.username,
                                                 @"password":registrationDto.password}
                                    error:&error];

    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             RegistrationDto *dto = [[RegistrationDto alloc] init];
             dto.name = [responseObject objectForKey:@"fullName"];
             dto.email = [responseObject objectForKey:@"email"];
             dto.username = [responseObject objectForKey:@"username"];
             [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_CALL_COMPLETED_WITH_RESULT object:dto];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_CALL_FAILED_WITH_ERROR object:error];
         }];
    
    [manager.operationQueue addOperation:operation];


}

- (void)loadEventsFromServerUsingSyncToken:(NSString *)syncToken
{

    NSString *urlString = [BASE_URL stringByAppendingString:EVENTS];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    // If we dont' have an OAuthToken yet, then we won't set it here.  The call will fail because the resource
    // is secured by token access.
    if(self.oauthTokenDto.accessToken) {
        [manager.requestSerializer setValue:[@"Bearer " stringByAppendingString:self.oauthTokenDto.accessToken]
                         forHTTPHeaderField:@"Authorization"];
    }

    if(!syncToken) {
        syncToken = @"";
    }
    
    [manager GET:urlString parameters:@{@"syncToken": syncToken} success:^(AFHTTPRequestOperation *operation, id eventResponse) {
        
        NSMutableArray *events = [NSMutableArray array];
        NSString *newSyncToken = @"syncToken";//[[responseObject objectForKey:@"data"] objectForKey:@"token"];
        
//        for (id json in [[responseObject objectForKey:@"data"] objectForKey:@"children"]) {
        for (id json in eventResponse) {
        
            EventDto *event = [[EventDto alloc] init];
            event.guid = [json objectForKey:@"guid"];
            event.url = [json objectForKey:@"url"];
            event.summary = [json objectForKey:@"summary"];
            event.details = [json objectForKey:@"details"];
            event.thumbnailImgUrl = [json objectForKey:@"thumbnailImgUrl"];
            event.detailImgUrl = [json objectForKey:@"detailImgUrl"];
 
            [events addObject:event];
        }
        NSDictionary *eventObject = @{@"events": events, @"syncToken": newSyncToken};
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_CALL_COMPLETED_WITH_RESULT object:eventObject];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EVENTS_CALL_FAILED_WITH_ERROR object:error];
    }];

    
}

@end
