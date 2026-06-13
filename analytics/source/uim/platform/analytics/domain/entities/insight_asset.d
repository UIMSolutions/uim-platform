module uim.platform.analytics.domain.entities.insight_asset;

import uim.platform.analytics.domain.types;
import vibe.data.json : Json;

struct InsightAsset {
  mixin TenantEntity!AssetId;

  string name;
  string kind;
  string sourceSystem;
  string[] dimensions;
  string[] measures;
  bool published;

  Json toJson() const {
    auto dims = Json.emptyArray;
    foreach (d; dimensions)
      dims ~= Json(d);

    auto meas = Json.emptyArray;
    foreach (m; measures)
      meas ~= Json(m);

    return entityToJson
      .set("id", Json(id))
      .set("tenantId", Json(tenantId))
      .set("name", Json(name))
      .set("kind", Json(kind))
      .set("sourceSystem", Json(sourceSystem))
      .set("dimensions", dims)
      .set("measures", meas)
      .set("published", Json(published));
  }
}
