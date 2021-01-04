package com.applicaster.plugin.xray.remote;

import org.jetbrains.annotations.NotNull;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.POST;

public interface IRemoteLogAPI {
    @POST("batch")
    Call<Void> batch(@NotNull @Body LogPack batch);
}
