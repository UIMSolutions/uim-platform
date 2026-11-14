/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.run_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: run configurations. Starting needs a running dev space, free
/// ports in that dev space and connected (or connectable) service bindings.
class ManageRunConfigurationsUseCase
  : ResourceUseCase!(RunConfiguration, RunConfigurationId, CreateRunConfigurationRequest, UpdateRunConfigurationRequest),
  IManageRunConfigurationsUseCase {

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    super(repos, repos.runConfigurations, publisher, "Run configuration", "studio.run-configuration");
  }

  override protected RunConfiguration build(CreateRunConfigurationRequest r) {
    auto p = requireProject(r.tenantId, r.parentId, "add run configurations");
    auto rc = RunConfiguration(r.tenantId);
    rc.projectId = p.id;
    rc.projectName = p.name;
    rc.devSpaceId = p.devSpaceId;
    assignMatching(rc, r.spec);
    check(rc);
    ensureUnique(repos.runConfigurations.findByProjectAndName(r.tenantId, p.id, rc.name), rc, "project " ~ p.name);
    rc.status = RunStatus.idle;
    return rc;
  }

  override protected void apply(ref RunConfiguration rc, RunConfigurationSpec spec) {
    ensureState(!rc.status.isLive, "Stop run configuration '" ~ rc.name ~ "' before changing it");
    assignMatching(rc, spec, ["name"]);
    check(rc);
  }

  protected void check(ref RunConfiguration rc) {
    validateDisplayName("Run configuration", rc.name);
    rc.entryPoint = rc.entryPoint.strip;
    validateLaunch(rc);
    rc.serviceBindings = normalizedNames(rc.serviceBindings);
    foreach (n; rc.serviceBindings)
      if (repos.serviceBindings.findByName(rc.tenantId, rc.devSpaceId, n).isNull)
        throw new StudioNotFoundException("Service binding '" ~ n ~ "' not found in the dev space");
  }

  override protected void beforeRemove(RunConfiguration rc) {
    ensureState(!rc.status.isLive, "Stop run configuration '" ~ rc.name ~ "' before deleting it");
  }

  UsecaseResult start(TenantId tenantId, RunConfigurationId id, UserId actor) {
    return transition(tenantId, id, actor, "start requested", (ref RunConfiguration rc) {
      ensureState(!rc.status.isLive, "Run configuration '" ~ rc.name ~ "' is already " ~ enumText(rc.status));
      requireProject(tenantId, rc.projectId, "run it");
      requireRunning(requireDevSpace(tenantId, rc.devSpaceId), "run projects");
      foreach (n; rc.serviceBindings) {
        auto b = repos.serviceBindings.findByName(tenantId, rc.devSpaceId, n);
        ensureState(!b.isNull && b.status == BindingStatus.connected, "Service binding '" ~ n ~ "' is not connected");
      }
      ensurePortsFree(rc, portsInUse(repos.runConfigurations.findByDevSpace(tenantId, rc.devSpaceId), rc.id));
      rc.status = RunStatus.starting;
      rc.statusMessage = "Starting " ~ rc.entryPoint;
    });
  }

  UsecaseResult stop(TenantId tenantId, RunConfigurationId id, UserId actor) {
    return transition(tenantId, id, actor, "stopped", (ref RunConfiguration rc) {
      ensureState(rc.status.isLive, "Run configuration '" ~ rc.name ~ "' is not running");
      rc.status = RunStatus.stopped;
      rc.statusMessage = "";
      rc.url = "";
    });
  }
}
