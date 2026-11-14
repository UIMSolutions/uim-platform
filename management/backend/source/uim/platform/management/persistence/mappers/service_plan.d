/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.persistence.mappers.service_plan;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Converts between ServicePlan and its snapshot record.
struct ServicePlanMapper {
  static Json toRecord(const ServicePlan e) {
    auto r = baseRecord(e);
    r["serviceName"] = e.serviceName;
    r["serviceDisplayName"] = e.serviceDisplayName;
    r["planName"] = e.planName;
    r["planDisplayName"] = e.planDisplayName;
    r["description"] = e.description;
    r["category"] = enumName(e.category);
    r["status"] = enumName(e.status);
    r["pricingModel"] = enumName(e.pricingModel);
    r["isFree"] = e.isFree;
    r["isBeta"] = e.isBeta;
    r["availableRegions"] = listToJson(e.availableRegions);
    r["maxQuota"] = e.maxQuota;
    r["unit"] = e.unit;
    r["supportedPlatforms"] = listToJson(e.supportedPlatforms);
    r["providerDisplayName"] = e.providerDisplayName;
    r["dataCenter"] = e.dataCenter;
    r["catalogUrl"] = e.catalogUrl;
    r["provisionable"] = e.provisionable;
    r["metadata"] = propertiesToJson(e.metadata);
    return r;
  }

  static ServicePlan fromRecord(Json r) {
    ServicePlan e;
    readBase(e, r);
    e.serviceName = fieldString(r, "serviceName");
    e.serviceDisplayName = fieldString(r, "serviceDisplayName");
    e.planName = fieldString(r, "planName");
    e.planDisplayName = fieldString(r, "planDisplayName");
    e.description = fieldString(r, "description");
    e.category = fieldEnum!ServicePlanCategory(r, "category", ServicePlanCategory.service);
    e.status = fieldEnum!ServicePlanStatus(r, "status", ServicePlanStatus.active);
    e.pricingModel = fieldEnum!PricingModel(r, "pricingModel", PricingModel.free);
    e.isFree = fieldBool(r, "isFree");
    e.isBeta = fieldBool(r, "isBeta");
    e.availableRegions = fieldStrings(r, "availableRegions");
    e.maxQuota = fieldInt(r, "maxQuota");
    e.unit = fieldString(r, "unit");
    e.supportedPlatforms = fieldStrings(r, "supportedPlatforms");
    e.providerDisplayName = fieldString(r, "providerDisplayName");
    e.dataCenter = fieldString(r, "dataCenter");
    e.catalogUrl = fieldString(r, "catalogUrl");
    e.provisionable = fieldBool(r, "provisionable", true);
    e.metadata = fieldMap(r, "metadata");
    return e;
  }
}

///
unittest {
  mixin(ShowTest!("ServicePlanMapper"));

  auto p = ServicePlan(TenantId("t1"));
  p.status = ServicePlanStatus.deprecated_;
  p.availableRegions = ["eu10"];
  auto r = ServicePlanMapper.toRecord(p);
  assert(r["status"].get!string == "deprecated");
  auto back = ServicePlanMapper.fromRecord(r);
  assert(back.status == ServicePlanStatus.deprecated_ && back.availableRegions == ["eu10"] && back.provisionable);
}
