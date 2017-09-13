package com.reactlibrary;

import com.bazaarvoice.bvandroidsdk.Action;
import com.bazaarvoice.bvandroidsdk.BVConversationsClient;
import com.bazaarvoice.bvandroidsdk.BVSDK;
import com.bazaarvoice.bvandroidsdk.BazaarException;
import com.bazaarvoice.bvandroidsdk.ConversationsCallback;
import com.bazaarvoice.bvandroidsdk.ReviewResponse;
import com.bazaarvoice.bvandroidsdk.ReviewSubmissionRequest;
import com.bazaarvoice.bvandroidsdk.ReviewSubmissionResponse;
import com.bazaarvoice.bvandroidsdk.ReviewsRequest;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

public class RNBazaarVoiceModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;
  private final BVConversationsClient client;

  public RNBazaarVoiceModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.client = new BVConversationsClient.Builder(BVSDK.getInstance()).build();
  }

  @Override public String getName() {
    return "RNBazaarVoice";
  }

  @ReactMethod public void getProductReviewsWithId(
      String productId, int limit, int offset, final Promise promise) {
    ReviewsRequest reviewsRequest = new ReviewsRequest.Builder(productId, limit, offset).build();
    client.prepareCall(reviewsRequest).loadAsync(new ConversationsCallback<ReviewResponse>() {
      @Override public void onSuccess(ReviewResponse response) {
        promise.resolve(response.getResults());
      }

      @Override public void onFailure(BazaarException exception) {
        promise.reject(exception);
      }
    });
  }

  @ReactMethod public void submitReview(
      ReadableMap review, String productId, ReadableMap user, final Promise promise) {
    ReviewSubmissionRequest previewSubmission =
        new ReviewSubmissionRequest.Builder(Action.Preview, productId).userId(user.getString(
            "userId"))
            .userNickname(user.getString("userNickname"))
            .sendEmailAlertWhenPublished(user.getBoolean("sendEmailAlertWhenPublished"))
            .agreedToTermsAndConditions(user.getBoolean("agreedToTermsAndConditions"))
            .title(review.getString("title"))
            .reviewText("text")
            .rating(review.getInt("rating"))
            .userEmail(user.getString("userEmail"))
            .build();

    client.prepareCall(previewSubmission)
        .loadAsync(new ConversationsCallback<ReviewSubmissionResponse>() {
          @Override public void onSuccess(ReviewSubmissionResponse response) {
            promise.resolve(response);
          }

          @Override public void onFailure(BazaarException exception) {
            promise.reject(exception);
          }
        });
  }
}