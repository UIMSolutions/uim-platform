/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.domain.entities.flex_variant;
import uim.platform.ui_flexibility;

// mixin(ShowModule!());

@safe:

/// A saved view variant (filter bar view, table view) available to authorized end users.
struct FlexVariant {
  mixin TenantEntity!(FlexVariantId);

  string appId_;            // Target application
  VariantType variantType_; // filterBar, table, chart, etc.
  string variantName_;      // User-visible name
  string content_;          // JSON string: variant filter/column configuration
  bool isDefault_;          // Whether this is the default variant
  bool isPublic_;           // True = visible to all users; false = only creator
  ChangeLayer layer_;       // customer or user layer
  string author_;           // Who created this variant
  long createdAtTicks_;
  long updatedAtTicks_;

  Json toJson() const @trusted {
    auto j = entityToJson(this);
    j["appId"] = Json(appId_);
    j["variantType"] = Json(variantType_.to!string);
    j["variantName"] = Json(variantName_);
    j["content"] = Json(content_);
    j["isDefault"] = Json(isDefault_);
    j["isPublic"] = Json(isPublic_);
    j["layer"] = Json(layer_.to!string);
    j["author"] = Json(author_);
    j["createdAtTicks"] = Json(createdAtTicks_);
    j["updatedAtTicks"] = Json(updatedAtTicks_);
    return j;
  }
}
