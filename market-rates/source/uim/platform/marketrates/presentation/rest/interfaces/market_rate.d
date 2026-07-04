/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.marketrates.presentation.rest.interfaces.market_rate;
import uim.platform.marketrates;


mixin(ShowModule!());

@safe:

// interface MarketRateController : SAPController {
//     @headerParam("tenantId", "X-Tenant-ID")
//     MarketRate[] getMarketRates(string tenantId);

//     @headerParam("tenantId", "X-Tenant-ID")
//     MarketRate getMarketRate(string tenantId, string id); 

//     CommandResult uploadMarketRates(string tenantId, MarketRate[] rates);
//     CommandResult downloadMarketRates(string tenantId);

//     CommandResult deleteMarketRates(string tenantId);

//     // Provider management
//     @headerParam("tenantId", "X-Tenant-ID")
//     MarketRateProvider[] listProviders(string tenantId);

//     @headerParam("tenantId", "X-Tenant-ID")
//     MarketRateProvider getProvider(string tenantId, string id);

//     CommandResult createProvider(string tenantId, MarketRateProvider provider);
//     CommandResult updateProvider(string tenantId, string id, MarketRateProvider provider);
//     CommandResult deleteProvider(string tenantId, string id);
//   }
