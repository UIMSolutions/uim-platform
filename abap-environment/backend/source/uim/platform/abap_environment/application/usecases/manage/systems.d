/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.application.usecases.manage.systems;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// Derive a free SID from a system name: the first three letters/digits
/// ("dev-eu" → "DEV"), else letter + two digits ("D01", "D02", ...).
string deriveSystemId(string name, const string[] taken) {
  import std.ascii : isAlpha, isAlphaNum, toUpper;

  string chars;
  foreach (c; name)
    if (isAlphaNum(c))
      chars ~= toUpper(c);
  auto first = chars.length > 0 && isAlpha(chars[0]) ? chars[0 .. 1] : "S";
  if (chars.length >= 3 && isAlpha(chars[0])) {
    auto candidate = chars[0 .. 3];
    if (!reservedSystemIds.canFind(candidate) && !taken.canFind(candidate))
      return candidate;
  }
  foreach (n; 1 .. 100) {
    auto candidate = first ~ format("%02d", n);
    if (!taken.canFind(candidate))
      return candidate;
  }
  throw new AbapConflictException("No free SAP System ID left for '" ~ name ~ "'");
}

/// Interactor: ABAP system instances. Provisioning, resizing, upgrades and
/// deprovisioning are completed asynchronously by the reconciler.
class ManageSystemsUseCase
  : ResourceUseCase!(SystemInstance, SystemInstanceId, CreateSystemRequest, UpdateSystemRequest),
  IManageSystemsUseCase {

  this(AbapRepositories repos, IAbapEventPublisher publisher) {
    super(repos, repos.systems, publisher, "System", "abap.system");
  }

  override protected SystemInstance build(CreateSystemRequest r) {
    auto s = SystemInstance(r.tenantId);
    assignMatching(s, r.spec);
    s.sapSystemId = s.sapSystemId.strip.toUpper;
    check(s);
    ensureUnique(repos.systems.findByName(r.tenantId, s.name), s, "this tenant");

    auto others = repos.systems.findByTenant(r.tenantId);
    if (s.sapSystemId.length == 0)
      s.sapSystemId = deriveSystemId(s.name, others.map!(o => o.sapSystemId).array);
    validateSystemId(s.sapSystemId);
    ensureState(repos.systems.findBySid(r.tenantId, s.sapSystemId).isNull,
      "SAP System ID '" ~ s.sapSystemId ~ "' is already used in this tenant");
    if (s.plan == SystemPlan.free_)
      ensureState(!others.any!(o => o.plan == SystemPlan.free_), "Only one free system is allowed per tenant");

    s.status = SystemStatus.provisioning;
    s.statusMessage = "Provisioning requested";
    return s;
  }

  /// Name, SID, region and plan are fixed; sizes change via a resize (→ updating).
  override protected void apply(ref SystemInstance s, SystemSpec spec) {
    auto resized = spec.abapRuntimeSize != s.abapRuntimeSize || spec.hanaMemorySize != s.hanaMemorySize;
    assignMatching(s, spec, ["name", "sapSystemId", "region", "plan", "abapRuntimeSize", "hanaMemorySize"]);
    if (resized) {
      requireActive(s, "be resized");
      s.abapRuntimeSize = spec.abapRuntimeSize;
      s.hanaMemorySize = spec.hanaMemorySize;
      check(s);
      transitionTo(s, SystemStatus.updating);
      s.statusMessage = "Resize to " ~ s.abapRuntimeSize.to!string ~ " GB ABAP / "
        ~ s.hanaMemorySize.to!string ~ " GB HANA requested";
    }
    check(s);
  }

  protected static void check(const ref SystemInstance s) {
    validateDisplayName("System", s.name);
    validateEmail("Administrator e-mail", s.adminEmail);
    validate(s.region.length > 0, "Region is required");
    validate(s.abapRuntimeSize >= 16 && s.abapRuntimeSize <= 1024 && s.abapRuntimeSize % 16 == 0,
      "ABAP runtime size must be a multiple of 16 GB between 16 and 1024");
    validate(s.hanaMemorySize >= 16 && s.hanaMemorySize <= 4096 && s.hanaMemorySize % 16 == 0,
      "HANA memory size must be a multiple of 16 GB between 16 and 4096");
    if (s.plan == SystemPlan.free_)
      validate(s.abapRuntimeSize == 16 && s.hanaMemorySize <= 32, "The free plan is limited to 16 GB ABAP and 32 GB HANA");
  }

  override protected void beforeRemove(SystemInstance s) {
    ensureState(canTransition(s.status, SystemStatus.deleting), "System '" ~ s.name
        ~ "' cannot be deleted while " ~ enumText(s.status));
  }

  override protected bool retire(ref SystemInstance s) {
    transitionTo(s, SystemStatus.deleting);
    s.statusMessage = "Deprovisioning requested";
    return true;
  }

  UsecaseResult suspend(TenantId tenantId, SystemInstanceId id, UserId actor) {
    return transition(tenantId, id, actor, "suspended", (ref SystemInstance s) {
      transitionTo(s, SystemStatus.suspended);
      s.statusMessage = "";
    });
  }

  UsecaseResult resume(TenantId tenantId, SystemInstanceId id, UserId actor) {
    return transition(tenantId, id, actor, "resumed", (ref SystemInstance s) {
      ensureState(s.status == SystemStatus.suspended, "System '" ~ s.name ~ "' is not suspended");
      transitionTo(s, SystemStatus.active);
    });
  }

  UsecaseResult upgrade(TenantId tenantId, SystemInstanceId id, string softwareVersion, UserId actor) {
    return transition(tenantId, id, actor, "upgrade started", (ref SystemInstance s) {
      auto v = softwareVersion.strip;
      validate(v.length == 4 && v.all!(c => c >= '0' && c <= '9'), "Software version looks like 2511 (YYMM)");
      validate(v > s.softwareVersion, "Software version " ~ v ~ " is not newer than " ~ s.softwareVersion);
      requireActive(s, "be upgraded");
      transitionTo(s, SystemStatus.updating);
      s.softwareVersion = v;
      s.statusMessage = "Upgrade to " ~ v ~ " requested";
    });
  }
}

///
unittest {
  assert(deriveSystemId("dev-eu", []) == "DEV");
  assert(deriveSystemId("dev", ["DEV"]) == "D01");
  assert(deriveSystemId("sap", []) == "S01"); // reserved
  assert(deriveSystemId("42", []) == "S01");
}
