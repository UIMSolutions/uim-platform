# Market Rates Management – Bring Your Own Rates (BYOR)

A **D / vibe.d** microservice that replicates the core capabilities of
**SAP Market Rates Management, Bring Your Own Rates data option** on SAP BTP.

---

## Overview

The service lets you **upload**, **store**, **query**, and **distribute**
market rates (exchange rates, interest rates, securities, volatilities, etc.)
in a format compatible with SAP S/4HANA.  It supports the 12 official SAP
market data type codes and enforces the same quota limits as the SAP cloud
service.

---

## Features

| Feature | Description |
|---|---|
| **Upload** | POST up to 1,500 rate records per call (JSON); validated against domain rules |
| **Download** | POST a download request specifying instruments (key1~key2:category); returns JSON |
| **Query** | GET rates filtered by provider, category, key pair or date range |
| **Delete** | DELETE rates by provider code or date range |
| **Provider management** | Full CRUD for market data providers |
| **Business Logging** | Automatic audit log entry for every upload, download and delete |
| **Multi-tenant** | Every entity carries a `tenantId`; all queries are tenant-scoped |
| **12 data types** | Exchange Rates (01), Securities (02), Interest Rates (03), Indexes (04), Basis Spread (09), Credit Spread (10), Forex Swap Rates (21), General Volatilities (30), Exchange Rate Volatilities (31), Security Price Volatilities (32), Interest Rate Volatilities (33), Index Volatilities (34) |
| **Quota enforcement** | Max 1,500 records/request; 300,000 records/account; 6,000 requests/month |

---

## Architecture

The service uses **Hexagonal (Ports & Adapters) architecture** combined with
**Clean Architecture** layering:

```
┌─────────────────────────────────────────────┐
│  Presentation (HTTP driving adapters)        │
│  MarketRateController / AuditLogController   │
├─────────────────────────────────────────────┤
│  Application (use cases / orchestration)     │
│  ManageMarketRatesUseCase                    │
│  ManageProvidersUseCase                      │
│  ManageAuditLogsUseCase                      │
├─────────────────────────────────────────────┤
│  Domain (entities, value types, validators)  │
│  MarketRate / Provider / AuditLog            │
│  MarketRateValidator / QuotaService          │
├─────────────────────────────────────────────┤
│  Infrastructure (driven adapters)            │
│  MemoryMarketRateRepository                  │
│  MemoryProviderRepository                    │
│  MemoryAuditLogRepository                    │
└─────────────────────────────────────────────┘
```

Dependency direction: Presentation → Application → Domain ← Infrastructure

---

## API Endpoints

### Upload
```
POST /api/v1/market_refinitiv/upload
Content-Type: application/json

{
  "tenantId": "t1",
  "requestedBy": "user@example.com",
  "records": [
    {
      "providerCode": "ECB",
      "dataSource": "ECB",
      "category": "01",
      "key1": "EUR",
      "key2": "USD",
      "marketDataProperty": "CMID",
      "effectiveDate": "20260518",
      "effectiveTime": "120000",
      "marketDataValue": 1.0845,
      "fromFactor": 1,
      "toFactor": 1,
      "priceQuotation": "direct"
    }
  ]
}
```

### Download
```
POST /api/v1/market_refinitiv/download
Content-Type: application/json

{
  "tenantId": "t1",
  "requestedBy": "user@example.com",
  "providerCode": "ECB",
  "instruments": [
    { "key1": "EUR", "key2": "USD", "category": "01" }
  ],
  "latestOnly": true
}
```

### Query rates
```
GET /api/v1/market_refinitiv/rates?tenantId=t1&providerCode=ECB&category=01
GET /api/v1/market_refinitiv/rates/{id}?tenantId=t1
```

### Delete rates
```
DELETE /api/v1/market_refinitiv/rates
Content-Type: application/json

{ "tenantId": "t1", "providerCode": "ECB", "fromDate": "20260101", "toDate": "20260131" }
```

### Providers
```
GET    /api/v1/market_refinitiv/providers?tenantId=t1
POST   /api/v1/market_refinitiv/providers
GET    /api/v1/market_refinitiv/providers/{id}?tenantId=t1
PUT    /api/v1/market_refinitiv/providers/{id}
DELETE /api/v1/market_refinitiv/providers/{id}?tenantId=t1
```

### Audit Logs
```
GET /api/v1/market_refinitiv/auditlogs?tenantId=t1
GET /api/v1/market_refinitiv/auditlogs/{id}?tenantId=t1
```

### Health
```
GET /api/v1/health
→ { "status": "UP", "service": "Market Rates Management - BYOR" }
```

---

## Market Data Type Codes

| Code | Type |
|------|------|
| 01 | Exchange Rates |
| 02 | Securities |
| 03 | Interest Rates |
| 04 | Indexes |
| 09 | Basis Spread |
| 10 | Credit Spread |
| 21 | Forex Swap Rates |
| 30 | General Volatilities |
| 31 | Exchange Rate Volatilities |
| 32 | Security Price Volatilities |
| 33 | Interest Rate Volatilities |
| 34 | Index Volatilities |

---

## Build

```bash
# From workspace root
dub build --root=market-refinitiv --build=release --config=defaultRun

# Or inside the package directory
cd market-refinitiv
dub build --build=release --config=defaultRun
```

---

## Docker / Podman

```bash
# Build
docker build -t uim-market-refinitiv-platform-service:latest .
# or
podman build -t uim-market-refinitiv-platform-service:latest .

# Run
docker run -p 8097:8097 \
  -e MARKET_RATES_HOST=0.0.0.0 \
  -e MARKET_RATES_PORT=8097 \
  uim-market-refinitiv-platform-service:latest
```

---

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `MARKET_RATES_HOST` | `0.0.0.0` | Bind address |
| `MARKET_RATES_PORT` | `8097` | TCP port |

---

## Restrictions (mirrors SAP BYOR)

- Combined `key1` + `key2` must not exceed **15 characters**
- The tilde `~` and colon `:` are reserved characters and must not appear in keys
- Only one date-range request may be processed at a time; daily calls without dates work concurrently

---

## License

Apache 2.0 – see LICENSE.txt
