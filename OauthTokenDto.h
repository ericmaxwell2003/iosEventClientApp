
#import <UIKit/UIKit.h>

@interface OauthTokenDto : NSObject

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *refreshToken;
@property (nonatomic, strong) NSString *scope;
@property (nonatomic, strong) NSString *tokenType;
@property (nonatomic, assign) long expiresIn;

@end
