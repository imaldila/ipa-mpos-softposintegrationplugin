package com.interpaymea.app_communication_plugin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.plugin.common.PluginRegistry;

/**
 * AppCommunicationPlugin
 */
public class AppCommunicationPlugin
        implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
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

    private Result resultToFlutter;

    private int OPEN_SOFTPOS_RTESULT_CODE = 202;
    private int OPEN_SOFTPOS_SZZT_RTESULT_CODE = 203;

    AppCommunicationPluginSZZT appCommunicationPluginSzzt;

    private static final String TAG = "AppCommunicationPlugin";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.i(TAG, "onAttachedToEngine");
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "app_communication_plugin");
        channel.setMethodCallHandler(this);
        channelSZZT = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "app_communication_plugin_szzt");
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        Log.i(TAG, "onMethodCall");
        this.resultToFlutter = result;
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

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.i(TAG, "onDetachedFromEngine");
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "onAttachedToActivity");
        activity = binding.getActivity();
        channelSZZT
                .setMethodCallHandler(appCommunicationPluginSzzt = new AppCommunicationPluginSZZT(context, activity));
        binding.addActivityResultListener((PluginRegistry.ActivityResultListener) this);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.i(TAG, "onDetachedFromActivityForConfigChanges");
        // Todo("Not yet implemented")
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.i(TAG, "onReattachedToActivityForConfigChanges");
        // Todo("Not yet implemented")
        binding.addActivityResultListener((PluginRegistry.ActivityResultListener) this);
    }

    @Override
    public void onDetachedFromActivity() {
        Log.i(TAG, "onDetachedFromActivity");
        // Todo("Not yet implemented")
    }

    @Override
    public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.i(TAG, "onActivityResult test --> " + requestCode);
        Log.i(TAG, "onActivityResult test --> " + resultCode);
        Log.i(TAG, "onActivityResult test --> " + data);
        if (requestCode == OPEN_SOFTPOS_RTESULT_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                Bundle bundle = data.getBundleExtra("data");

                HashMap map = new HashMap();

                for (String key : bundle.keySet()) {
                    map.put(key, bundle.get(key));

                }
                resultToFlutter.success(map);
            } else if (resultCode == Activity.RESULT_CANCELED) {
                if (data != null) {

                    Bundle bundle = data.getBundleExtra("data");
                    if (bundle != null && bundle.getString("errorCode") != null) {

                        resultToFlutter.error(bundle.getString("errorCode"), bundle.getString("errorMessage"),
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
        } else if (requestCode == OPEN_SOFTPOS_SZZT_RTESULT_CODE) {
            appCommunicationPluginSzzt.szztResult(requestCode, resultCode, data);
            return false;
        }
        return true;
    }

    private void throwErrorFromSoftpos(HashMap map) {
        Log.i(TAG, "throwErrorFromSoftpos");
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
                System.out.println("Key : " + pair.getKey() + "  value :: " + pair.getValue());
                bundle.putString(pair.getKey().toString(), (String) pair.getValue());
            }

            it.remove(); // avoids a ConcurrentModificationException
        }

        intent.putExtra("data", bundle);

        activity.setResult(Activity.RESULT_CANCELED, intent);
        activity.finish();
    }

    private void sendDataBackToSource(HashMap map) {
        Log.i(TAG, "sendDataBackToSource");
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
                    System.out.println("Key : " + pair.getKey() + "  value :: " + pair.getValue());
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
        Log.i(TAG, "getDataReceivedInSoftpos");
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
        Log.i(TAG, "openSoftposApp");
        Intent sendIntent = new Intent();

        PackageManager pm = context.getPackageManager();
        try {
            pm.getPackageInfo("com.interpaymea.softpos", 0);

        } catch (PackageManager.NameNotFoundException e) {
            resultToFlutter.error("404", "App not installed", null);
            return;
        }

        // Need to register your intent filter in App2 in manifest file with same
        // action.
        sendIntent.setClassName("com.interpaymea.softpos", "com.interpaymea.softpos.MainActivity");
        Bundle bundle = new Bundle();

        Iterator it = map.entrySet().iterator();
        while (it.hasNext()) {
            Map.Entry pair = (Map.Entry) it.next();

            if (pair.getValue() instanceof Boolean) {
                bundle.putBoolean((String) pair.getKey(), (Boolean) pair.getValue());
            } else if (pair.getValue() instanceof Double) {
                bundle.putDouble((String) pair.getKey(), (Double) pair.getValue());
            } else {
                bundle.putString(pair.getKey().toString(), (String) pair.getValue());
            }

            it.remove(); // avoids a ConcurrentModificationException
        }

        sendIntent.putExtra("data", bundle);
        sendIntent.setType("text/plain");
        Log.i(TAG, "Activity - " + activity);
        if (sendIntent.resolveActivity(activity.getPackageManager()) != null) {
            activity.startActivityForResult(sendIntent, OPEN_SOFTPOS_RTESULT_CODE);
        }
    }

    public static Map<String, Object> jsonToMap(JSONObject json) throws JSONException {
        Map<String, Object> retMap = new HashMap<String, Object>();

        if (json != JSONObject.NULL) {
            retMap = toMap(json);
        }
        return retMap;
    }

    public static Map<String, Object> toMap(JSONObject object) throws JSONException {
        Map<String, Object> map = new HashMap<String, Object>();

        Iterator<String> keysItr = object.keys();
        while (keysItr.hasNext()) {
            String key = keysItr.next();
            Object value = object.get(key);

            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            map.put(key, value);
        }
        return map;
    }

    public static List<Object> toList(JSONArray array) throws JSONException {
        List<Object> list = new ArrayList<Object>();
        for (int i = 0; i < array.length(); i++) {
            Object value = array.get(i);
            if (value instanceof JSONArray) {
                value = toList((JSONArray) value);
            } else if (value instanceof JSONObject) {
                value = toMap((JSONObject) value);
            }
            list.add(value);
        }
        return list;
    }

}
