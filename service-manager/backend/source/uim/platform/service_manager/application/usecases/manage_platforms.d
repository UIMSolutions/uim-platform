/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service_manager.application.usecases.manage_platforms;

import uim.platform.service_manager;

mixin(ShowModule!());

@safe:

class ManagePlatformsUseCase : IManagePlatforms {
  protected IPlatformRepository platforms;
  protected IServiceInstanceRepository instances;
  protected ILabelRepository labels;

  this(IPlatformRepository platforms, IServiceInstanceRepository instances, ILabelRepository labels) {
    this.platforms = platforms;
    this.instances = instances;
    this.labels = labels;
  }

  Platform[] listPlatforms(TenantId tenantId) {
    return platforms.findAll(tenantId);
  }

  Platform getPlatform(TenantId tenantId, PlatformId id) {
    return platforms.findById(tenantId, id).required("Platform '" ~ id.value ~ "'");
  }

  Platform registerPlatform(RegisterPlatformRequest r) {
    Platform p;
    stampCreated!(Platform, PlatformId)(p, r.tenantId, r.actor, r.id);
    if (platforms.existsById(r.tenantId, p.id))
      throw ServiceManagerException.conflict("Platform '" ~ p.id.value ~ "' already exists");
    p.name = r.name;
    p.description = r.description;
    p.type = parseDomainEnumOr!PlatformType(r.type, PlatformType.other, "type");
    p.region = r.region;
    p.subaccountId = SubaccountId(r.subaccountId);
    p.brokerUrl = r.brokerUrl;
    p.credentials = r.credentials;
    p.validate();
    ensureUniqueName(p);
    platforms.save(p);
    return p;
  }

  Platform updatePlatform(UpdatePlatformRequest r) {
    auto p = getPlatform(r.tenantId, r.id);
    r.name.applyTo(p.name);
    r.description.applyTo(p.description);
    if (r.type.isSet)
      p.type = parseDomainEnum!PlatformType(r.type.value, "type");
    if (r.status.isSet)
      p.status = parseDomainEnum!PlatformStatus(r.status.value, "status");
    r.region.applyTo(p.region);
    if (r.subaccountId.isSet)
      p.subaccountId = SubaccountId(r.subaccountId.value);
    r.brokerUrl.applyTo(p.brokerUrl);
    r.credentials.applyTo(p.credentials);
    p.validate();
    ensureUniqueName(p);
    stampUpdated(p, r.actor);
    platforms.save(p);
    return p;
  }

  void deregisterPlatform(TenantId tenantId, PlatformId id) {
    auto p = getPlatform(tenantId, id);
    auto used = instances.findByPlatform(tenantId, id).length;
    if (used > 0)
      throw ServiceManagerException.ruleViolation("Platform '" ~ p.name ~ "' still hosts " ~ countOf(used,
          "service instance"));
    platforms.removeById(tenantId, id);
    labels.removeByResource(tenantId, ResourceType.platform, id.value);
  }

  protected void ensureUniqueName(const Platform p) {
    auto other = platforms.findByName(p.tenantId, p.name);
    if (!other.isNull && other.id != p.id)
      throw ServiceManagerException.conflict("A platform named '" ~ p.name ~ "' already exists");
  }
}
