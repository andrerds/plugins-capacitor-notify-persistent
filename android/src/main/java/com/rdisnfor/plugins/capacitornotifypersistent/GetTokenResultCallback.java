package com.rdisnfor.plugins.capacitornotifypersistent;

public interface GetTokenResultCallback {
    void success(String token);
    void error(String message);
}
