/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.service_plan;

import uim.platform.management.domain.entities.service_plan;
import uim.platform.management.domain.types;

/// Port: outgoing — service plan catalog persistence.
interface ServicePlanRepository
{
  ServicePlan findById(ServicePlanId id);
  ServicePlan[] findByService(string serviceName);
  ServicePlan[] findByCategory(ServicePlanCategory category);
  ServicePlan[] findByRegion(string region);
  ServicePlan[] findAll();
  void save(ServicePlan plan);
  void update(ServicePlan plan);
  void remove(ServicePlanId id);
}
