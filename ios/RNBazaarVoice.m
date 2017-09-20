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

RCT_EXPORT_METHOD(getUserSubmittedReviews:(NSString *)authorId withLimit:(int)limit withResolver:(RCTPromiseResolveBlock)resolve andRejecter:(RCTResponseSenderBlock)reject) {
    BVAuthorRequest *request = [[BVAuthorRequest alloc] initWithAuthorId:authorId];
    [request includeStatistics:BVAuthorContentTypeReviews];
    [request includeContent:BVAuthorContentTypeReviews limit:limit];
    [request load:^(BVAuthorResponse * _Nonnull response) {
        NSArray *reviews;
        if (response.results.count > 0) {
            BVAuthor *author = response.results[0];
            reviews = [self parseReviews:author.includedReviews];
        }
        resolve(reviews);
    } failure:^(NSArray * _Nonnull errors) {
        reject(errors);
    }];
}

RCT_EXPORT_METHOD(getProductReviewsWithId:(NSString *)productId andLimit:(int)limit offset:(int)offset andLocale:(NSString*)locale withResolver:(RCTPromiseResolveBlock)resolve andRejecter:(RCTResponseSenderBlock)reject) {
    BVReviewsTableView *reviewsTableView = [BVReviewsTableView new];
    BVReviewsRequest* request = [[BVReviewsRequest alloc] initWithProductId:productId limit:limit offset:offset];
    [request addFilter:BVReviewFilterTypeContentLocale filterOperator:BVFilterOperatorEqualTo value:locale];
    [reviewsTableView load:request success:^(BVReviewsResponse * _Nonnull response) {
        resolve([self parseReviews:response.results]);
    } failure:^(NSArray<NSError *> * _Nonnull errors) {
        reject(@[@"Error"]);
    }];
}

RCT_EXPORT_METHOD(submitReview:(NSDictionary *)review fromProduct:(NSString *)productId andUser:(NSDictionary *)user withResolver:(RCTPromiseResolveBlock)resolve andRejecter:(RCTResponseSenderBlock)reject) {
    NSString *nickname = [user objectForKey:@"nickname"];
    NSString *locale = [user objectForKey:@"locale"];
    NSString *token = [user objectForKey:@"token"];
    NSString *email = [user objectForKey:@"email"];
    NSString *profilePicture = [user objectForKey:@"profilePicture"];
    bool sendEmailAlertWhenPublished = [user objectForKey:@"sendEmailAlertWhenPublished"];
    
    NSString *title = [review objectForKey:@"title"];
    NSString *text = [review objectForKey:@"text"];
    int comfort = [[review valueForKey:@"comfort"] intValue];
    int size = [[review valueForKey:@"size"] intValue];
    int rating = [[review valueForKey:@"rating"] intValue];
    int quality = [[review valueForKey:@"quality"] intValue];
    int width = [[review valueForKey:@"width"] intValue];
    bool isRecommended = [user objectForKey:@"isRecommended"];
    
    BVReviewSubmission* bvReview = [[BVReviewSubmission alloc] initWithReviewTitle:title
                                                                        reviewText:text
                                                                            rating:rating
                                                                         productId:productId];
    bvReview.action = BVSubmissionActionSubmit;
    bvReview.locale = locale;
    bvReview.userNickname = nickname;
    bvReview.user = token;
    bvReview.userEmail = email;
    bvReview.sendEmailAlertWhenPublished = [NSNumber numberWithBool:sendEmailAlertWhenPublished];
    bvReview.isRecommended = [NSNumber numberWithBool:isRecommended];
    [bvReview addRatingQuestion:@"Comfort" value:comfort];
    [bvReview addRatingQuestion:@"Size" value:size];
    [bvReview addRatingQuestion:@"Quality" value:quality];
    [bvReview addRatingQuestion:@"Width" value:width];
    [bvReview addAdditionalField:@"profilePicture" value:profilePicture];
    [bvReview submit:^(BVReviewSubmissionResponse * _Nonnull response) {
        if (response.submissionId) {
            resolve(@[response.submissionId]);
        } else {
            reject(@[@"Could not find submission ID."]);
        }
    } failure:^(NSArray * _Nonnull errors) {
        reject(@[@"Error"]);
    }];
}

-(NSArray *)parseReviews:(NSArray*)results {
    NSMutableArray *reviews = [NSMutableArray new];
    for (BVReview *review in results) {
        [reviews addObject:[self jsonFromReview:review]];
    }
    return reviews;
}

- (NSMutableDictionary *)jsonFromReview:(BVReview *)review {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setValue:review.authorId forKey:@"userUuid"];
    [dictionary setValue:review.identifier forKey:@"reviewId"];
    [dictionary setValue:review.submissionId forKey:@"submissionId"];
    [dictionary setValue:review.productId forKey:@"productId"];
    [dictionary setObject:review.title forKey:@"title"];
    [dictionary setObject:review.userNickname forKey:@"nickname"];
    [dictionary setObject:review.reviewText forKey:@"reviewText"];
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssxxx";
    [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    NSString *date = [dateFormatter stringFromDate:review.submissionTime];
    
    [dictionary setObject:date forKey:@"date"];
    [dictionary setObject:[NSNumber numberWithInteger:review.rating] forKey:@"rating"];
    
    NSDictionary *additionalField = review.additionalFields;
    if ([additionalField objectForKey:@"profilePicture"]) {
        NSString *profilePicture = [additionalField objectForKey:@"profilePicture"];
        [dictionary setObject:profilePicture forKey:@"profilePicture"];
    }
    
    return dictionary;
}

@end

