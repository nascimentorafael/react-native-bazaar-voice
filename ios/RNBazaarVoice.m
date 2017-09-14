#import "RNBazaarVoice.h"
#import "RCTConvert.h"
#import "RCTLog.h"
#import "RCTUIManager.h"
#import "RCTUtils.h"
#import "RCTBridge.h"
@import BVSDK;

@implementation RNBazaarVoice

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(getProductReviewsWithId:(NSString *)productId andLimit:(int)limit andOffset:(int)offset withResolver:(RCTPromiseResolveBlock)resolve andRejecter:(RCTResponseSenderBlock)reject) {
    BVReviewsTableView *reviewsTableView = [BVReviewsTableView new];
    BVReviewsRequest* request = [[BVReviewsRequest alloc] initWithProductId:productId limit:limit offset:offset];
    [reviewsTableView load:request success:^(BVReviewsResponse * _Nonnull response) {
        NSMutableArray *reviews = [NSMutableArray new];
        for (BVReview *review in response.results) {
            [reviews addObject:[self jsonFromReview:review]];
        }
        resolve(reviews);
    } failure:^(NSArray<NSError *> * _Nonnull errors) {
        reject(errors);
    }];
}

RCT_EXPORT_METHOD(submitReview:(NSDictionary *)review fromProduct:(NSString *)productId andUser:(NSDictionary *)user withResolver:(RCTPromiseResolveBlock)resolve andRejecter:(RCTResponseSenderBlock)reject) {
    
    //    NSLog(@"BVuser %@",user);
    //    NSLog(@"BVreview %@",review);
    
    // User info
    NSString *userNickname = [user objectForKey:@"userNickname"];
    NSString *locale = [user objectForKey:@"locale"];
    NSString *userId = [user objectForKey:@"userId"];
    NSString *userEmail = [user objectForKey:@"userEmail"];
    bool sendEmailAlertWhenPublished = [user objectForKey:@"sendEmailAlertWhenPublished"];
    bool agreedToTermsAndConditions = [user objectForKey:@"agreedToTermsAndConditions"];
    
    // Review info
    NSString *title = [review objectForKey:@"title"];
    NSString *text = [review objectForKey:@"text"];
    int comfort = [[review valueForKey:@"comfort"] intValue];
    int size = [[review valueForKey:@"size"] intValue];
    int rating = [[review valueForKey:@"rating"] intValue];
    int quality = [[review valueForKey:@"quality"] intValue];
    bool isRecommended = [user objectForKey:@"isRecommended"];
    
    BVReviewSubmission* bvReview = [[BVReviewSubmission alloc] initWithReviewTitle:title
                                                                        reviewText:text
                                                                            rating:rating
                                                                         productId:productId];
    bvReview.action = BVSubmissionActionPreview;
    bvReview.locale = locale;
    bvReview.userNickname = userNickname;
    bvReview.user = userId;
    bvReview.userEmail = userEmail;
    bvReview.sendEmailAlertWhenPublished = [NSNumber numberWithBool:sendEmailAlertWhenPublished];
    bvReview.agreedToTermsAndConditions  = [NSNumber numberWithBool:agreedToTermsAndConditions];
    bvReview.isRecommended = [NSNumber numberWithBool:isRecommended];
    bvReview.hostedAuthenticationEmail = userEmail;
    [bvReview addRatingQuestion:@"Comfort" value:comfort];
    [bvReview addRatingQuestion:@"Size" value:size];
    [bvReview addRatingQuestion:@"Quality" value:quality];
    
    [bvReview submit:^(BVReviewSubmissionResponse * _Nonnull response) {
        // review submitted successfully! 🎉
        resolve(response);
    } failure:^(NSArray * _Nonnull errors) {
        // handle failure appropriately  🚨
        reject(errors);
    }];
}

- (NSMutableDictionary *)jsonFromReview:(BVReview *)review {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:review.authorId forKey:@"authorId"];
    [dictionary setValue:review.productId forKey:@"productId"];
    [dictionary setObject:review.title forKey:@"title"];
    [dictionary setObject:review.description forKey:@"description"];
    [dictionary setObject:review.userNickname forKey:@"userNickname"];
    [dictionary setObject:review.reviewText forKey:@"reviewText"];
    return dictionary;
}

@end

