package com.reactlibrary;

import android.util.Log;
import com.bazaarvoice.bvandroidsdk.Action;
import com.bazaarvoice.bvandroidsdk.AuthorIncludeType;
import com.bazaarvoice.bvandroidsdk.AuthorsRequest;
import com.bazaarvoice.bvandroidsdk.AuthorsResponse;
import com.bazaarvoice.bvandroidsdk.BVConversationsClient;
import com.bazaarvoice.bvandroidsdk.BVSDK;
import com.bazaarvoice.bvandroidsdk.BazaarException;
import com.bazaarvoice.bvandroidsdk.ConversationsCallback;
import com.bazaarvoice.bvandroidsdk.ReviewResponse;
import com.bazaarvoice.bvandroidsdk.ReviewSubmissionRequest;
import com.bazaarvoice.bvandroidsdk.ReviewSubmissionResponse;
import com.bazaarvoice.bvandroidsdk.ReviewsRequest;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.google.gson.Gson;
import java.util.Iterator;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class RNBazaarVoiceModule extends ReactContextBaseJavaModule {

  private final BVConversationsClient client;
  private static final Gson gson = new Gson();

  public RNBazaarVoiceModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.client = new BVConversationsClient.Builder(BVSDK.getInstance()).build();
  }

  private static WritableMap jsonToReact(JSONObject jsonObject) throws JSONException {
    WritableMap writableMap = Arguments.createMap();
    Iterator iterator = jsonObject.keys();
    while (iterator.hasNext()) {
      String key = (String) iterator.next();
      Object value = jsonObject.get(key);
      if (value instanceof Float || value instanceof Double) {
        writableMap.putDouble(key, jsonObject.getDouble(key));
      } else if (value instanceof Number) {
        writableMap.putInt(key, jsonObject.getInt(key));
      } else if (value instanceof String) {
        writableMap.putString(key, jsonObject.getString(key));
      } else if (value instanceof JSONObject) {
        writableMap.putMap(key, jsonToReact(jsonObject.getJSONObject(key)));
      } else if (value instanceof JSONArray) {
        writableMap.putArray(key, jsonToReact(jsonObject.getJSONArray(key)));
      } else if (value == JSONObject.NULL) {
        writableMap.putNull(key);
      }
    }
    return writableMap;
  }

  private static WritableArray jsonToReact(JSONArray jsonArray) throws JSONException {
    WritableArray writableArray = Arguments.createArray();
    for (int i = 0; i < jsonArray.length(); i++) {
      Object value = jsonArray.get(i);
      if (value instanceof Float || value instanceof Double) {
        writableArray.pushDouble(jsonArray.getDouble(i));
      } else if (value instanceof Number) {
        writableArray.pushInt(jsonArray.getInt(i));
      } else if (value instanceof String) {
        writableArray.pushString(jsonArray.getString(i));
      } else if (value instanceof JSONObject) {
        writableArray.pushMap(jsonToReact(jsonArray.getJSONObject(i)));
      } else if (value instanceof JSONArray) {
        writableArray.pushArray(jsonToReact(jsonArray.getJSONArray(i)));
      } else if (value == JSONObject.NULL) {
        writableArray.pushNull();
      }
    }
    return writableArray;
  }

  private static String ucFirstLetter(String in) {
    return Character.toUpperCase(in.charAt(0)) + in.substring(1);
  }

  private static WritableMap toReact(Object o) throws JSONException {
    if(o instanceof List) {
      throw new JSONException("Expected non-list object! Use toReactArray instead!");
    }
    return jsonToReact(new JSONObject(gson.toJson(o)));
  }

  private static WritableArray toReactArray(List list) throws JSONException {
    return jsonToReact(new JSONArray(gson.toJson(list)));
  }

  @Override public String getName() {
    return "RNBazaarVoice";
  }

  @ReactMethod public void getUserSubmittedReviews(String authorId, int limit,
      final Promise promise) {
       AuthorsRequest request = new AuthorsRequest.Builder(authorId)
        .addIncludeStatistics(AuthorIncludeType.REVIEWS)
        .addIncludeContent(AuthorIncludeType.REVIEWS, limit).build();
    client.prepareCall(request).loadAsync(new ConversationsCallback<AuthorsResponse>() {
      @Override public void onSuccess(AuthorsResponse response) {
        try {
          Log.w("BVSDK", "onSuccess: " + gson.toJson(response));
          promise.resolve(toReact(response.getResults().get(0)));
        } catch (JSONException e) {
          promise.reject(e);
        }
      }

      @Override public void onFailure(BazaarException exception) {
        promise.reject(exception);
      }
    });
  }

  @ReactMethod public void getProductReviewsWithId(
      String productId, int limit, int offset, final Promise promise) {
    ReviewsRequest reviewsRequest = new ReviewsRequest.Builder(productId, limit, offset).build();
    client.prepareCall(reviewsRequest).loadAsync(new ConversationsCallback<ReviewResponse>() {
      @Override public void onSuccess(ReviewResponse response) {
        try {
          promise.resolve(toReact(response.getResults()));
        } catch (JSONException e) {
          promise.reject(e);
        }
      }

      @Override public void onFailure(BazaarException exception) {
        promise.reject(exception);
      }
    });
  }

  @ReactMethod public void submitReview(
      ReadableMap review, String productId, ReadableMap user, final Promise promise) {
    ReviewSubmissionRequest.Builder previewSubmissionBuilder =
        new ReviewSubmissionRequest.Builder(Action.Submit, productId)
            .locale(user.getString("locale"))
            .userNickname(user.getString("userNickname"))
            .user(user.getString("token"))
            .userEmail(user.getString("userEmail"))
            .sendEmailAlertWhenPublished(user.getBoolean("sendEmailAlertWhenPublished"))
            .title(review.getString("title"))
            .reviewText("text")
            .rating(review.getInt("rating"))
            .isRecommended(review.getBoolean("isRecommended"));

    final String[] additionalReviewIntProperties = new String[] {
        "comfort", "size", "rating", "quality", "width"
    };

    for (String addRevKey : additionalReviewIntProperties) {
      previewSubmissionBuilder.addRatingQuestion(ucFirstLetter(addRevKey),
          review.getInt(addRevKey));
    }

    client.prepareCall(previewSubmissionBuilder.build())
        .loadAsync(new ConversationsCallback<ReviewSubmissionResponse>() {
          @Override public void onSuccess(ReviewSubmissionResponse response) {
            try {
              promise.resolve(toReact(response));
            } catch (JSONException e) {
              promise.reject(e);
            }
          }

          @Override public void onFailure(BazaarException exception) {
            promise.reject(exception);
          }
        });
  }
}