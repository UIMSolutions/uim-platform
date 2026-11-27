/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A catalog asset: the governed, searchable description of an object of a
/// space (business name, owner, quality, sensitivity, tags, glossary terms).
module uim.platform.datasphere.domain.entities.catalog_asset;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

struct CatalogAsset {
  mixin TenantEntity!CatalogAssetId;

  SpaceId spaceId;
  string name;
  string businessName;
  string description;
  AssetType assetType = AssetType.view;
  string sourceObjectId; /// id of the described object ("" = external)
  string owner;
  QualityStatus qualityStatus = QualityStatus.unknown;
  Sensitivity sensitivity = Sensitivity.internal;
  string[] tags;
  string[] glossaryTerms;
  long accessCount;
  long lastAccessedAt;

  /// Count a read of the asset.
  void recordAccess(long at) {
    accessCount++;
    lastAccessedAt = at;
  }

  /// Relevance of the asset for a search text (0 = no match): name and
  /// business name weigh most, then tags and glossary terms, then the description.
  int searchScore(string text) const {
    auto q = text.strip.toLower;
    if (q.length == 0)
      return 1;
    int score;
    foreach (word; q.split) {
      if (name.toLower.canFind(word) || businessName.toLower.canFind(word))
        score += 10;
      if (tags.any!(t => t.toLower.canFind(word)) || glossaryTerms.any!(t => t.toLower.canFind(word)))
        score += 5;
      if (description.toLower.canFind(word) || owner.toLower.canFind(word))
        score += 1;
    }
    return score;
  }

  void validate() const {
    requireId(id.value, "Asset ID");
    if (spaceId.isNull)
      throw DspException.invalid("The space of the asset is required");
    requireText(name, "Asset name");
    requireMaxLength(name, 200, "Asset name");
    requireMaxLength(businessName, 200, "Business name");
    requireMaxLength(description, 5000, "Description");
    requireMaxLength(owner, 200, "Owner");
    if (sourceObjectId.length)
      requireId(sourceObjectId, "Source object");
    if (tags.length > 50 || glossaryTerms.length > 50)
      throw DspException.invalid("At most 50 tags and 50 glossary terms");
    foreach (t; tags ~ glossaryTerms)
      requireMaxLength(t, 100, "Tag / glossary term");
  }
}

///
unittest {
  CatalogAsset a;
  a.id = CatalogAssetId("a");
  a.spaceId = SpaceId("SALES");
  a.name = "V_SALES_ORDERS";
  a.businessName = "Sales Orders";
  a.tags = ["revenue"];
  a.description = "Orders of S/4HANA";
  a.validate();
  assert(a.searchScore("sales") == 10 && a.searchScore("revenue") == 5 && a.searchScore("s/4hana") == 1);
  assert(a.searchScore("hr") == 0 && a.searchScore("") == 1);
  a.recordAccess(5);
  assert(a.accessCount == 1 && a.lastAccessedAt == 5);
}
