module uim.platform.analytics.domain.entities.insight_asset;

import uim.platform.analytics;

// mixin(ShowModule!());

@safe:  

struct InsightAsset {
  AssetId id;
  TenantId tenantId;
  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
  bool published;
  long createdAt;
  long updatedAt;

  bool isNull() const {
    return id.length == 0;
  }

  Json toJson() const {
    auto dims = Json.emptyArray;
    foreach (d; dimensions) dims ~= Json(d);

    auto meas = Json.emptyArray;
    foreach (m; measures) meas ~= Json(m);

    auto obj = Json.emptyObject;
    obj["id"] = Json(id);
    obj["tenantId"] = Json(tenantId);
    obj["name"] = Json(name);
    obj["kind"] = Json(kind);
    obj["sourceSystem"] = Json(sourceSystem);
    obj["dimensions"] = dims;
    obj["measures"] = meas;
    obj["published"] = Json(published);
    obj["createdAt"] = Json(createdAt);
    obj["updatedAt"] = Json(updatedAt);
    return obj;
  }
}
