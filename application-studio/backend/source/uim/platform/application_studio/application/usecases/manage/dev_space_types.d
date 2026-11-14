/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.application.usecases.manage.dev_space_types;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// Interactor: dev space types. Predefined types (installed by the catalogue
/// seeder) are read-only; a type in use by a dev space cannot be deleted.
class ManageDevSpaceTypesUseCase
  : ResourceUseCase!(DevSpaceType, DevSpaceTypeId, CreateDevSpaceTypeRequest, UpdateDevSpaceTypeRequest),
  IManageDevSpaceTypesUseCase {

  this(StudioRepositories repos, IStudioEventPublisher publisher) {
    super(repos, repos.devSpaceTypes, publisher, "Dev space type", "studio.dev-space-type");
  }

  override protected DevSpaceType build(CreateDevSpaceTypeRequest r) {
    auto t = DevSpaceType(r.tenantId);
    assignMatching(t, r.spec);
    validate(t.category != DevSpaceTypeCategory.predefined, "Category 'predefined' is reserved for the SAP catalogue");
    check(t);
    ensureUnique(repos.devSpaceTypes.findByName(r.tenantId, t.name), t, "this tenant");
    return t;
  }

  override protected void apply(ref DevSpaceType t, DevSpaceTypeSpec spec) {
    requireCustom(t);
    assignMatching(t, spec, ["name", "category"]);
    check(t);
  }

  protected void check(ref DevSpaceType t) {
    validateDisplayName("Dev space type", t.name);
    t.predefinedExtensions = normalizedNames(t.predefinedExtensions);
    requireExtensions(t.tenantId, t.predefinedExtensions, false);
    ProjectType[] types;
    foreach (p; t.supportedProjectTypes)
      if (!types.canFind(p))
        types ~= p;
    t.supportedProjectTypes = types;
    validate(t.iconUrl.length == 0 || isHttpUrl(t.iconUrl), "Icon URL must be an http(s) URL");
  }

  protected static void requireCustom(const ref DevSpaceType t) {
    ensureState(t.category != DevSpaceTypeCategory.predefined, "Predefined dev space type '" ~ t.name ~ "' is read-only");
  }

  override protected void beforeRemove(DevSpaceType t) {
    requireCustom(t);
    auto users = repos.devSpaces.findByType(t.tenantId, t.id);
    ensureState(users.length == 0, "Dev space type '" ~ t.name ~ "' is used by " ~ users.length.to!string
        ~ " dev space(s): " ~ users.map!(d => d.name).join(", "));
  }
}
