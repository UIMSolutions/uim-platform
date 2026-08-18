/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.analytics.application.usecases.manage_assets;

import uim.platform.analytics.application.dto;
import uim.platform.analytics.domain;

class ManageAssetsUseCase {
  protected AssetRepository repository;
  protected AnalyticsValidator validator;

  this(AssetRepository repository) {
    this.repository = repository;
    this.validator = AnalyticsValidator();
  }

  UsecaseResult createAsset(CreateAssetRequest req) {
    auto err = validator.validateCreate(req);
    if (err.length > 0)
      return UsecaseResult(false, "", err);

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
    asset.createdAt = cast(long)now;
    asset.updatedAt = cast(long)now;

    auto id = repository.save(asset);
    return UsecaseResult(true, id, "Created");
  }

  InsightAsset[] listAssets(TenantId tenantId) {
    return repository.findByTenant(tenantId);
  }

  InsightAsset getAsset(TenantId tenantId, AssetId id) {
    return repository.findById(tenantId, id);
  }

  UsecaseResult updateAsset(UpdateAssetRequest req) {
    auto err = validator.validateUpdate(req);
    if (err.length > 0)
      return UsecaseResult(false, "", err);

    auto existing = repository.findById(req.tenantId, req.id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Asset not found");

    existing.name = req.name;
    existing.kind = req.kind;
    existing.sourceSystem = req.sourceSystem;
    existing.dimensions = req.dimensions.dup;
    existing.measures = req.measures.dup;
    existing.updatedAt = cast(long)MonoTime.currTime.ticks;

    if (!repository.update(existing))
      return UsecaseResult(false, "", "Update failed");

    return UsecaseResult(true, existing.id, "Updated");
  }

  UsecaseResult deleteAsset(TenantId tenantId, AssetId id) {
    if (!repository.remove(tenantId, id))
      return UsecaseResult(false, "", "Asset not found");
    return UsecaseResult(true, id, "Deleted");
  }

  UsecaseResult publishAsset(TenantId tenantId, AssetId id) {
    auto existing = repository.findById(tenantId, id);
    if (existing.isNull)
      return UsecaseResult(false, "", "Asset not found");

    existing.published = true;
    existing.updatedAt = cast(long)MonoTime.currTime.ticks;
    if (!repository.update(existing))
      return UsecaseResult(false, "", "Publish failed");

    return UsecaseResult(true, existing.id, "Published");
  }
}

unittest {
  import uim.platform.analytics.infrastructure.persistence.repositories.assets;

  auto repo = new AssetRepository();
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
