#import "RNBazaarInvoice.h"
@import BVSDK;

@implementation RNBazaarInvoice

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}
    
//    Get product review by ID:
//    PARAMETERS:
//    productId - the productId that you want reviews for
//    limit - max number of reviews to fetch (maximum of 20)
//    offset - the index to start on
    
RCT_EXPORT_MODULE(getProductReviewsWithId:(NSString *)productId andLimit:(int)limit andOffset:(int)offset failureCallback:(RCTResponseErrorBlock)failureCallback successCallback:(RCTResponseSenderBlock)successCallback) {
    
    BVReviewsTableView *reviewsTableView = [BVReviewsTableView new];
    
    BVReviewsRequest* request = [[BVReviewsRequest alloc] initWithProductId:productId limit:limit offset:offset];
    
//    [request addFilter:BVReviewFilterTypeHasPhotos filterOperator:BVFilterOperatorEqualTo value:@"true"]
//    [request addReviewSort:BVSortOptionReviewsSubmissionTime order:BVSortOrderDescending];
    
    [reviewsTableView load:request success:^(BVReviewsResponse * _Nonnull response) {
        successCallback(response.results);
    } failure:^(NSArray<NSError *> * _Nonnull error) {
        failureCallback(error);
    }];
    
}

@end
  
