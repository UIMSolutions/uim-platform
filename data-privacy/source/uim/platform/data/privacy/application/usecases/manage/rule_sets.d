/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.rule_sets;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageRuleSetsUseCase : UIMUseCase {
  private RuleSetRepository repo;

  this(RuleSetRepository repo) {
    this.repo = repo;
  }

  CommandResult createRuleSet(CreateRuleSetRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    auto now = Clock.currStdTime();
    auto rs = RuleSet();
    rs.id = randomUUID();
    rs.tenantId = req.tenantId;
    rs.businessContextId = req.businessContextId;
    rs.name = req.name;
    rs.description = req.description;
    rs.status = RuleSetStatus.draft;
    rs.priority = req.priority;
    rs.createdAt = now;
    rs.updatedAt = now;

    repo.save(rs);
    return CommandResult(rs.id, "");
  }

  RuleSet* getRuleSet(RuleSetId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  RuleSet[] listRuleSets(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  RuleSet[] listByBusinessContext(TenantId tenantId, BusinessContextId contextId) {
    return repo.findByBusinessContext(tenantId, contextId);
  }

  CommandResult updateRuleSet(UpdateRuleSetRequest req) {
    auto rs = repo.findById(req.id, req.tenantId);
    if (rs is null)
      return CommandResult(false, "", "Rule set not found");

    if (req.name.length > 0) rs.name = req.name;
    if (req.description.length > 0) rs.description = req.description;
    if (req.priority > 0) rs.priority = req.priority;
    rs.updatedAt = Clock.currStdTime();

    repo.update(*rs);
    return CommandResult(rs.id, "");
  }

  CommandResult activateRuleSet(RuleSetId tenantId, id tenantId) {
    auto rs = repo.findById(tenantId, id);
    if (rs is null)
      return CommandResult(false, "", "Rule set not found");

    rs.status = RuleSetStatus.active;
    rs.activatedAt = Clock.currStdTime();
    rs.updatedAt = rs.activatedAt;

    repo.update(*rs);
    return CommandResult(rs.id, "");
  }

  void deleteRuleSet(RuleSetId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
