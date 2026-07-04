/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.application.usecases.manage.deployments;

import uim.platform.buildcode;


mixin(ShowModule!());

@safe:

class ManageDeploymentsUseCase {
  private DeploymentRepository  _repo;

  this(DeploymentRepository repo) { _repo = repo; }

  CommandResult create(TenantId tenantId, CreateDeploymentRequest req) {
    DeploymentEnvironment env = DeploymentEnvironment.cloudFoundry;
    static foreach (member; __traits(allMembers, DeploymentEnvironment)) {
      if (req.targetEnvironment == mixin("DeploymentEnvironment." ~ member ~ ".to!string"))
        env = mixin("DeploymentEnvironment." ~ member);
    }

    auto d = Deployment(tenantId, DeploymentId(createId), req.createdBy);
    d.projectId         = ProjectId(req.projectId);
    d.buildJobId        = BuildJobId(req.buildJobId);
    d.artifactVersion   = req.artifactVersion;
    d.targetEnvironment = env;
    d.status            = DeploymentStatus.pending;
    d.targetOrg         = req.targetOrg;
    d.targetSpace       = req.targetSpace;
    d.deployedBy        = req.deployedBy;
    d.deployedAtMs      = 0;

    _repo.save(d);
    return CommandResult(true, d.id.value, "");
  }

  Deployment getById(TenantId tenantId, DeploymentId id) {
    return _repo.findById(tenantId, id);
  }

  Deployment[] list(TenantId tenantId) {
    return _repo.findByTenant(tenantId);
  }

  Deployment[] listByProject(TenantId tenantId, string projectId) {
    return _repo.findByProject(tenantId, projectId);
  }

  Deployment[] listByEnvironment(TenantId tenantId, string envStr) {
    DeploymentEnvironment env = DeploymentEnvironment.other;
    static foreach (member; __traits(allMembers, DeploymentEnvironment)) {
      if (envStr == mixin("DeploymentEnvironment." ~ member ~ ".to!string"))
        env = mixin("DeploymentEnvironment." ~ member);
    }
    return _repo.findByEnvironment(tenantId, env);
  }

  CommandResult updateStatus(TenantId tenantId, string id, string statusStr, string url = "") {
    auto d = _repo.findById(tenantId, DeploymentId(id));
    if (d.isNull) return CommandResult(false, "", "Deployment not found");
    static foreach (member; __traits(allMembers, DeploymentStatus)) {
      if (statusStr == mixin("DeploymentStatus." ~ member ~ ".to!string"))
        d.status = mixin("DeploymentStatus." ~ member);
    }
    if (url.length > 0) d.targetUrl = url;
    _repo.update(d);
    return CommandResult(true, id, "");
  }
}
