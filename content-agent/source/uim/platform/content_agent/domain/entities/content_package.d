/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.entities.content_package;

// import uim.platform.content_agent.domain.types;
import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// A single content item within a package.
struct ContentItem {
  string id;
  string name;
  ContentCategory category;
  ContentProviderId providerId;
  string version_;
  string description;
  string[] dependencies;

  Json toJson() const {
    return Json.entityToJson
      .set("id", id)
      .set("name", name)
      .set("category", category.to!string)
      .set("providerId", providerId)
      .set("version", version_)
      .set("description", description)
      .set("dependencies", dependencies);
  }
}

/// A package containing bundled content for transport across landscapes.
struct ContentPackage {
  mixin TenantEntity!(ContentPackageId);

  SubaccountId subaccountId;
  string name;
  string description;
  string version_;
  PackageStatus status = PackageStatus.draft;
  ContentFormat format = ContentFormat.mtar;
  ContentItem[] items;
  string[] tags;
  long assembledAt;
  long packageSizeBytes;

  Json toJson() const {
    return Json.entityToJson
      .set("subaccountId", subaccountId)
      .set("name", name)
      .set("description", description)
      .set("version", version_)
      .set("status", status.to!string)
      .set("format", format.to!string)
      .set("items", items.map!(item => item.toJson()).array)
      .set("tags", tags)
      .set("assembledAt", assembledAt)
      .set("packageSizeBytes", packageSizeBytes);
  }
}
