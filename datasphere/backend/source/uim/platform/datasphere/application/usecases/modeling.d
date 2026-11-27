/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Modeling and governance: views, data flows, data access controls and
/// the catalog.
///
///   * the sources of a view are derived from its SQL (FROM / JOIN); they
///     must be objects of the space when the view is deployed
///   * changing a deployed view or data flow sets "changesToDeploy"
///   * views and data flows cannot be deleted while tasks, data flows,
///     other views or data access controls use them
///   * a data access control protects views of its own space
module uim.platform.datasphere.application.usecases.modeling;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

class ManageViewsUseCase : ResourceInteractor!(DataView, DataViewId, ViewInput), IManageViews {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(DataView, DataViewId) store() {
    return repos.views;
  }

  protected override string what() {
    return "View";
  }

  protected override string eventPrefix() {
    return "view";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId", "name"];
  }

  protected override ViewInput toInput(const DataView e) {
    ViewInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.businessName = e.businessName;
    i.description = e.description;
    i.semantic = cast(string) e.semantic;
    i.sqlExpression = e.sqlExpression;
    i.columns = e.columns.dup;
    i.exposed = e.exposed;
    return i;
  }

  protected override void fromInput(TenantId t, ref DataView e, ViewInput i, bool creating) {
    if (creating) {
      auto space = activeSpace(t, i.spaceId, "Creating a view");
      requireUniqueName(t, space.id, i.name.strip);
    }
    auto before = toInput(e);
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.businessName = i.businessName.strip.length ? i.businessName.strip : e.name;
    e.description = i.description.strip;
    e.semantic = parseDomainEnum!ViewSemantic(i.semantic, "semantic usage");
    e.sqlExpression = i.sqlExpression.strip;
    e.sourceObjects = e.sqlExpression.length ? analyzeViewSql(e.sqlExpression) : null;
    e.columns = i.columns.map!(c => c.strip).filter!(c => c.length > 0).array;
    e.exposed = i.exposed;
    if (!creating && (before.sqlExpression != i.sqlExpression.strip || before.columns != e.columns
        || before.semantic != i.semantic))
      e.deploymentStatus = afterChange(e.deploymentStatus);
  }

  protected override void beforeRemove(TenantId t, const DataView e, UserId actor) {
    auto s = e.spaceId.value;
    auto views = repos.views.findByReference(t, "spaceId", s).count!(v => v.id != e.id && v.sourceObjects.containsName(e.name));
    requireUnused("View '" ~ e.name ~ "'", views, "views");
    auto flows = repos.dataFlows.findByReference(t, "spaceId", s).count!(f => f.sourceObjects.containsName(e.name));
    requireUnused("View '" ~ e.name ~ "'", flows, "data flows");
    auto tasks = repos.tasks.findByReference(t, "targetObjectId", e.id.value).count!(x => x.taskType == TaskType.viewPersistence);
    requireUnused("View '" ~ e.name ~ "'", tasks, "tasks");
    auto controls = repos.accessControls.findByReference(t, "spaceId", s).count!(c => c.targetViewIds.canFind(e.id.value));
    requireUnused("View '" ~ e.name ~ "'", controls, "data access controls");
  }

  override void remove(TenantId t, DataViewId id, UserId actor) {
    auto space = get(t, id).spaceId;
    super.remove(t, id, actor);
    runner.refreshUsage(t, space);
  }

  DataView deploy(TenantId t, DataViewId id, UserId actor) {
    auto v = get(t, id);
    spaceOf(t, v.spaceId).requireActive("Deployment");
    v.requireDeployable();
    v.sourceObjects = analyzeViewSql(v.sqlExpression);
    foreach (src; v.sourceObjects)
      if (src.toUpper == v.name.toUpper)
        throw DspException.ruleViolation("View '" ~ v.name ~ "' must not read itself");
    requireObjects(t, v.spaceId, v.sourceObjects, "Source");
    v.deploymentStatus = DeploymentStatus.deployed;
    v.deployedAt = now;
    stampUpdated(v, actor, now);
    repos.views.save(v);
    emit("view.deployed", t, id.value);
    return v;
  }

  TaskRun persist(TenantId t, DataViewId id, UserId actor) {
    auto v = get(t, id);
    RunContext rc;
    rc.actor = actor;
    return runner.persistView(t, v.spaceId, id, rc);
  }

  DataView removePersistence(TenantId t, DataViewId id, UserId actor) {
    auto v = get(t, id);
    v.persisted = false;
    v.rowCount = 0;
    v.persistedBytes = 0;
    v.persistedAt = 0;
    stampUpdated(v, actor, now);
    repos.views.save(v);
    runner.refreshUsage(t, v.spaceId);
    emit("view.persistenceRemoved", t, id.value);
    return v;
  }

  AccessDecision checkAccess(TenantId t, DataViewId id, string user, Json row) {
    auto v = get(t, id);
    requireText(user, "User");
    if (row.type != Json.Type.object)
      throw DspException.invalid("The row must be a JSON object (column: value)");
    return evaluateAccess(repos.accessControls.findByReference(t, "spaceId", v.spaceId.value), id.value, user.strip, row);
  }
}

