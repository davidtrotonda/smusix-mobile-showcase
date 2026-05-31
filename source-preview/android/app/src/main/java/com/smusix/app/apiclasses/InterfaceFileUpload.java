package com.smusix.app.apiclasses;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okhttp3.ResponseBody;
import retrofit2.Call;
import retrofit2.http.Field;
import retrofit2.http.FormUrlEncoded;
import retrofit2.http.GET;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.Url;


public interface InterfaceFileUpload {

    @Multipart
    @POST(ApiLinks.postVideo)
    Call<Object> UploadFile(@Part MultipartBody.Part file,
                                    @Part("privacy_type") RequestBody PrivacyType,
                                    @Part("user_id") RequestBody UserId,
                                    @Part("sound_id") RequestBody SoundId,
                                    @Part("allow_comments") RequestBody AllowComments,
                                    @Part("description") RequestBody Description,
                                    @Part("allow_duet") RequestBody AllowDuet,
                                    @Part("users_json") RequestBody UsersJson,
                                    @Part("hashtags_json") RequestBody HashtagsJson,
                                    @Part("story") RequestBody story ,
                                    @Part("video_id") RequestBody videoId,
                                    @Part("product_id") RequestBody product_id,
                                     @Part("song_language_id") RequestBody language,
                                     @Part("song_genre_id") RequestBody video_type,
                                     @Part("artist_feat") RequestBody artist_feat,
                                     @Part("digital_song_price") RequestBody digital_price,
                                     @Part("nft_link") RequestBody nft_link,
                                     @Part("schedule") RequestBody schedule,
                                     @Part("video_type") RequestBody video_t);



    @FormUrlEncoded
    @POST(ApiLinks.postVideoNew)
    Call<Object> uploadNewFile(
                            @Field("privacy_type") String PrivacyType,
                            @Field("user_id") String UserId,
                            @Field("sound_id") String SoundId,
                            @Field("allow_comments") String AllowComments,
                            @Field("description") String Description,
                            @Field("allow_duet") String AllowDuet,
                            @Field("users_json") String UsersJson,
                            @Field("hashtags_json") String HashtagsJson,
                            @Field("story") String story ,
                            @Field("video_id") String videoId,
                            @Field("product_id") String product_id,
                            @Field("song_language_id") String language,
                            @Field("song_genre_id") String video_type,
                            @Field("artist_feat") String artist_feat,
                            @Field("digital_song_price") String digital_price,
                            @Field("nft_link") String nft_link,
                            @Field("schedule") String schedule,
                            @Field("video_type") String video_t,
                            @Field("video") String videoUrl,
                            @Field("thum") String videothum,
                            @Field("gif") String videoGif,
                            @Field("video_duration") String duration);


    @Multipart
    @POST(ApiLinks.addUserImage)
    Call<Object> UploadProfileImageVideo(@Part MultipartBody.Part file,
                                    @Part("user_id") RequestBody UserId ,
                                    @Part("extension") RequestBody ExtensionId);


    @GET
    Call<ResponseBody> downloadFile(@Url String fileUrl);
}
