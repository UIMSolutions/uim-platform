/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.application.usecases.manage.carriers;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
class ManageCarriersUseCase {
private:
  ICarrierRepository repo;

public:
  this(ICarrierRepository repo) {
    repo = repo;
  }

  UsecaseResult createCarrier(TenantId tenantId, CreateCarrierRequest req) {
    if (req.name.isEmpty)
      return UsecaseResult(false, "Carrier name is required");

    if (repo.existsByName(tenantId, req.name))
      return UsecaseResult(false, "A carrier with that name already exists");

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
    c.createdAt = currentTimestamp();
    c.updatedAt = c.createdAt;

    foreach (m; req.supportedModes) {
      try {
        c.supportedModes ~= m.to!TransportMode;
      } catch (Exception) {
      }
    }
    repo.save(c);
    return UsecaseResult(true, "", c.id.value);
  }

  UsecaseResult updateCarrier(TenantId tenantId, CarrierId id, UpdateCarrierRequest req) {
    auto c = repo.findById(tenantId, id);
    if (c.isNull)
      return UsecaseResult(false, "Carrier not found");

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
    updated.updatedAt = currentTimestamp();

    if (req.status.length > 0) {
      try {
        updated.status = req.status.to!CarrierStatus;
      } catch (Exception) {
        updated.status = c.status;
      }
    } else {
      updated.status = c.status;
    }
    if (req.supportedModes.length > 0) {
      foreach (m; req.supportedModes) {
        try {
          updated.supportedModes ~= m.to!TransportMode;
        } catch (Exception) {
        }
      }
    } else {
      updated.supportedModes = c.supportedModes;
    }
    repo.save(updated);
    return UsecaseResult(true, "", id.value);
  }

  UsecaseResult deleteCarrier(TenantId tenantId, CarrierId id) {
    auto e = repo.findById(tenantId, id);
    if (e.isNull)
      return UsecaseResult(false, "", "Carrier not found");
    
    repo.remove(e);
    return UsecaseResult(true);
  }

  Carrier getCarrier(TenantId tenantId, CarrierId id) {
    return repo.findById(tenantId, id);
  }

  Carrier[] listCarriers(TenantId tenantId) {
    return repo.findByTenant(tenantId);
  }

  Carrier[] listByStatus(TenantId tenantId, CarrierStatus status) {
    return repo.findByStatus(tenantId, status);
  }
}