class ManageDataFlowsUseCase : ResourceInteractor!(DataFlow, DataFlowId, DataFlowInput), IManageDataFlows {
  protected RunService runner;

  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy, RunService runner) {
    super(repos, clock, audit, unitOfWork, policy);
    this.runner = runner;
  }

  protected override IDspRepository!(DataFlow, DataFlowId) store() {
    return repos.dataFlows;
  }

  protected override string what() {
    return "Data flow";
  }

  protected override string eventPrefix() {
    return "dataFlow";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId", "name"];
  }

  protected override DataFlowInput toInput(const DataFlow e) {
    DataFlowInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.businessName = e.businessName;
    i.description = e.description;
    i.sourceObjects = e.sourceObjects.dup;
    i.transforms = e.transforms.dup;
    i.targetTable = e.targetTable;
    i.loadMode = cast(string) e.loadMode;
    return i;
  }

  protected override void fromInput(TenantId t, ref DataFlow e, DataFlowInput i, bool creating) {
    if (creating)
      activeSpace(t, i.spaceId, "Creating a data flow");
    auto before = toInput(e);
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.businessName = i.businessName.strip.length ? i.businessName.strip : e.name;
    e.description = i.description.strip;
    e.sourceObjects = i.sourceObjects.map!(s => s.strip).filter!(s => s.length > 0).array;
    e.transforms = i.transforms.map!(s => s.strip).filter!(s => s.length > 0).array;
    auto target = i.targetTable.strip;
    if (target != e.targetTable && target.length)
      requireUniqueName(t, e.spaceId, target);
    if (target != e.targetTable) { // a new target starts empty
      e.targetRows = 0;
      e.targetBytes = 0;
    }
    e.targetTable = target;
    e.loadMode = parseDomainEnum!LoadMode(i.loadMode, "load mode");
    if (!creating && (before.sourceObjects != e.sourceObjects || before.transforms != e.transforms
        || before.targetTable != e.targetTable || before.loadMode != i.loadMode))
      e.deploymentStatus = afterChange(e.deploymentStatus);
  }

  protected override void beforeRemove(TenantId t, const DataFlow e, UserId actor) {
    auto tasks = repos.tasks.findByReference(t, "targetObjectId", e.id.value).count!(x => x.taskType == TaskType.dataFlow);
    requireUnused("Data flow '" ~ e.name ~ "'", tasks, "tasks");
    if (e.targetTable.length) {
      auto s = e.spaceId.value;
      auto readers = repos.views.findByReference(t, "spaceId", s).count!(v => v.sourceObjects.containsName(e.targetTable))
        + repos.dataFlows.findByReference(t, "spaceId", s).count!(f => f.id != e.id && f.sourceObjects.containsName(e.targetTable));
      requireUnused("Target table '" ~ e.targetTable ~ "'", readers, "views and data flows");
    }
  }

  override void remove(TenantId t, DataFlowId id, UserId actor) {
    auto space = get(t, id).spaceId;
    super.remove(t, id, actor);
    runner.refreshUsage(t, space);
  }

  DataFlow deploy(TenantId t, DataFlowId id, UserId actor) {
    auto f = get(t, id);
    spaceOf(t, f.spaceId).requireActive("Deployment");
    f.requireDeployable();
    requireObjects(t, f.spaceId, f.sourceObjects, "Source");
    f.deploymentStatus = DeploymentStatus.deployed;
    f.deployedAt = now;
    stampUpdated(f, actor, now);
    repos.dataFlows.save(f);
    emit("dataFlow.deployed", t, id.value);
    return f;
  }

  TaskRun run(TenantId t, DataFlowId id, UserId actor) {
    auto f = get(t, id);
    RunContext rc;
    rc.actor = actor;
    return runner.runDataFlow(t, f.spaceId, id, rc);
  }
}

class ManageAccessControlsUseCase : ResourceInteractor!(DataAccessControl, DataAccessControlId, AccessControlInput),
IManageAccessControls {
  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IDspRepository!(DataAccessControl, DataAccessControlId) store() {
    return repos.accessControls;
  }

  protected override string what() {
    return "Data access control";
  }

  protected override string eventPrefix() {
    return "accessControl";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId"];
  }

  protected override AccessControlInput toInput(const DataAccessControl e) {
    AccessControlInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.description = e.description;
    i.criteriaColumn = e.criteriaColumn;
    i.criteriaOperator = cast(string) e.criteriaOperator;
    i.criteriaValues = e.criteriaValues.dup;
    i.targetViewIds = e.targetViewIds.dup;
    i.assignedUsers = e.assignedUsers.dup;
    i.enabled = e.enabled;
    return i;
  }

  protected override void fromInput(TenantId t, ref DataAccessControl e, AccessControlInput i, bool creating) {
    if (creating)
      spaceOf(t, SpaceId(i.spaceId.strip));
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.description = i.description.strip;
    e.criteriaColumn = i.criteriaColumn.strip;
    e.criteriaOperator = parseDomainEnum!CriteriaOperator(i.criteriaOperator, "criteria operator");
    e.criteriaValues = i.criteriaValues.map!(s => s.strip).filter!(s => s.length > 0).array;
    e.targetViewIds = i.targetViewIds.map!(s => s.strip).filter!(s => s.length > 0).array;
    e.assignedUsers = i.assignedUsers.map!(s => s.strip).filter!(s => s.length > 0).array;
    e.enabled = i.enabled;
    foreach (v; e.targetViewIds) {
      auto view = required(repos.views.findById(t, DataViewId(v)), "View '" ~ v ~ "'");
      if (view.spaceId != e.spaceId)
        throw DspException.ruleViolation("View '" ~ v ~ "' belongs to space '" ~ view.spaceId.value ~ "'");
    }
  }
}

