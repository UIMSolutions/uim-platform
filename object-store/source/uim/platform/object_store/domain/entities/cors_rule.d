/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.domain.entities.cors_rule;

// import uim.platform.object_store.domain.types;
import uim.platform.object_store;

mixin(ShowModule!());

@safe:
struct CorsRule {
  mixin TenantEntity!(CorsRuleId);

  BucketId bucketId;
  string allowedOrigins; // JSON array, e.g. '["https://example.com"]'
  string allowedMethods; // JSON array, e.g. '["GET","PUT","POST"]'
  string allowedHeaders; // JSON array, e.g. '["Content-Type","Authorization"]'
  string exposedHeaders; // JSON array, e.g. '["ETag"]'
  int maxAgeSeconds = 3600;

  Json toJson() const {
    auto j = entityToJson
      .set("bucketId", bucketId.value)
      .set("allowedOrigins", allowedOrigins)
      .set("allowedMethods", allowedMethods)
      .set("allowedHeaders", allowedHeaders)
      .set("exposedHeaders", exposedHeaders)
      .set("maxAgeSeconds", maxAgeSeconds);

    return j;
  }
}
