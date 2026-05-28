/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.ui_flexibility.application.usecases.manage.flex_variants;
import uim.platform.ui_flexibility;

mixin(ShowModule!());

@safe:

class ManageFlexVariantsUseCase {
  private FlexVariantRepository repo;

  this(FlexVariantRepository repo) {
    this.repo = repo;
  }

  CommandResult createVariant(CreateFlexVariantRequest r) {
    auto v = FlexVariant();
    v.id_ = r.variantId;
    v.tenant_ = r.tenantId;
    v.appId_ = r.appId;
    v.variantType_ = r.variantType_;
    v.variantName_ = r.variantName_;
    v.content_ = r.content_;
    v.isDefault_ = r.isDefault_;
    v.isPublic_ = r.isPublic_;
    v.layer_ = r.layer_;
    v.author_ = r.author_;
    v.createdAtTicks_ = MonoTime.currTime.ticks;
    v.updatedAtTicks_ = v.createdAtTicks_;

    auto err = FlexValidator.validateFlexVariant(v);
    if (err !is null)
      return CommandResult(false, null, err);

    repo.save(r.tenantId, v);
    return CommandResult(true, v.id_.value);
  }

  CommandResult updateVariant(UpdateFlexVariantRequest r) {
    auto existing = repo.findById(r.tenantId, r.variantId);
    if (existing.isNull)
      return CommandResult(false, null, "FlexVariant not found");

    existing.variantName_ = r.variantName_;
    existing.content_ = r.content_;
    existing.isDefault_ = r.isDefault_;
    existing.isPublic_ = r.isPublic_;
    existing.updatedAtTicks_ = currentTimestamp();
    
    repo.update(r.tenantId, existing);
    return CommandResult(true, existing.id_.value, "FlexVariant updated successfully.");
  }

  FlexVariant getVariant(TenantId tenantId, FlexVariantId id) {
    return repo.findById(tenantId, id);
  }

  FlexVariant[] listVariants(TenantId tenantId) {
    return repo.findByTenantAll(tenantId);
  }

  FlexVariant[] listVariantsByApp(TenantId tenantId, string appId) {
    return repo.findByApp(tenantId, appId);
  }

  FlexVariant[] listVariantsByType(TenantId tenantId, string appId, VariantType variantType) {
    return repo.findByType(tenantId, appId, variantType);
  }

  FlexVariant[] listPublicVariants(TenantId tenantId, string appId) {
    return repo.findPublicByApp(tenantId, appId);
  }

  CommandResult deleteVariant(TenantId tenantId, FlexVariantId id) {
    auto existing = repo.findById(tenantId, id);
    if (existing.isNull)
      return CommandResult(false, null, "FlexVariant not found");

    repo.remove(existing);
    return CommandResult(true, existing.id.value, "FlexVariant deleted successfully.");
  }
}
