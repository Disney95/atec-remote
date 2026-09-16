package com.atecremote.app

import android.content.Context
import android.hardware.ConsumerIrManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val CHANNEL = "atec_remote/ir"

class MainActivity : FlutterActivity() {

    private var irManager: ConsumerIrManager? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasIrEmitter" -> {
                    val hasEmitter = irManager?.hasIrEmitter() ?: false
                    result.success(hasEmitter)
                }
                "transmit" -> {
                    val manager = irManager
                    if (manager == null || !manager.hasIrEmitter()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    try {
                        val frequency = (call.argument<Int>("frequency")) ?: 38000
                        @Suppress("UNCHECKED_CAST")
                        val patternList = call.argument<List<Int>>("pattern") ?: emptyList()
                        val pattern = patternList.toIntArray()
                        manager.transmit(frequency, pattern)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("IR_TRANSMIT_ERROR", e.message, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
