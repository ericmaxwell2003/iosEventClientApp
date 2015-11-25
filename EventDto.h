
#import <UIKit/UIKit.h>

@interface EventDto : NSObject

@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSString *thumbnailImgUrl;
@property (nonatomic, strong) NSString *detailImgUrl;

@end
