/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.html_repository.domain.services.content_delivery_service;

import uim.platform.html_repository.domain.types;

import std.conv : to;
import std.digest.md : md5Of, toHexString;

struct ContentDeliveryService {
  // Generate ETag from content data
  static string generateEtag(string data) {
    auto hash = md5Of(data);
    return hash.toHexString.to!string;
  }

  // Check if cached content is still valid
  static bool isCacheValid(long cachedAt, long ttlSeconds, long currentTime) {
    if (ttlSeconds == 0)
      return true; // no expiry
    return currentTime < (cachedAt + ttlSeconds);
  }

  // Determine file category from MIME content type
  static FileCategory categorizeFile(string contentType) {
    if (contentType.length == 0)
      return FileCategory.other;

    import std.string : indexOf;

    if (contentType.indexOf("text/html") >= 0)
      return FileCategory.html;
    if (contentType.indexOf("text/css") >= 0)
      return FileCategory.css;
    if (contentType.indexOf("javascript") >= 0)
      return FileCategory.javascript;
    if (contentType.indexOf("image/") >= 0)
      return FileCategory.image;
    if (contentType.indexOf("font/") >= 0)
      return FileCategory.font;
    if (contentType.indexOf("application/json") >= 0)
      return FileCategory.json;
    if (contentType.indexOf("application/xml") >= 0 || contentType.indexOf("text/xml") >= 0)
      return FileCategory.xml;
    return FileCategory.other;
  }

  // Guess MIME type from file extension
  static string guessContentType(string filePath) {
    import std.string : lastIndexOf;

    auto dotIdx = lastIndexOf(filePath, '.');
    if (dotIdx < 0)
      return "application/octet-stream";

    auto ext = filePath[dotIdx + 1 .. $];
    switch (ext) {
    case "html":
    case "htm":
      return "text/html";
    case "css":
      return "text/css";
    case "js":
      return "application/javascript";
    case "json":
      return "application/json";
    case "xml":
      return "application/xml";
    case "png":
      return "image/png";
    case "jpg":
    case "jpeg":
      return "image/jpeg";
    case "gif":
      return "image/gif";
    case "svg":
      return "image/svg+xml";
    case "ico":
      return "image/x-icon";
    case "woff":
      return "font/woff";
    case "woff2":
      return "font/woff2";
    case "ttf":
      return "font/ttf";
    case "eot":
      return "application/vnd.ms-fontobject";
    case "map":
      return "application/json";
    case "txt":
      return "text/plain";
    default:
      return "application/octet-stream";
    }
  }

  // Calculate default cache TTL based on file category
  static long defaultTtlSeconds(FileCategory category) {
    final switch (category) {
    case FileCategory.html:
      return 300; // 5 min
    case FileCategory.css:
    case FileCategory.javascript:
      return 86400; // 24 hours
    case FileCategory.image:
    case FileCategory.font:
      return 604800; // 7 days
    case FileCategory.json:
    case FileCategory.xml:
      return 3600; // 1 hour
    case FileCategory.other:
      return 3600;
    }
  }
}
