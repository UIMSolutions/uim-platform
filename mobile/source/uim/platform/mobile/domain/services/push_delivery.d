/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.services.push_delivery_service;

import uim.platform.mobile.domain.types;

import std.conv : to;

struct PushDeliveryService {
  // Validate push notification payload size
  // APNS: 4KB max, FCM: 4KB max, WNS: 5KB max
  static bool validatePayloadSize(string payload, PushProvider provider) {
    long maxSize;
    final switch (provider) {
    case PushProvider.apns:
      maxSize = 4096;
      break;
    case PushProvider.fcm:
      maxSize = 4096;
      break;
    case PushProvider.wns:
      maxSize = 5120;
      break;
    case PushProvider.w3c:
      maxSize = 4096;
      break;
    }
    return payload.length <= maxSize;
  }

  // Determine provider from platform
  static PushProvider defaultProvider(AppPlatform platform) {
    final switch (platform) {
    case AppPlatform.ios:
      return PushProvider.apns;
    case AppPlatform.android:
      return PushProvider.fcm;
    case AppPlatform.windows:
      return PushProvider.wns;
    case AppPlatform.web:
      return PushProvider.w3c;
    }
  }

  // Check if a push token looks valid (basic validation)
  static bool validatePushToken(string token, PushProvider provider) {
    if (token.length == 0)
      return false;
    final switch (provider) {
    case PushProvider.apns:
      return token.length == 64; // hex-encoded 32-byte token
    case PushProvider.fcm:
      return token.length >= 100; // FCM tokens are long
    case PushProvider.wns:
      return token.length > 10; // WNS channel URI
    case PushProvider.w3c:
      return token.length > 10; // W3C push subscription URL
    }
  }

  // Check if notification has expired
  static bool isExpired(long expiresAt, long currentTime) {
    if (expiresAt == 0)
      return false; // no expiry set
    return currentTime > expiresAt;
  }

  // Generate a simple notification ID
  static string generateNotificationId() {
    import std.uuid : randomUUID;

    return randomUUID().to!string;
  }
}
