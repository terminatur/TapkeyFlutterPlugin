package com.flutter.plugin.tapkey_flutter_plugin2;

import com.tapkey.mobile.concurrent.Promise;

public interface IdTokenRefreshHandler {
    Promise<String> getIdToken();
}
