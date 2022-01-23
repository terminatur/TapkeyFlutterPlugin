package com.flutter.plugin.tapkey_flutter_plugin2;

import android.content.Context;
import android.net.Uri;

import com.tapkey.mobile.concurrent.Async;
import com.tapkey.mobile.concurrent.Promise;
import com.tapkey.mobile.concurrent.PromiseSource;

import net.openid.appauth.AuthorizationService;
import net.openid.appauth.AuthorizationServiceConfiguration;
import net.openid.appauth.TokenRequest;

import java.util.HashMap;
import java.util.HashSet;


public class WitteTokenProvider {
    private final static String AuthConfigScheme = "https";
    private final static String AuthConfigAuthority = "login.tapkey.com";

    private final static String TokenExchangeClientId = "wma-native-mobile-app";
    private final static String TokenExchangeGrantType = "http://tapkey.net/oauth/token_exchange";

    private final static String TokenExchangeScopeRegisterMobiles = "register:mobiles";
    private final static String TokenExchangeScopeReadUser = "read:user";
    private final static String TokenExchangeScopeHandleKeys = "handle:keys";

    private final static String TokenExchangeParamProviderKey = "provider";
    private final static String TokenExchangeParamSubjectTokenTypeKey = "subject_token_type";
    private final static String TokenExchangeParamSubjectTokenKey = "subject_token";
    private final static String TokenExchangeParamAudienceKey = "audience";
    private final static String TokenExchangeParamRequestedTokenTypeKey = "requested_token_type";

    private final static String TokenExchangeParamProviderValue = "wma.oauth";
    private final static String TokenExchangeParamSubjectTokenTypeValue = "jwt";
    private final static String TokenExchangeParamAudienceValue = "tapkey_api";
    private final static String TokenExchangeParamRequestedTokenTypeValue = "access_token";

    private final Context _context;

    public WitteTokenProvider(Context context) {
        _context = context;
    }

    public Promise<String> AccessToken(String idToken) {
        System.out.println("Calling TokenProvider->AccessToken");

        PromiseSource<String> promiseSource = new PromiseSource<>();

        Uri.Builder builder = new Uri.Builder();
        Uri authorizationServer = builder
                .scheme(AuthConfigScheme)
                .encodedAuthority(AuthConfigAuthority)
                .build();

        AuthorizationServiceConfiguration.fetchFromIssuer(authorizationServer, (serviceConfiguration, ex) -> {
            if(null != ex) {
                promiseSource.setException(ex);
            }
            else {
                TokenRequest.Builder tokenRequestBuilder =
                        new TokenRequest.Builder(serviceConfiguration, TokenExchangeClientId)
                                .setCodeVerifier(null)
                                .setGrantType(TokenExchangeGrantType)
                                .setScopes(new HashSet<String>() {{
                                    add(TokenExchangeScopeRegisterMobiles);
                                    add(TokenExchangeScopeReadUser);
                                    add(TokenExchangeScopeHandleKeys);
                                }})
                                .setAdditionalParameters(new HashMap<String, String>() {{
                                    put(TokenExchangeParamProviderKey, TokenExchangeParamProviderValue);
                                    put(TokenExchangeParamSubjectTokenTypeKey, TokenExchangeParamSubjectTokenTypeValue);
                                    put(TokenExchangeParamSubjectTokenKey, idToken);
                                    put(TokenExchangeParamAudienceKey, TokenExchangeParamAudienceValue);
                                    put(TokenExchangeParamRequestedTokenTypeKey, TokenExchangeParamRequestedTokenTypeValue);
                                }});

                TokenRequest tokenRequest = tokenRequestBuilder.build();

                AuthorizationService authService = new AuthorizationService(_context);
                authService.performTokenRequest(tokenRequest, (response, ex1) -> {
                    if(null != ex1) {
                        promiseSource.setException(ex1);
                    }
                    else {
                        promiseSource.setResult(response.accessToken);
                    }
                });
            }
        });

        return promiseSource.getPromise();
    }
}
