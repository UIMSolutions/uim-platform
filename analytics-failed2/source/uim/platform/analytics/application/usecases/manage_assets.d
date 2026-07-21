module uim.platform.analytics.application.usecases.manage_assets;


import std.conv : to;
import uim.platform.analytics.application.dto;
import uim.platform.analytics.domain;

class ManageAssetsUseCase {
  private AssetRepository repository;
  private AnalyticsValidator validator;

  this(AssetRepository repository) {
    this.repository = repository;
    this.validator = AnalyticsValidator();
  }

  CommandResult createAsset(CreateAssetRequest req) {
    auto err = validator.validateCreate(req);
    if (err.length > 0) return CommandResult(false, "", err);

    auto now = MonoTime.currTime.ticks;

    InsightAsset asset;
    asset.id = "asset-" ~ now.to!string;
    asset.tenantId = req.tenantId;
    asset.name = req.name;
    asset.kind = req.kind;
    asset.sourceSystem = req.sourceSystem;
    asset.dimensions = req.dimensions.dup;
    asset.measures = req.measures.dup;
    asset.published = false;
    asset.createdAt = cast(long) now;
    asset.updatedAt = cast(long) now;

    auto id = repository.save(asset);
    return CommandResult(true, id, "Created");
  }

  InsightAsset[] listAssets(TenantId tenantId) {
    return repository.findByTenant(tenantId);
  }

  InsightAsset getAsset(TenantId tenantId, AssetId id) {
    return repository.findById(tenantId, id);
  }

  CommandResult updateAsset(UpdateAssetRequest req) {
    auto err = validator.validateUpdate(req);
    if (err.length > 0) return CommandResult(false, "", err);

    auto existing = repository.findById(req.tenantId, req.id);
    if (existing.isNull) return CommandResult(false, "", "Asset not found");

    existing.name = req.name;
    existing.kind = req.kind;
    existing.sourceSystem = req.sourceSystem;
    existing.dimensions = req.dimensions.dup;
    existing.measures = req.measures.dup;
    existing.updatedAt = cast(long) MonoTime.currTime.ticks;

    if (!repository.update(existing))
      return CommandResult(false, "", "Update failed");

    return CommandResult(true, existing.id, "Updated");
  }

  CommandResult deleteAsset(TenantId tenantId, AssetId id) {
    if (!repository.remove(tenantId, id))
      return CommandResult(false, "", "Asset not found");
    return CommandResult(true, id, "Deleted");
  }

  CommandResult publishAsset(TenantId tenantId, AssetId id) {
    auto existing = repository.findById(tenantId, id);
    if (existing.isNull) return CommandResult(false, "", "Asset not found");

    existing.published = true;
    existing.updatedAt = cast(long) MonoTime.currTime.ticks;
    if (!repository.update(existing))
      return CommandResult(false, "", "Publish failed");

    return CommandResult(true, existing.id, "Published");
  }
}

unittest {
  import uim.platform.analytics.infrastructure.persistence.repositories.assets;

  auto repo = new MemoryAssetRepository();
  auto useCase = new ManageAssetsUseCase(repo);

  CreateAssetRequest createReq;
  createReq.tenantId = "t1";
  createReq.name = "Revenue Story";
  createReq.kind = "story";
  createReq.sourceSystem = "sap-datasphere";
  createReq.dimensions = ["region"];
  createReq.measures = ["revenue"];

  auto created = useCase.createAsset(createReq);
  assert(created.success);
  assert(created.id.length > 0);

  auto listed = useCase.listAssets("t1");
  assert(listed.length == 1);
  assert(listed[0].name == "Revenue Story");

  UpdateAssetRequest updateReq;
  updateReq.tenantId = "t1";
  updateReq.id = created.id;
  updateReq.name = "Revenue Story Updated";
  updateReq.kind = "dashboard";
  updateReq.sourceSystem = "sap-hana";
  updateReq.dimensions = ["region", "segment"];
  updateReq.measures = ["revenue", "margin"];

  auto updated = useCase.updateAsset(updateReq);
  assert(updated.success);

  auto published = useCase.publishAsset("t1", created.id);
  assert(published.success);

  auto loaded = useCase.getAsset("t1", created.id);
  assert(!loaded.isNull);
  assert(loaded.published);
  assert(loaded.kind == "dashboard");

  auto deleted = useCase.deleteAsset("t1", created.id);
  assert(deleted.success);
  assert(useCase.listAssets("t1").length == 0);
}
