package com.flutter.plugin.tapkey_flutter_plugin2;

import android.app.Application;
import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tapkey.mobile.TapkeyEnvironmentConfig;
import com.tapkey.mobile.TapkeyEnvironmentConfigBuilder;
import com.tapkey.mobile.TapkeyServiceFactory;
import com.tapkey.mobile.TapkeyServiceFactoryBuilder;
import com.tapkey.mobile.ble.BleLockCommunicator;
import com.tapkey.mobile.ble.BleLockScanner;
import com.tapkey.mobile.broadcast.PollingScheduler;
import com.tapkey.mobile.concurrent.Async;
import com.tapkey.mobile.concurrent.CancellationToken;
import com.tapkey.mobile.concurrent.CancellationTokens;
import com.tapkey.mobile.concurrent.Promise;
import com.tapkey.mobile.concurrent.PromiseSource;
import com.tapkey.mobile.manager.CommandExecutionFacade;
import com.tapkey.mobile.manager.KeyManager;
import com.tapkey.mobile.manager.NotificationManager;
import com.tapkey.mobile.manager.UserManager;
import com.tapkey.mobile.model.BleLock;
import com.tapkey.mobile.model.CommandResult;
import com.tapkey.mobile.utils.ObserverRegistration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** TapkeyFlutterPlugin2Plugin */
public class TapkeyFlutterPlugin2Plugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context applicationContext = null;
  private TapkeyServiceFactory tapkeyServiceFactory = null;
  private ObserverRegistration bleScanObserverRegistration = null;

  private KeyManager keyManager() { return tapkeyServiceFactory.getKeyManager(); }
  private CommandExecutionFacade commandExecutionFacade() { return tapkeyServiceFactory.getCommandExecutionFacade(); }
  private UserManager userManager() { return tapkeyServiceFactory.getUserManager(); }
  private BleLockScanner bleLockScanner() { return tapkeyServiceFactory.getBleLockScanner(); }
  private BleLockCommunicator bleLockCommunicator() { return tapkeyServiceFactory.getBleLockCommunicator(); }
  private NotificationManager notificationManager() { return tapkeyServiceFactory.getNotificationManager(); }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tapkey_flutter_plugin2");
    channel.setMethodCallHandler(this);

    this.applicationContext = flutterPluginBinding.getApplicationContext();

    initializeTapKey();
  }

  /**
   * Method: login - logs into Tapkey through the flinkey tenant
   * Method: triggerLock - unlocks a specific lock
   * Method: getLocks - scans for locks
   * Method: logout - logout of Tapkey
   * Method: refreshKeys - refresh the keys for the user
   *
   * @param call
   * @param result
   */
  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    switch (call.method) {
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "login":
        handleLoginMethodCall(call, result);
        break;
      case "startForegroundScan":
        handleStartForegroundScanMethodCall(call, result);
        break;
      case "stopForegroundScan":
        handleStopForegroundScanMethodCall(call, result);
        break;
      case "isLockNearby":
        handleIsLockNearbyMethodCall(call, result);
        break;
      case "triggerLock":
        handleTriggerLockMethodCall(call, result);
        break;
      case "logout":
        handleLogoutMethodCall(call, result);
        break;
      case "refreshKeys":
        handleRefreshKeysMethodCall(call, result);
        break;
      case "getLocks":
        handleGetLocksMethodCall(call, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void initializeTapKey() {
    System.out.println("Initializing tapkey");

    /**
     * The tenant id used with the Tapkey backend.
     */
    String TenantId = "wma";

    /**
     * The id token type used to authenticate with the Tapkey backend.
     */
    String IpId = "wma.oauth";

    /**
     * The Bluetooth LE service UUID of a flinkey box.
     */
    String BleServiceUuid = "6e65742e-7470-6ba0-0000-060601810057";


    TapkeyEnvironmentConfig tapkeyEnvironmentConfig = new TapkeyEnvironmentConfigBuilder(this.applicationContext)
            .setBleServiceUuid(BleServiceUuid)
            .setTenantId(TenantId)
            .build();

    TapkeyServiceFactoryBuilder tapkeyServiceFactoryBuilder = new TapkeyServiceFactoryBuilder((Application) this.applicationContext)
            .setConfig(tapkeyEnvironmentConfig)
            .setTokenRefreshHandler(new WitteTokenRefreshHandler(new WitteTokenProvider(this.applicationContext),
                    new myIdTokenRefreshHandler())
            );

    this.tapkeyServiceFactory = tapkeyServiceFactoryBuilder.build();

    // TODO: Determine if there is a different way to do this in flutter
    PollingScheduler.register(this.applicationContext, 1, PollingScheduler.DEFAULT_INTERVAL);

    this.bleLockScanner().getLocksChangedObservable()
            .addObserver(locks -> {
              System.out.println("locks changed observable call. | locks size: " + locks.size());

              locks.forEach((id, lock) -> {
                System.out.println("BleLock key: " + id);
                System.out.println("BleLock bluetooth address: " + lock.getBluetoothAddress());
              });

              onLocksChanged(locks);
            });
  }

  private Promise handleLoginMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    WitteTokenProvider witteTokenProvider = new WitteTokenProvider(this.applicationContext);

    new myIdTokenRefreshHandler().getIdToken()
            .continueOnUi(idToken -> {
              System.out.println("HandleLoginMethod got idToken: " + idToken);

              witteTokenProvider.AccessToken(idToken)
                      .continueOnUi(accessToken -> {
                        System.out.println("HandleLoginMethod got access token: " + accessToken);

                        if (null != accessToken && accessToken != "") {
                        // login with access token
                          userManager().logInAsync(accessToken, CancellationTokens.None)
                                .continueOnUi(userId -> {
                                  System.out.println("Got UserId: " + userId);

                                  result.success(userId);
                                  return null;
                                })
                                .catchAsyncOnUi(e -> {
                                  System.out.println("Caught exception asyncOnUi");
                                  result.error("LoginMethod", e.getMessage(), e);
                                  return null;
                                })
                                .catchOnUi(e -> {
                                  System.out.println("Caught exception onUi");
                                  e.printStackTrace();
                                  result.error("LoginMethod", e.getMessage(), e);
                                  return null;
                                });
                        }
                        return null;
                      });
              return null;
            });

//    witteTokenProvider.AccessToken()
//            .continueOnUi(accessToken -> {
//              System.out.println("Retrieved Access token: " + accessToken);
//
//              if (null != accessToken && accessToken != "") {
//                // login with access token
//                userManager().logInAsync(accessToken, CancellationTokens.None)
//                        .continueOnUi(userId -> {
//                          System.out.println("Got UserId: " + userId);
//
//                          result.success(userId);
//                          return null;
//                        })
//                        .catchAsyncOnUi(e -> {
//                          System.out.println("Caught exception asyncOnUi");
//                          result.error("LoginMethod", e.getMessage(), e);
//                          return null;
//                        })
//                        .catchOnUi(e -> {
//                          System.out.println("Caught exception onUi");
//                          e.printStackTrace();
//                          result.error("LoginMethod", e.getMessage(), e);
//                          return null;
//                        });
//              }
//              return null;
//            })
//            .catchOnUi(e -> {
//              e.printStackTrace();
//              result.error("LoginMethod", e.getMessage(), e);
//              return null;
//            });

    return null;
  }

  private Promise handleRefreshKeysMethodCall(@NonNull MethodCall call, @NonNull Result result) {

    Async.firstAsync(() -> notificationManager().pollForNotificationsAsync(CancellationTokens.None))
            .continueOnUi(c -> {
              result.success(null);
              return null;
            })
            .catchOnUi(e -> {
              Log.e("TapkeyFultterPlugin2", "Failed to poll for notifications.", e);
              return null;
            }).conclude();

    return null;
  }

  private void handleLogoutMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (!userManager().getUsers().isEmpty()) {
      String userId = userManager().getUsers().get(0);

      Async.firstAsync(() ->
              userManager().logOutAsync(userId, CancellationTokens.None)
      ).continueOnUi(r -> {
        result.success(null);
        return null;
      })
        .catchOnUi(e -> {
        Log.e("Tapkey::Logout", "Could not log out user: " + userId, e);
        return null;
      }).conclude();
    }

    result.success(null);
  }

  private void handleStartForegroundScanMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (this.bleScanObserverRegistration == null) {
      this.bleScanObserverRegistration = bleLockScanner().startForegroundScan();
    }

    result.success(null);
  }

  private void handleStopForegroundScanMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (this.bleScanObserverRegistration != null) {
      this.bleScanObserverRegistration.close();
      this.bleScanObserverRegistration = null;
    }

    result.success(null);
  }

  private void handleIsLockNearbyMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, Object> arguments = call.arguments();

    String lockId = (String)arguments.get("lockId");

    System.out.println("is lock nearby | lockId: " + lockId);

    String physicalLockId = BoxIdConverter.toPhysicalLockId(lockId);

    boolean isLockNearby = bleLockScanner().isLockNearby(physicalLockId);

    System.out.println("is lock nearby | isNearby: " + isLockNearby);

    result.success(isLockNearby);
  }

  private void handleTriggerLockMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, Object> arguments = call.arguments();

    String lockId = (String)arguments.get("lockId");

    System.out.println("Lock/Box Id: " + lockId);

    String userId = userManager().getUsers().get(0);

    System.out.println("Unlock user id: " + userId);

