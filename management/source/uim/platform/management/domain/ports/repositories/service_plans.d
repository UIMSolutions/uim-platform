/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.ports.repositories.service_plans;

// import uim.platform.management.domain.entities.service_plan;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Port: outgoing — service plan catalog persistence.
interface ServicePlanRepository : IIdRepository!(ServicePlan, ServicePlanId) {

  size_t countByService(string serviceName);
  ServicePlan[] filterByService(ServicePlan[] items, string serviceName);
  ServicePlan[] findByService(string serviceName);
  void removeByService(string serviceName);

  size_t countByCategory(ServicePlanCategory category);
  ServicePlan[] filterByCategory(ServicePlan[] items, ServicePlanCategory category);  
  ServicePlan[] findByCategory(ServicePlanCategory category);
  void removeByCategory(ServicePlanCategory category);

  size_t countByRegion(string region);
  ServicePlan[] filterByRegion(ServicePlan[] items, string region);
  ServicePlan[] findByRegion(string region);
  void removeByRegion(string region);
  
}
