#import "RNBazaarVoice"
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

RCT_EXPORT_METHOD(getProductReviewsWithId:(NSString *)productId andLimit:(int)limit andOffset:(int)offset failureCallback:(RCTResponseErrorBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback) {
    BVReviewsTableView *reviewsTableView = [BVReviewsTableView new];
    BVReviewsRequest* request = [[BVReviewsRequest alloc] initWithProductId:productId limit:limit offset:offset];
    [reviewsTableView load:request success:^(BVReviewsResponse * _Nonnull response) {
        NSMutableArray *reviews = [NSMutableArray new];
        for (BVReview *review in response.results) {
            [reviews addObject:[self jsonFromReview:review]];
        }
        successCallback(reviews);
    } failure:^(NSArray<NSError *> * _Nonnull errors) {
        failureCallback(errors[0]);
    }];
}

RCT_EXPORT_METHOD(submitReview:(NSDictionary *)review fromProduct:(NSString *)productId andUser:(NSDictionary *)user failureCallback:(RCTResponseErrorBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback) {
    
    NSLog(@"BVuser %@",user);
    NSLog(@"BVreview %@",review);
    
    // User info
    NSString *userNickname = [user objectForKey:@"userNickname"];
    //    NSString *userId = [user objectForKey:@"userId"];
    NSString *userEmail = [user objectForKey:@"userEmail"];
    bool sendEmailAlertWhenPublished = [user objectForKey:@"sendEmailAlertWhenPublished"];
    bool agreedToTermsAndConditions = [user objectForKey:@"agreedToTermsAndConditions"];
    
    // Review info
    NSString *title = [review objectForKey:@"title"];
    NSString *text = [review objectForKey:@"text"];
    int rating = [[review valueForKey:@"rating"] intValue];
    
    NSLog(@"rating %d", rating);
    
    BVReviewSubmission* bvReview = [[BVReviewSubmission alloc] initWithReviewTitle:title
                                                                        reviewText:text
                                                                            rating:rating
                                                                         productId:productId];
    bvReview.action = BVSubmissionActionPreview;
    bvReview.userNickname = userNickname;
    bvReview.user = [NSString stringWithFormat:@"userId%d", arc4random()];
    bvReview.userEmail = userEmail;
    bvReview.sendEmailAlertWhenPublished = [NSNumber numberWithBool:sendEmailAlertWhenPublished];
    bvReview.agreedToTermsAndConditions  = [NSNumber numberWithBool:agreedToTermsAndConditions];
    bvReview.isRecommended = [NSNumber numberWithBool:YES];
    
    [bvReview submit:^(BVReviewSubmissionResponse * _Nonnull response) {
        // review submitted successfully! 🎉
        successCallback(@[response]);
    } failure:^(NSArray * _Nonnull errors) {
        // handle failure appropriately  🚨
        for (NSError* error in errors) {
            
            // If fields had errors, useful information is available in the error
            NSString* fieldErrorName = error.userInfo[BVFieldErrorName];
            NSString* fieldErrorMessage = error.userInfo[BVFieldErrorMessage];
            
            if (fieldErrorName && [fieldErrorName isEqualToString:@"reviewText"]) {
                // fieldErrorMessage = "You must enter review text."
                NSLog(@"fieldErrorName: %@ - %@", fieldErrorName, fieldErrorMessage);
            }
            
            if (fieldErrorName && [fieldErrorName isEqualToString:@"rating"]) {
                // fieldErrorMessage = "This field must be between 1 and 5."
                NSLog(@"fieldErrorName: %@ - %@", fieldErrorName, fieldErrorMessage);
            }
            
        }
        failureCallback(errors[0]);
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

