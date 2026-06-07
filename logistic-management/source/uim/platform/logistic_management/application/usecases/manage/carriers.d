module uim.platform.logistic_management.application.usecases.manage.carriers;

/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.carriers;
import uim.platform.logistic_management;

// mixin(ShowModule!());

@safe:
class ManageCarriersUseCase {
private:
  CarrierRepository _repo;

public:
  this(CarrierRepository repo) {
    _repo = repo;
  }

  CommandResult createCarrier(TenantId tenantId, CreateCarrierRequest req) {
    if (req.name.length == 0)
      return CommandResult(false, "Carrier name is required");
    if (_repo.existsByName(tenantId, req.name))
      return CommandResult(false, "A carrier with that name already exists");

    Carrier c;
    c.id = CarrierId(generateId());
    c.tenantId = tenantId;
    c.name = req.name;
    c.description = req.description;
    c.contactEmail = req.contactEmail;
    c.contactPhone = req.contactPhone;
    c.addressStreet = req.addressStreet;
    c.addressCity = req.addressCity;
    c.addressCountry = req.addressCountry;
    c.taxId = req.taxId;
    c.status = CarrierStatus.active;
    c.createdAt = currentTimeMs();
    c.updatedAt = c.createdAt;
    
    foreach (m; req.supportedModes) {
      try { c.supportedModes ~= m.to!TransportMode; } catch (Exception) {}
    }
    _repo.save(c);
    return CommandResult(true, "", c.id.value);
  }

  CommandResult updateCarrier(TenantId tenantId, CarrierId id, UpdateCarrierRequest req) {
    auto c = _repo.findById(tenantId, id);
    if (c == Carrier.init) return CommandResult(false, "Carrier not found");

    Carrier updated;
    updated.id = c.id;
    updated.tenantId = c.tenantId;
    updated.name = c.name;
    updated.description = req.description.length > 0 ? req.description : c.description;
    updated.contactEmail = req.contactEmail.length > 0 ? req.contactEmail : c.contactEmail;
    updated.contactPhone = req.contactPhone.length > 0 ? req.contactPhone : c.contactPhone;
    updated.addressStreet = req.addressStreet.length > 0 ? req.addressStreet : c.addressStreet;
    updated.addressCity = req.addressCity.length > 0 ? req.addressCity : c.addressCity;
    updated.addressCountry = req.addressCountry.length > 0 ? req.addressCountry : c.addressCountry;
    updated.taxId = c.taxId;
    updated.createdAt = c.createdAt;
    updated.updatedAt = currentTimeMs();
    
    if (req.status.length > 0) {
      try { updated.status = req.status.to!CarrierStatus; } catch (Exception) { updated.status = c.status; }
    } else {
      updated.status = c.status;
    }
    if (req.supportedModes.length > 0) {
      foreach (m; req.supportedModes) {
        try { updated.supportedModes ~= m.to!TransportMode; } catch (Exception) {}
      }
    } else {
      updated.supportedModes = c.supportedModes;
    }
    _repo.save(updated);
    return CommandResult(true, "", id.value);
  }

  CommandResult deleteCarrier(TenantId tenantId, CarrierId id) {
    auto c = _repo.findById(tenantId, id);
    if (c == Carrier.init) return CommandResult(false, "Carrier not found");
    _repo.remove(tenantId, id);
    return CommandResult(true);
  }

  Carrier getCarrier(TenantId tenantId, CarrierId id) {
    return _repo.findById(tenantId, id);
  }

  Carrier[] listCarriers(TenantId tenantId) {
    return _repo.findAll(tenantId);
  }

  Carrier[] listByStatus(TenantId tenantId, CarrierStatus status) {
    return _repo.findByStatus(tenantId, status);
  }
}
