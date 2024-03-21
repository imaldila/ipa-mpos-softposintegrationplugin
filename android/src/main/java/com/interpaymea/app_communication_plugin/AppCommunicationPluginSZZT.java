package com.interpaymea.app_communication_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * AppCommunicationPlugin
 */
public class AppCommunicationPluginSZZT
        implements
        MethodCallHandler {

    /// The MethodChannel that will the communication between Flutter and native
    /// Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine
    /// and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private MethodChannel channelSZZT;

    private Context context;
    private Activity activity;

    private static Result resultToFlutter;

    private int OPEN_SOFTPOS_RTESULT_CODE = 202;
    private static int OPEN_SOFTPOS_SZZT_RTESULT_CODE = 203;

    private static final String TAG = "AppCommunicationPluginSZZT";

    public AppCommunicationPluginSZZT(Context context, Activity activity) {
        this.context = context;
        this.activity = activity;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        Log.e(TAG, "onMethodCall");
        AppCommunicationPluginSZZT.resultToFlutter = result;
        if (call.method.equals("getDataReceivedInSoftpos")) {
            HashMap hashMap = getDataReceivedInSoftpos();
            if (hashMap != null) {
                result.success(hashMap);
            } else {
                result.success(null);
            }
        } else if (call.method.equals("openSoftposApp")) {
            HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
            openSoftposApp(map);
        } else if (call.method.equals("sendDataBackToSource")) {
            HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
            sendDataBackToSource(map);
        } else if (call.method.equals("throwErrorFromSoftpos")) {
            HashMap<String, Object> map = (HashMap<String, Object>) call.arguments;
            throwErrorFromSoftpos(map);
        } else {
            result.notImplemented();
        }
    }

    private void throwErrorFromSoftpos(HashMap map) {
        Intent intent = new Intent();
        Bundle bundle = new Bundle();
        Iterator it = map.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();

            if (pair.getValue() instanceof Boolean) {
                bundle.putBoolean((String) pair.getKey(), (Boolean) pair.getValue());
            } else if (pair.getValue() instanceof Double) {
                bundle.putDouble((String) pair.getKey(), (Double) pair.getValue());
            } else {
                System.out.println(
                        "Key : " + pair.getKey() + "  value :: " + pair.getValue());
                bundle.putString(pair.getKey().toString(), (String) pair.getValue());
            }

            it.remove(); // avoids a ConcurrentModificationException
        }

        intent.putExtra("data", bundle);

        activity.setResult(Activity.RESULT_CANCELED, intent);
        activity.finish();
    }

    private void sendDataBackToSource(HashMap map) {
        Intent intent = new Intent();
        Bundle bundle = new Bundle();
        if (map == null || map.isEmpty()) {
            intent.putExtra("data", bundle);

            activity.setResult(Activity.RESULT_CANCELED, intent);
            activity.finish();
            return;
        } else {
            Iterator it = map.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry pair = (Map.Entry) it.next();

                if (pair.getValue() instanceof Boolean) {
                    bundle.putBoolean((String) pair.getKey(), (Boolean) pair.getValue());
                } else if (pair.getValue() instanceof Double) {
                    bundle.putDouble((String) pair.getKey(), (Double) pair.getValue());
                } else {
                    System.out.println(
                            "Key : " + pair.getKey() + "  value :: " + pair.getValue());
                    bundle.putString(pair.getKey().toString(), (String) pair.getValue());
                }

                it.remove(); // avoids a ConcurrentModificationException
            }
        }
        intent.putExtra("data", bundle);

        activity.setResult(Activity.RESULT_OK, intent);
        activity.finish();
    }

    private HashMap getDataReceivedInSoftpos() {
        HashMap hashMap = new HashMap();
        Intent intent = activity.getIntent();
        if (intent != null) {
            Bundle bundle = intent.getBundleExtra("data");
            if (bundle != null) {
                for (String key : bundle.keySet()) {
                    hashMap.put(key, bundle.get(key));
                }
            } else {
                return null;
            }
        } else {
            return null;
        }

        return hashMap;
    }

    private void openSoftposApp(HashMap map) {
        Log.e(TAG, "openSoftposApp");
        Intent sendIntent = new Intent();

        PackageManager pm = context.getPackageManager();
        try {
            pm.getPackageInfo("com.interpaymea.softpos.szzt", 0);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(TAG, "404" + " App not installed");
            resultToFlutter.error("404", "App not installed", null);
            return;
        }

        // Need to register your intent filter in App2 in manifest file with same
        // action.
        sendIntent.setClassName(
                "com.interpaymea.softpos.szzt",
                "com.interpaymea.softpos.szzt.screens.splash.SplashActivity");
        Bundle bundle = new Bundle();

        Iterator it = map.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();

            if (pair.getValue() instanceof Boolean) {
                bundle.putBoolean((String) pair.getKey(), (Boolean) pair.getValue());
            } else if (pair.getValue() instanceof Double) {
                Log.i(TAG, "Double key --> " + pair.getKey() + "   value --> " + pair.getValue());
                bundle.putDouble((String) pair.getKey(), (Double) pair.getValue());
            } else {
                Log.i(TAG, "String key --> " + pair.getKey() + "   value --> " + pair.getValue());
                bundle.putString(pair.getKey().toString(), (String) pair.getValue());
            }

            it.remove(); // avoids a ConcurrentModificationException
        }

        sendIntent.putExtra("data", bundle);
        sendIntent.setType("text/plain");
        if (activity != null) {
            if (sendIntent.resolveActivity(activity.getPackageManager()) != null) {
                activity.startActivityForResult(sendIntent, OPEN_SOFTPOS_SZZT_RTESULT_CODE);
            }
        } else {
            Log.e(TAG, "ACtivity is null");
        }
    }

    public static void szztResult(int requestCode, int resultCode, Intent data) {
        Log.i(TAG, "SZZT Resulr handler");
        if (requestCode == OPEN_SOFTPOS_SZZT_RTESULT_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                Bundle bundle = data.getBundleExtra("data");

                HashMap map = new HashMap();

                for (String key : bundle.keySet()) {
                    map.put(key, bundle.get(key));
                }
                resultToFlutter.success(map);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                if(data != null) {
                    Bundle bundle = data.getBundleExtra("data");
                    if (bundle != null && bundle.getString("errorCode") != null) {
                        resultToFlutter.error(
                                bundle.getString("errorCode"),
                                bundle.getString("errorMessage"),
                                bundle.getString("errorDetails"));
                    } else {
                        resultToFlutter.error("400", "User has cancelled the payment.", null);
                    }
                } else {
                    resultToFlutter.error("400", "User has cancelled the payment.", null);
                }

            } else {
                resultToFlutter.error("404", "Unable to get data", null);
            }
        }
    }
}
