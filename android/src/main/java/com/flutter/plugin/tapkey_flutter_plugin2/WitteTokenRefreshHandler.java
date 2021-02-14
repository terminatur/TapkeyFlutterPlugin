package com.flutter.plugin.tapkey_flutter_plugin2;

import com.tapkey.mobile.auth.TokenRefreshHandler;
import com.tapkey.mobile.concurrent.CancellationToken;
import com.tapkey.mobile.concurrent.Promise;
import com.tapkey.mobile.concurrent.PromiseSource;

public class WitteTokenRefreshHandler implements TokenRefreshHandler {

    private final WitteTokenProvider _witteTokenProvider;
    private final IdTokenRefreshHandler _idTokenRefreshHandler;

    public WitteTokenRefreshHandler(WitteTokenProvider witteTokenProvider,
                                    IdTokenRefreshHandler idTokenRefreshHandler) {
        _witteTokenProvider = witteTokenProvider;
        _idTokenRefreshHandler = idTokenRefreshHandler;
    }

    @Override
    public Promise<String> refreshAuthenticationAsync(String tapkeyUserId, CancellationToken cancellationToken) {
        PromiseSource<String> promiseSource = new PromiseSource<String>();

        _idTokenRefreshHandler.getIdToken()
                .continueOnUi(idToken -> {
                    return _witteTokenProvider.AccessToken(idToken)
                            .continueOnUi(accessToken -> {
                                promiseSource.setResult(accessToken);
                                return accessToken;
                            });
                });

        return promiseSource.getPromise();
    }

    @Override
    public void onRefreshFailed(String tapkeyUserId) {
        // At this point you should logout the user from the app as the token refresh is permanently
        // broken and the TapkeyMobileLib is no longer able to communicate with the Tapkey backend.
        // https://developers.tapkey.io/mobile/android/reference/Tapkey.MobileLib/latest/com/tapkey/mobile/auth/TokenRefreshHandler.html#onRefreshFailed-java.lang.String-
    }
}

