package vip.hsq168.plugin.fluttersobot.flutter_sobot

import android.app.Application
import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import com.sobot.chat.SobotApi
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import com.sobot.chat.api.model.Information


class FlutterSobotPlugin : MethodCallHandler {

    companion object {
        var conext: Context? = null
        var appKey = ""
        var partnerId = ""
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            conext = registrar.context()
            initSdk()
            val channel = MethodChannel(registrar.messenger(), "flutter_sobot")
            channel.setMethodCallHandler(FlutterSobotPlugin())
        }

        private fun initSdk() {
            var packageManager = conext!!.packageManager
            var appInfo = packageManager.getApplicationInfo(conext!!.packageName, PackageManager.GET_META_DATA)
            if (appInfo.metaData.containsKey("SobotAppkey") && appInfo.metaData.containsKey("SobotPartnerId")) {
                appKey = appInfo.metaData["SobotAppkey"].toString()
                partnerId = appInfo.metaData["SobotPartnerId"].toString()
                SobotApi.initSobotSDK(conext, appKey, partnerId)
            } else {
                Log.d("flutter_sobot", "===========请在AndroidManifest填入SobotAppkey和SobotPartnerId================")
            }

        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when {
            call.method == "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            call.method == "start" -> {
                val info = Information()
                info.appkey = appKey
                SobotApi.startSobotChat(conext, info)
            }
            else -> result.notImplemented()
        }
    }
}
