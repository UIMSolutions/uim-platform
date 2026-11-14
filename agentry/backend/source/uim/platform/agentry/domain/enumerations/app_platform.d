/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.domain.enumerations.app_platform;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// Mobile application target platform
enum AppPlatform {
    // Native iOS application, built using Swift or Objective-C and running on Apple devices
    ios,
    // Native Android application, built using Java or Kotlin and running on a wide range of devices from various manufacturers
    android,
    // Native Windows application, built using C# or C++ and running on Microsoft devices
    windows,
    // Web application, built using HTML, CSS, and JavaScript and accessible through a web browser on any device
    web,
    // Cross-platform application, built using frameworks like React Native, Flutter, or Xamarin that allow for a single codebase to be deployed across multiple platforms, providing a consistent user experience regardless of the underlying operating system or device
    cross
}

AppPlatform toAppPlatform(string value) {
    mixin(EnumSwitch("AppPlatform", "cross"));
}

AppPlatform[] toAppPlatforms(string[] values) {
    return values.map!toAppPlatform.array;
}

string toString(AppPlatform value) {
    return value.to!string; // This will return the enum member name as a string, e.g. "ios", "android", etc
}

string[] toString(AppPlatform[] values) {
    return values.map!toString.array;
}
///
unittest {
    assert("ios".toAppPlatform == AppPlatform.ios);
    assert("Android".toAppPlatform == AppPlatform.android);
    assert("WINDOWS".toAppPlatform == AppPlatform.windows);
    assert("web".toAppPlatform == AppPlatform.web);
    assert("cross".toAppPlatform == AppPlatform.cross);

    assert("".toAppPlatform == AppPlatform.cross);
    assert("unknown".toAppPlatform == AppPlatform.cross);

    assert(AppPlatform.ios.toString == "ios");
    assert(AppPlatform.android.toString == "android");
    assert(AppPlatform.windows.toString == "windows");
    assert(AppPlatform.web.toString == "web");
    assert(AppPlatform.cross.toString == "cross");

    assert(["ios", "android", "windows", "web", "cross"].toAppPlatforms ==
            [        AppPlatform.ios, AppPlatform.android, AppPlatform.windows,
                AppPlatform.web, AppPlatform.cross
            ]);
    assert([AppPlatform.ios, AppPlatform.android, AppPlatform.windows,
        AppPlatform.web, AppPlatform.cross
    ].toString ==
        ["ios", "android", "windows", "web", "cross"]);
}
