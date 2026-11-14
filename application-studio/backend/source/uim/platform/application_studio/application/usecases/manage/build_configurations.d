/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.build_configurations;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: build configurations. Builds and deployments are queued here
/// (status building / deploying) and executed by the reconciler; the project
/// mirrors the progress (building / deploying / active).
class ManageBuildConfigurationsUseCase
  : ResourceUseCase!(BuildConfiguration, BuildConfigurationId, CreateBuildConfigurationRequest, UpdateBuildConfigurationRequest),
  IManageBuildConfigurationsUseCase {

  protected ProjectStatusSync projectStatus;

  this(StudioRepositories repos, ProjectStatusSync projectStatus, IStudioEventPublisher publisher) {
    super(repos, repos.buildConfigurations, publisher, "Build configuration", "studio.build-configuration");
    this.projectStatus = projectStatus;
  }

  override protected BuildConfiguration build(CreateBuildConfigurationRequest r) {
    auto p = requireProject(r.tenantId, r.parentId, "add build configurations");
    auto bc = BuildConfiguration(r.tenantId);
    bc.projectId = p.id;
    bc.projectName = p.name;
    bc.devSpaceId = p.devSpaceId;
    assignMatching(bc, r.spec);
    check(bc, p);
    ensureUnique(repos.buildConfigurations.findByProjectAndName(r.tenantId, p.id, bc.name), bc, "project " ~ p.name);
    bc.status = BuildStatus.pending;
    return bc;
  }

  override protected void apply(ref BuildConfiguration bc, BuildConfigurationSpec spec) {
    ensureState(!bc.status.isBusy, "Build configuration '" ~ bc.name ~ "' is " ~ enumText(bc.status));
    auto oldTarget = bc.deployTarget;
    auto oldArtifact = defaultArtifactPath(oldTarget, bc.projectName);
    auto oldCommand = defaultDeployCommand(oldTarget, bc.artifactPath);
    assignMatching(bc, spec, ["name"]);
    if (bc.deployTarget != oldTarget) {
      // derived defaults follow the new target; explicit values are kept
      if (bc.artifactPath == oldArtifact)
        bc.artifactPath = "";
      if (bc.deployCommand == oldCommand)
        bc.deployCommand = "";
    }
    check(bc, repos.projects.findById(bc.tenantId, bc.projectId));
  }

  protected static void check(ref BuildConfiguration bc, const Project p) {
    validateDisplayName("Build configuration", bc.name);
    bc.buildCommand = bc.buildCommand.strip;
    validate(bc.buildCommand.length > 0, "Build command is required (e.g. 'mbt build' or 'npm run build')");
    if (bc.deployTarget == DeployTarget.cloudFoundry && bc.mtaDescriptor.strip.length == 0)
      bc.mtaDescriptor = "mta.yaml";
    validateDeployTarget(p.projectType, bc.deployTarget, bc.mtaDescriptor.strip);
    if (bc.artifactPath.strip.length == 0)
      bc.artifactPath = defaultArtifactPath(bc.deployTarget, bc.projectName);
    if (bc.deployCommand.strip.length == 0)
      bc.deployCommand = defaultDeployCommand(bc.deployTarget, bc.artifactPath);
  }

  override protected void beforeRemove(BuildConfiguration bc) {
    ensureState(!bc.status.isBusy, "Build configuration '" ~ bc.name ~ "' is " ~ enumText(bc.status)
        ~ " — cancel it first");
  }

  protected void requireWorkspace(TenantId tenantId, const BuildConfiguration bc, string what) {
    requireProject(tenantId, bc.projectId, what);
    requireRunning(requireDevSpace(tenantId, bc.devSpaceId), what);
  }

  protected static BuildRun newRun(const BuildConfiguration bc, BuildPhase phase, BuildStatus status) {
    BuildRun run;
    run.runId = bc.name.toLower.replace(" ", "-") ~ "-" ~ (bc.history.length + 1).to!string;
    run.phase = phase;
    run.status = status;
    run.startedAt = nowStdTime();
    return run;
  }

  UsecaseResult build(TenantId tenantId, BuildConfigurationId id, UserId actor) {
    auto result = transition(tenantId, id, actor, "build queued", (ref BuildConfiguration bc) {
      ensureCanBuild(bc);
      requireWorkspace(tenantId, bc, "build");
      bc.status = BuildStatus.building;
      bc.statusMessage = "Running '" ~ bc.buildCommand ~ "'";
      recordRun(bc, newRun(bc, BuildPhase.build, BuildStatus.building));
    });
    if (result.isSuccess)
      projectStatus.sync(tenantId, require(tenantId, id).projectId);
    return result;
  }

  UsecaseResult deploy(TenantId tenantId, BuildConfigurationId id, UserId actor) {
    auto result = transition(tenantId, id, actor, "deployment queued", (ref BuildConfiguration bc) {
      ensureCanDeploy(bc);
      requireWorkspace(tenantId, bc, "deploy");
      bc.status = BuildStatus.deploying;
      bc.statusMessage = "Running '" ~ bc.deployCommand ~ "'";
      recordRun(bc, newRun(bc, BuildPhase.deploy, BuildStatus.deploying));
    });
    if (result.isSuccess)
      projectStatus.sync(tenantId, require(tenantId, id).projectId);
    return result;
  }

  UsecaseResult cancel(TenantId tenantId, BuildConfigurationId id, UserId actor) {
    auto result = transition(tenantId, id, actor, "cancelled", (ref BuildConfiguration bc) {
      ensureState(bc.status.isBusy, "Build configuration '" ~ bc.name ~ "' has nothing to cancel");
      bc.status = BuildStatus.cancelled;
      bc.statusMessage = "Cancelled by " ~ (actor.isEmpty ? "user" : actor.value);
      if (bc.history.length > 0) {
        bc.history[$ - 1].status = BuildStatus.cancelled;
        bc.history[$ - 1].finishedAt = nowStdTime();
        bc.history[$ - 1].message = bc.statusMessage;
      }
    });
    if (result.isSuccess)
      projectStatus.sync(tenantId, require(tenantId, id).projectId);
    return result;
  }
}
