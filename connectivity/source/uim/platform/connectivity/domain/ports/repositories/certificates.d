/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.domain.ports.repositories.certificates;

// import uim.platform.connectivity.domain.entities.certificate;
// import uim.platform.connectivity.domain.types;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
/// Port: outgoing - certificate store persistence.
interface CertificateRepository {
  bool existsById(CertificateId id);
  Certificate findById(CertificateId id);

  bool existsName(TenantId tenantId, string name);
  Certificate findByName(TenantId tenantId, string name);

  Certificate[] findByTenant(TenantId tenantId);
  Certificate[] findExpiring(TenantId tenantId, long now, uint withinDays);

  void save(Certificate cert);
  void update(Certificate cert);
  void remove(CertificateId id);
}