//    String boxId = BoxIdConverter.toBoxId(lockId);
    String physicalLockId = BoxIdConverter.toPhysicalLockId(lockId);

    System.out.println("PhysicalLockId: " + physicalLockId);

    BleLock lock = bleLockScanner().getLock(physicalLockId);
    if (lock == null) {
      System.out.println("BleLock is not found");
    }


    Map<String, BleLock> locksMap = bleLockScanner().getLocks();
    System.out.println("Size of locksMap: " + locksMap.size());

//    String bluetoothAddress = lock.getBluetoothAddress();
    String bluetoothAddress = "E0:F2:1C:BE:4D:96";
    System.out.println("Bluethooth address: " + bluetoothAddress);

    String TAG = "Opening box";
    final int timeoutInMs = 60 * 1000;
    CancellationToken timeout = CancellationTokens.fromTimeout(timeoutInMs);


    bleLockCommunicator().executeCommandAsync(bluetoothAddress, physicalLockId, tlcpConnection -> commandExecutionFacade().triggerLockAsync(tlcpConnection, timeout), timeout)
            .continueOnUi(commandResult -> {
              boolean success = false;

              // The CommandResultCode indicates if triggerLockAsync completed successfully
              // or if an error occurred during the execution of the command.
              // https://developers.tapkey.io/mobile/android/reference/Tapkey.MobileLib/latest/com/tapkey/mobile/model/CommandResult.CommandResultCode.html
              CommandResult.CommandResultCode commandResultCode = commandResult.getCommandResultCode();
              switch (commandResultCode) {
                case Ok: {
                  success = true;

                  // get the 10 byte box feedback from the command result
                  Object object = commandResult.getResponseData();
                  if (object instanceof byte[]) {

                    byte[] responseData = (byte[]) object;
                    try {
                      BoxFeedback boxFeedback = BoxFeedback.create(responseData);
                      int boxState = boxFeedback.getBoxState();
                      if (BoxState.UNLOCKED == boxState) {

                        Log.d(TAG, "Box has been opened");
                      } else if (BoxState.LOCKED == boxState) {

                        Log.d(TAG, "Box has been closed");
                      } else if (BoxState.DRAWER_OPEN == boxState) {

                        Log.d(TAG, "The drawer of the Box is open.");
                      }
                    } catch (IllegalArgumentException iaEx) {
                      Log.e(TAG, iaEx.getMessage());
                    }
                  }
                  break;
                }
                case LockCommunicationError:
                {
                  Log.e(TAG, "A transport-level error occurred when communicating with the locking device");
                  break;
                }
                case LockDateTimeInvalid:
                {
                  Log.e(TAG, "Lock date/time are invalid.");
                  break;
                }
                case ServerCommunicationError:
                {
                  Log.e(TAG, "An error occurred while trying to communicate with the Tapkey Trust Service (e.g. due to bad internet connection).");
                  break;
                }
                case TechnicalError:
                {
                  Log.e(TAG, "Some unspecific technical error has occurred.");
                  break;
                }
                case Unauthorized:
                {
                  Log.e(TAG, "Communication with the security backend succeeded but the user is not authorized for the given command on this locking device.");
                  break;
                }
                case UserSpecificError: {
                  // If there is a UserSpecificError we need to have look at the list
                  // of UserCommandResults in order to determine what exactly caused the error
                  // https://developers.tapkey.io/mobile/android/reference/Tapkey.MobileLib/latest/com/tapkey/mobile/model/CommandResult.UserCommandResult.html
                  List<CommandResult.UserCommandResult> userCommandResults = commandResult.getUserCommandResults();
                  for (CommandResult.UserCommandResult ucr : userCommandResults) {
                    Log.e(TAG, "triggerLockAsync failed with UserSpecificError and UserCommandResultCode " + ucr.getUserCommandResultCode());
                  }
                  break;
                }
                default: {
                  break;
                }
              }

              if(success) {
                Toast.makeText(this.applicationContext, "triggerLock successful", Toast.LENGTH_SHORT).show();
              }
              else {
                Toast.makeText(this.applicationContext, "triggerLock error", Toast.LENGTH_SHORT).show();
              }

              return success;
            })
            .catchOnUi(e -> {
              Toast.makeText(this.applicationContext, "triggerLock exception", Toast.LENGTH_SHORT).show();
              return false;
            });
  }

  private void handleGetLocksMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Map<String, BleLock> nearbyLocks = bleLockScanner().getLocks();

    List<Map<String, Object>> nearbyLocksList = bleLockMapToList(nearbyLocks);

    System.out.println("GetLocks");
    System.out.println("Number of locks found: " + nearbyLocks.size());

    result.success(nearbyLocksList);
  }

  private List<Map<String, Object>> bleLockMapToList(Map<String, BleLock> locks) {
    List<Map<String, Object>> locksList = new ArrayList<>();

    locks.forEach((id, lock) -> {
      Map<String, Object> lockMap = bleLockToMap(lock);
      locksList.add(lockMap);
    });

    return locksList;
  }

  private Map<String, Object> bleLockToMap(BleLock lock) {
    Map<String, Object> map = new HashMap<String, Object>();

    map.put("bluetoothAddress", lock.getBluetoothAddress());
    map.put("incompleteLockId", lock.getIncompleteLockId());
    map.put("lastSeen", lock.getLastSeen().getTime());
    map.put("rssi", lock.getRssi());
    map.put("isLockIdComplete", lock.isLockIdComplete());

    return map;
  }


  class myIdTokenRefreshHandler implements IdTokenRefreshHandler {
    @Override
    public Promise<String> getIdToken() {
      PromiseSource<String> promiseSource = new PromiseSource<>();

      channel.invokeMethod("getIdToken", null, new Result() {
        @Override
        public void success(@Nullable Object result) {
          String idToken = (String) result;

          promiseSource.setResult(idToken);
        }

        @Override
        public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
          promiseSource.setException((Exception)errorDetails);
        }

        @Override
        public void notImplemented() {}
      });

      return promiseSource.getPromise();
    }
  }

  private void onLocksChanged(Map<String, BleLock> locks) {
    List<Map<String, Object>> locksList = bleLockMapToList(locks);

    channel.invokeMethod("onLocksChanged", locksList);
  }
}
