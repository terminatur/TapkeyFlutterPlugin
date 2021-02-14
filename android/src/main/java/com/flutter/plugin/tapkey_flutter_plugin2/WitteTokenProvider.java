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

//        String idToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkU1QTUxRjZEOUY1NjNGODgzRkVDOUIxREUyM0M4QkJCNzJGM0U2QjgifQ.eyJzdWIiOiIyMDM1YzIzYS1kZTNlLTQ1Y2UtOWYyMi0zYzBmNzlkMGNkNDgiLCJpc3MiOiJodHRwczovL3d3dy53aXR0ZS5kaWdpdGFsIiwiYXVkIjoiZjhiOGJiMTctNTkzYS00NzUwLTliNGUtMmZiMDY5ZDZkMjlhIiwiaWF0IjoxNjEzMDA4OTMyLCJleHAiOjE2MTMwMTI1MzIsImVtYWlsIjoiMjAzNWMyM2EtZGUzZS00NWNlLTlmMjItM2MwZjc5ZDBjZDQ4In0.nE2YKoiA3JgXbxS9lynDz5X5VmRloK0Ihrcp4S5Dq8BeJ-yJYX95k7Z3pJiJV3VyneYk2qsbeRv2EqeSCf7UBSOunVKpQfXWAKauPDDo4T05kZKB5FRwjlWuwTrHGNWm7afOYz9Q14vH4Y6j68UbwKTVDd0rt9mnLRuSlmfvH7zJxivPqr1hBzfaxrCw78CKHg-589c2FqquYXU5_wWKo8M0nkLSFnQloaeLXYazSWOTNDK6kavJue4lnYvkABE2VxLtaZlEI33SayX_y05ngnBsvxmJzYYRAQqvDPLC1nE8SbdrIihDWyffXKl0XszNgFGCm8iFvLH-oPrO3jQdfw";

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
