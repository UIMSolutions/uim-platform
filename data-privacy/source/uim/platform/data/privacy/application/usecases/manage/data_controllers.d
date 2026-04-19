/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.application.usecases.manage.data_controllers;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ManageDataControllersUseCase { // TODO: UIMUseCase {
  private DataControllerRepository repo;

  this(DataControllerRepository repo) {
    this.repo = repo;
  }

  CommandResult createController(CreateDataControllerRequest req) {
    if (req.tenantId.isEmpty)
      return CommandResult(false, "", "Tenant ID is required");
    if (req.name.length == 0)
      return CommandResult(false, "", "Name is required");

    auto now = Clock.currStdTime();
    auto c = DataController();
    c.id = randomUUID();
    c.tenantId = req.tenantId;
    c.name = req.name;
    c.description = req.description;
    c.legalEntityName = req.legalEntityName;
    c.contactEmail = req.contactEmail;
    c.contactPhone = req.contactPhone;
    c.address = req.address;
    c.country = req.country;
    c.dpoName = req.dpoName;
    c.dpoEmail = req.dpoEmail;
    c.isActive = true;
    c.createdAt = now;
    c.updatedAt = now;

    repo.save(c);
    return CommandResult(c.id, "");
  }

  DataController* getController(DataControllerId tenantId, id tenantId) {
    return repo.findById(tenantId, id);
  }

  DataController[] listControllers(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  CommandResult updateController(UpdateDataControllerRequest req) {
    auto c = repo.findById(req.id, req.tenantId);
    if (c is null)
      return CommandResult(false, "", "Data controller not found");

    if (req.name.length > 0) c.name = req.name;
    if (req.description.length > 0) c.description = req.description;
    if (req.legalEntityName.length > 0) c.legalEntityName = req.legalEntityName;
    if (req.contactEmail.length > 0) c.contactEmail = req.contactEmail;
    if (req.contactPhone.length > 0) c.contactPhone = req.contactPhone;
    if (req.address.length > 0) c.address = req.address;
    if (req.country.length > 0) c.country = req.country;
    if (req.dpoName.length > 0) c.dpoName = req.dpoName;
    if (req.dpoEmail.length > 0) c.dpoEmail = req.dpoEmail;
    c.updatedAt = Clock.currStdTime();

    repo.update(*c);
    return CommandResult(c.id, "");
  }

  void deleteController(DataControllerId tenantId, id tenantId) {
    repo.remove(tenantId, id);
  }
}
