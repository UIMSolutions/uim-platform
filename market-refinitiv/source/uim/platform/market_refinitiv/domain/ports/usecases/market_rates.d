/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.market_refinitiv.domain.ports.usecases.market_rates;

import uim.platform.market_refinitiv;

mixin(ShowModule!());

@safe:

/// Port: outgoing — market rates management use case.
interface IManageMarketRatesUseCase {
  
  /// Uploads market rates for a given tenant.
  /// @param req The request containing the market rates to upload.
  UploadRatesResponse upload(UploadRatesRequest req);

  /// Downloads market rates for a given tenant.
  /// @param req The request containing the criteria for downloading market rates.
  DownloadRatesResponse download(DownloadRatesRequest req);

  /// Queries market rates for a given tenant based on the specified criteria.
  /// @param req The request containing the criteria for querying market rates.
  MarketRate[] queryRates(QueryRatesRequest req);

  /// Retrieves a market rate by its ID for a given tenant.
  /// @param tenantId The tenant ID.
  /// @param id The ID of the market rate to retrieve.
  MarketRate getRate(TenantId tenantId, MarketRateId id);

  /// Deletes market rates for a given tenant based on the specified criteria.
  /// @param req The request containing the criteria for deleting market rates.
  UsecaseResult deleteRate(DeleteRatesRequest req);

}