class ManageCatalogUseCase : ResourceInteractor!(CatalogAsset, CatalogAssetId, CatalogAssetInput), IManageCatalog {
  this(DspRepositories repos, IClock clock, IAuditTrail audit, IDspUnitOfWork unitOfWork, DspPolicy policy) {
    super(repos, clock, audit, unitOfWork, policy);
  }

  protected override IDspRepository!(CatalogAsset, CatalogAssetId) store() {
    return repos.catalog;
  }

  protected override string what() {
    return "Catalog asset";
  }

  protected override string eventPrefix() {
    return "catalog";
  }

  protected override string[] immutableAttributes() {
    return ["spaceId"];
  }

  protected override CatalogAssetInput toInput(const CatalogAsset e) {
    CatalogAssetInput i;
    i.spaceId = e.spaceId.value;
    i.name = e.name;
    i.businessName = e.businessName;
    i.description = e.description;
    i.assetType = cast(string) e.assetType;
    i.sourceObjectId = e.sourceObjectId;
    i.owner = e.owner;
    i.qualityStatus = cast(string) e.qualityStatus;
    i.sensitivity = cast(string) e.sensitivity;
    i.tags = e.tags.dup;
    i.glossaryTerms = e.glossaryTerms.dup;
    return i;
  }

  protected override void fromInput(TenantId t, ref CatalogAsset e, CatalogAssetInput i, bool creating) {
    if (creating)
      spaceOf(t, SpaceId(i.spaceId.strip));
    e.spaceId = SpaceId(i.spaceId.strip);
    e.name = i.name.strip;
    e.businessName = i.businessName.strip.length ? i.businessName.strip : e.name;
    e.description = i.description.strip;
    e.assetType = parseDomainEnum!AssetType(i.assetType, "asset type");
    e.sourceObjectId = i.sourceObjectId.strip;
    e.owner = i.owner.strip;
    e.qualityStatus = parseDomainEnum!QualityStatus(i.qualityStatus, "quality status");
    e.sensitivity = parseDomainEnum!Sensitivity(i.sensitivity, "sensitivity");
    e.tags = i.tags.map!(s => s.strip).filter!(s => s.length > 0).array;
    e.glossaryTerms = i.glossaryTerms.map!(s => s.strip).filter!(s => s.length > 0).array;
    if (e.sourceObjectId.length && !sourceExists(t, e))
      throw DspException.notFound(cast(string) e.assetType ~ " '" ~ e.sourceObjectId ~ "' of space '" ~ e.spaceId.value ~ "'");
  }

  /// The described object exists in the space (types without a repository are not checked).
  protected bool sourceExists(TenantId t, const CatalogAsset a) {
    bool inSpace(E)(E x) {
      return !x.isNull && x.spaceId == a.spaceId;
    }

    switch (a.assetType) {
    case AssetType.view:
    case AssetType.analyticModel:
      return inSpace(repos.views.findById(t, DataViewId(a.sourceObjectId)));
    case AssetType.remoteTable:
      return inSpace(repos.remoteTables.findById(t, RemoteTableId(a.sourceObjectId)));
    case AssetType.dataFlow:
      return inSpace(repos.dataFlows.findById(t, DataFlowId(a.sourceObjectId)));
    case AssetType.connection:
      return inSpace(repos.connections.findById(t, ConnectionId(a.sourceObjectId)));
    default:
      return true;
    }
  }

  CatalogAsset[] search(TenantId t, string text, SpaceId spaceId) {
    CatalogAsset[] hits;
    int[string] scores;
    foreach (a; repos.catalog.findAll(t)) {
      if (!spaceId.isNull && a.spaceId != spaceId)
        continue;
      auto s = a.searchScore(text);
      if (s > 0) {
        hits ~= a;
        scores[a.id.value] = s;
      }
    }
    hits.sort!((a, b) => scores[a.id.value] != scores[b.id.value] ? scores[a.id.value] > scores[b.id.value]
        : a.accessCount > b.accessCount);
    return hits;
  }

  CatalogAsset recordAccess(TenantId t, CatalogAssetId id) {
    auto a = get(t, id);
    a.recordAccess(now);
    repos.catalog.save(a);
    return a;
  }
}
