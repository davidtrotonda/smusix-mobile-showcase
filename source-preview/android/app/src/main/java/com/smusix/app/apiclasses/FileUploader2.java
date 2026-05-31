package com.smusix.app.apiclasses;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.smusix.app.Constants;
import com.smusix.app.models.UploadVideoModel;
import com.smusix.app.simpleclasses.Functions;

import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import okio.BufferedSink;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class FileUploader2 {

    private FileUploaderCallback mFileUploaderCallback;
    UploadVideoModel uploadModel;

    public FileUploader2(Context context, UploadVideoModel uploadModel) {
        this.uploadModel=uploadModel;

        InterfaceFileUpload interfaceFileUpload = ApiClient.getRetrofitInstance(context).create(InterfaceFileUpload.class);


        Call<Object> fileUpload = interfaceFileUpload.uploadNewFile(uploadModel.getPrivacyPolicy(),
                uploadModel.getUserId(),
                uploadModel.getSoundId(),
                uploadModel.getAllowComments(),
                uploadModel.getDescription(),
                uploadModel.getAllowDuet(),
                uploadModel.getUsersJson(),
                uploadModel.getHashtagsJson(),
                uploadModel.getVideoType(),
                uploadModel.getVideoId(),
                uploadModel.getProduct_id(),
                uploadModel.getLanguageId(),
                uploadModel.getGenreSongId(),
                uploadModel.getArtistFeat(),
                uploadModel.getDigitalPrice(),
                uploadModel.getNftLink(),
                uploadModel.getSchedule(),
                "",
                uploadModel.getVideoUrl(),
                uploadModel.getThumbUrl(),
                uploadModel.getGifUrl(),
                uploadModel.getDuration());


        Log.d(Constants.tag, "************************  before call : " +
                fileUpload.request().url());

        fileUpload.enqueue(new Callback<Object>() {

            @Override
            public void onResponse(@NonNull Call<Object> call,
                                   @NonNull Response<Object> response) {

                String bodyRes=new Gson().toJson(response.body());
                Log.d(Constants.tag,"Responce: "+bodyRes);
                try {
                    JSONObject jsonObject = new JSONObject(bodyRes);
                    int code = jsonObject.optInt("code",0);
                    if (code==200) {
                        mFileUploaderCallback.onFinish(bodyRes);
                    }
                }
                catch (Exception e)
                {
                    Log.d(Constants.tag,"Exception file uploader :"+e);
                    mFileUploaderCallback.onError();
                }


            }
            @Override
            public void onFailure(Call<Object> call, Throwable t) {
                Log.d(Constants.tag,"Exception onFailure file uploader:"+t.toString());
                mFileUploaderCallback.onError();
            }

        });

    }

    public void SetCallBack(FileUploaderCallback fileUploaderCallback) {
        this.mFileUploaderCallback = fileUploaderCallback;
    }

    public interface FileUploaderCallback {

        void onError();

        void onFinish(String responses);
    }

}
