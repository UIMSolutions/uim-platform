/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ai_core.application.usecases.manage.artifacts;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

class ManageArtifactsUseCase : AiCoreInteractor, IManageArtifacts {
  this(AiCoreRepositories repos, IClock clock, IAiCoreEventPublisher events, LifecyclePolicy policy) {
    super(repos, clock, events, policy);
  }

  Artifact createArtifact(CreateArtifactRequest r) {
    auto t = r.tenantId, rg = r.resourceGroupId;
    groupOf(t, rg);
    auto scenario = scenarioOf(t, rg, ScenarioId(r.scenarioId.strip));
    auto execution = ExecutionId(r.executionId.strip);
    if (!execution.isNull && !repos.executions.existsById(t, rg, execution))
      throw AiCoreException.notFound("Execution '" ~ execution.value ~ "'");
    auto id = idOrNew(r.id);
    if (repos.artifacts.existsById(t, rg, ArtifactId(id)))
      throw AiCoreException.conflict("Artifact '" ~ id ~ "' already exists");
    Artifact a;
    stampCreated!(Artifact, ArtifactId)(a, t, r.actor, id, now);
    a.resourceGroupId = rg;
    a.scenarioId = scenario.id;
    a.executionId = execution;
    a.name = r.name.strip;
    a.kind = parseDomainEnumOr!ArtifactKind(r.kind, ArtifactKind.other, "artifact kind");
    a.url = r.url.strip;
    a.description = r.description;
    a.labels = checkedLabels(r.labels);
    a.validate();
    repos.artifacts.save(a);
    emit("artifact.created", t, resourceKey(rg.value, id), Json(["kind": Json(cast(string) a.kind)]));
    return a;
  }

  Artifact updateArtifact(UpdateArtifactRequest r) {
    auto a = getArtifact(r.tenantId, r.resourceGroupId, ArtifactId(r.id));
    r.description.applyTo(a.description);
    if (r.labels.isSet)
      a.labels = checkedLabels(r.labels.value);
    stampUpdated(a, r.actor, now);
    repos.artifacts.save(a);
    return a;
  }

  Artifact getArtifact(TenantId t, ResourceGroupId rg, ArtifactId id) {
    return required(repos.artifacts.findById(t, rg, id), "Artifact '" ~ id.value ~ "'");
  }

  Artifact[] listArtifacts(TenantId t, ResourceGroupId rg, ArtifactFilter filter = ArtifactFilter.init) {
    return repos.artifacts.findByGroup(t, rg).filter!(a => filter.matches(a)).array;
  }

  void deleteArtifact(TenantId t, ResourceGroupId rg, ArtifactId id) {
    getArtifact(t, rg, id);
    auto users = repos.configurations.findByGroup(t, rg)
      .count!(c => c.inputArtifactBindings.any!(b => b.artifactId == id));
    if (users > 0)
      throw AiCoreException.ruleViolation(format("Artifact '%s' is bound by %d configuration(s)", id.value, users));
    repos.artifacts.removeById(t, rg, id);
    emit("artifact.deleted", t, resourceKey(rg.value, id.value));
  }
}
