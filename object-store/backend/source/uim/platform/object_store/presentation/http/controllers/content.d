/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Content API — the S3 like data plane:
///
///   PUT     <prefix>/content/<bucket>/<key>            upload (raw body; Content-Type; x-meta-* headers)
///   GET     <prefix>/content/<bucket>/<key>[?version=n] download (ETag, If-None-Match → 304)
///   HEAD    <prefix>/content/<bucket>/<key>            metadata only
///   DELETE  <prefix>/content/<bucket>/<key>            delete (delete marker in versioned buckets)
///   GET     <prefix>/content/<bucket>?prefix=&delimiter=/   list keys
///   OPTIONS <prefix>/content/<bucket>/<key>            CORS preflight (bucket CORS rules)
///
/// <bucket> is a bucket id or name. Callers authenticate with the XSUAA token
/// (behind the approuter) or with service binding credentials:
///   X-Access-Key-Id / X-Secret-Access-Key   or   Authorization: OSK <accessKeyId>:<secret>
/// Binding permissions and the bucket's access policies are enforced.
module uim.platform.object_store.presentation.http.controllers.content;

import vibe.http.router : URLRouter;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
import vibe.http.common : HTTPMethod;
import vibe.stream.operations : readAll;
import vibe.textfilter.urlencode : urlDecode;
import uim.platform.object_store;
import uim.platform.object_store.presentation.resources;
import uim.platform.object_store.presentation.http.controllers.resources : guard, writeJson, writeError;

mixin(ShowModule!());

@safe:

/// Split "<bucket>/<key…>" (already URL decoded).
string[2] splitContentPath(string path) pure {
  auto p = path.startsWith("/") ? path[1 .. $] : path;
  auto slash = p.indexOf('/');
  return slash < 0 ? [p, ""] : [p[0 .. slash], p[slash + 1 .. $]];
}

class ObjectStoreContentController {
  protected ResourceRegistry registry;
  protected string defaultTenant;
  protected string base;
  protected long maxObjectSize;

  this(ResourceRegistry registry, string defaultTenant, string prefix, long maxObjectSize) {
    this.registry = registry;
    this.defaultTenant = defaultTenant;
    this.base = prefix ~ "/content";
    this.maxObjectSize = maxObjectSize;
  }

  void registerRoutes(URLRouter router) {
    router.any(base ~ "/*", &handle);
  }

  void handle(HTTPServerRequest req, HTTPServerResponse res) {
    guard(res, () {
      auto parts = splitContentPath(urlDecode(req.requestPath.toString[base.length .. $]));
      auto bucket = parts[0], key = parts[1];
      if (bucket.length == 0)
        throw new ResourceError(400, "MissingParameter", "The bucket is missing in the path");
      auto caller = callerOf(req);

      if (req.method == HTTPMethod.OPTIONS)
        return preflight(req, res, caller, bucket);
      applyCors(req, res, caller, bucket);

      if (key.length == 0) {
        if (req.method != HTTPMethod.GET && req.method != HTTPMethod.HEAD)
          throw new ResourceError(405, "MethodNotAllowed", "Only GET lists a bucket");
        return writeJson(res, 200, registry.listContent(caller, bucket, req.query.get("prefix", ""),
          req.query.get("delimiter", "")));
      }

      switch (req.method) {
      case HTTPMethod.PUT:
        const(ubyte)[] data;
        try
          data = (() @trusted => req.bodyReader.readAll(cast(size_t) maxObjectSize + 1))();
        catch (Exception e)
          throw new ResourceError(413, "PayloadTooLarge", "Objects are limited to " ~ maxObjectSize.to!string ~ " bytes");
        if (data.length > maxObjectSize)
          throw new ResourceError(413, "PayloadTooLarge", "Objects are limited to " ~ maxObjectSize.to!string ~ " bytes");
        auto row = registry.putContent(caller, bucket, key, data, req.headers.get("Content-Type", ""), metadataOf(req));
        res.headers["ETag"] = `"` ~ fieldString(row, "etag") ~ `"`;
        res.headers["X-Version-Number"] = fieldString(row, "currentVersion");
        return writeJson(res, 200, row);

      case HTTPMethod.GET, HTTPMethod.HEAD:
        int versionNumber;
        auto v = req.query.get("version", "");
        if (v.length > 0) {
          try
            versionNumber = v.to!int;
          catch (Exception)
            throw new ResourceError(400, "InvalidParameter", "version must be a number");
        }
        auto content = registry.getContent(caller, bucket, key, versionNumber);
        auto etag = `"` ~ content.version_.etag ~ `"`;
        res.headers["ETag"] = etag;
        res.headers["X-Version-Number"] = content.version_.versionNumber.to!string;
        res.headers["X-Storage-Class"] = enumText(content.object.storageClass);
        res.headers["Last-Modified"] = httpDate(content.version_.createdAt);
        foreach (m; content.object.metadata)
          res.headers["X-Meta-" ~ m.key] = m.value;
        if (req.headers.get("If-None-Match", "") == etag) {
          res.statusCode = 304;
          res.writeVoidBody();
          return;
        }
        auto type = content.version_.contentType.length > 0 ? content.version_.contentType : "application/octet-stream";
        if (req.query.get("download", "") == "true")
          res.headers["Content-Disposition"] = `attachment; filename="` ~ fileNameOf(key) ~ `"`;
        res.writeBody(content.data, type);
        return;

      case HTTPMethod.DELETE:
        return writeJson(res, 200, registry.deleteContent(caller, bucket, key));

      default:
        throw new ResourceError(405, "MethodNotAllowed", "Method not allowed on object content");
      }
    });
  }

