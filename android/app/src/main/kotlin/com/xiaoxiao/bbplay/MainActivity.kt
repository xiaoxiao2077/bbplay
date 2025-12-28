package com.xiaoxiao.bbplay

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 如果需要注册额外的插件或处理平台通道，可以在这里添加
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}