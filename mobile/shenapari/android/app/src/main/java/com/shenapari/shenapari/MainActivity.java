package com.shenapari.shenapari;

import io.flutter.embedding.android.FlutterActivity;

// Java, not Kotlin: with AGP 9 and android.builtInKotlin=false (still needed
// by the Firebase plugins) the app module's Kotlin output was not packaged,
// so MainActivity was missing from the APK (ClassNotFoundException on start).
public class MainActivity extends FlutterActivity {}
