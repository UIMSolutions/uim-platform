/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.domain.ports.repositories.certificates;

import uim.platform.destination.domain.entities.certificate;
import uim.platform.destination.domain.types;

/// Port: outgoing — certificate persistence.
interface CertificateRepository
{
  Certificate findById(CertificateId id);
  Certificate findByName(TenantId tenantId, SubaccountId subaccountId, string name);
  Certificate[] findByTenant(TenantId tenantId);
  Certificate[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId);
  Certificate[] findByType(TenantId tenantId, SubaccountId subaccountId, CertificateType type);
  Certificate[] findExpiring(TenantId tenantId, long beforeTimestamp);
  void save(Certificate cert);
  void update(Certificate cert);
  void remove(CertificateId id);
}