  // ── CORS ───────────────────────────────────────────────────────────────

  protected void preflight(HTTPServerRequest req, HTTPServerResponse res, DataPlaneCaller caller, string bucket) {
    auto body = Json.emptyObject
      .set("bucketId", bucket)
      .set("origin", req.headers.get("Origin", ""))
      .set("method", req.headers.get("Access-Control-Request-Method", "GET"));
    auto headers = req.headers.get("Access-Control-Request-Headers", "");
    body["requestHeaders"] = headers;
    auto d = registry.checkCors(caller.identity.tenantId, body);
    if (!fieldBool(d, "allowed"))
      throw new ResourceError(403, "CorsDenied", fieldString(d, "reason"));
    res.headers["Access-Control-Allow-Origin"] = fieldString(d, "allowOrigin");
    res.headers["Access-Control-Allow-Methods"] = fieldStrings(d, "allowMethods").join(", ");
    if (headers.length > 0)
      res.headers["Access-Control-Allow-Headers"] = fieldStrings(d, "allowHeaders").canFind("*") ? headers
        : fieldStrings(d, "allowHeaders").join(", ");
    res.headers["Access-Control-Max-Age"] = fieldString(d, "maxAgeSeconds");
    res.headers["Vary"] = "Origin";
    res.statusCode = 204;
    res.writeVoidBody();
  }

  /// Add CORS response headers to a simple / actual request from a browser.
  protected void applyCors(HTTPServerRequest req, HTTPServerResponse res, DataPlaneCaller caller, string bucket) {
    auto origin = req.headers.get("Origin", "");
    if (origin.length == 0)
      return;
    auto method = enumText(parseEnum!CorsMethod(req.method.to!string, CorsMethod.get));
    try {
      auto d = registry.checkCors(caller.identity.tenantId, Json.emptyObject.set("bucketId", bucket)
          .set("origin", origin).set("method", method));
      if (!fieldBool(d, "allowed"))
        return;
      res.headers["Access-Control-Allow-Origin"] = fieldString(d, "allowOrigin");
      auto expose = fieldStrings(d, "exposeHeaders");
      if (expose.length > 0)
        res.headers["Access-Control-Expose-Headers"] = expose.join(", ");
      res.headers["Vary"] = "Origin";
    } catch (ResourceError) {
      // unknown bucket: the request itself reports it
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────

  protected DataPlaneCaller callerOf(HTTPServerRequest req) {
    DataPlaneCaller c;
    auto authorization = req.headers.get("Authorization", "");
    c.identity = resolveIdentity(authorization.startsWith("Bearer ") ? authorization : "",
      req.headers.get("X-Tenant-Id", ""), req.headers.get("X-User-Id", ""), defaultTenant);
    c.accessKeyId = req.headers.get("X-Access-Key-Id", "");
    c.secretAccessKey = req.headers.get("X-Secret-Access-Key", "");
    if (authorization.startsWith("OSK ")) {
      auto pair = authorization[4 .. $].strip;
      auto colon = pair.indexOf(':');
      if (colon > 0) {
        c.accessKeyId = pair[0 .. colon];
        c.secretAccessKey = pair[colon + 1 .. $];
      }
    }
    return c;
  }

  protected static MetadataEntry[] metadataOf(HTTPServerRequest req) {
    MetadataEntry[] entries;
    foreach (k, v; req.headers.byKeyValue)
      if (k.length > 7 && k[0 .. 7].toLower == "x-meta-")
        entries ~= MetadataEntry(k[7 .. $].toLower, v);
    return entries;
  }

  protected static string fileNameOf(string key) {
    auto slash = key.lastIndexOf('/');
    return (slash < 0 ? key : key[slash + 1 .. $]).replace(`"`, "");
  }
}

/// std time → RFC 7231 date ("Wed, 18 Nov 2026 10:00:00 GMT").
string httpDate(long stdTime) {
  import std.datetime.systime : SysTime;
  import std.datetime.timezone : UTC;
  import vibe.inet.message : toRFC822DateTimeString;

  if (stdTime <= 0)
    return "";
  return toRFC822DateTimeString(SysTime(stdTime, UTC()));
}

///
unittest {
  assert(splitContentPath("/photos/2026/cat.jpg") == ["photos", "2026/cat.jpg"]);
  assert(splitContentPath("photos") == ["photos", ""]);
  assert(splitContentPath("/photos/") == ["photos", ""]);
  assert(httpDate(parseIsoTime("2026-11-18T10:00:00Z")).canFind("18 Nov 2026 10:00:00"));
}
