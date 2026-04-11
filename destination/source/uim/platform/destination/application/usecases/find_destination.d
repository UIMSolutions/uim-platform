/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.application.usecases.find_destination;

// import uim.platform.destination.application.dto;
// import uim.platform.destination.domain.entities.destination;
// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.entities.auth_token;
// import uim.platform.destination.domain.entities.certificate;
// import uim.platform.destination.domain.ports.repositories.destinations;
// import uim.platform.destination.domain.ports.repositories.fragments;
// import uim.platform.destination.domain.ports.repositories.certificates;
// import uim.platform.destination.domain.services.destination_resolver;
// import uim.platform.destination.domain.types;

// import std.conv : to;
import uim.platform.destination;

mixin(ShowModule!());

@safe:
/// Application service for the "Find Destination" API — resolves a destination
/// by name, merges fragments, resolves auth tokens, and collects certificates.
class FindDestinationUseCase : UIMUseCase {
  private DestinationRepository destRepo;
  private FragmentRepository fragRepo;
  private CertificateRepository certRepo;

  this(DestinationRepository destRepo, FragmentRepository fragRepo, CertificateRepository certRepo) {
    this.destRepo = destRepo;
    this.fragRepo = fragRepo;
    this.certRepo = certRepo;
  }

  DestinationLookupResponse find(FindDestinationRequest req) {
    DestinationLookupResponse resp;

    if (req.name.length == 0) {
      resp.found = false;
      resp.error = "Destination name is required";
      return resp;
    }

    // Look up the destination by name
    auto dest = destRepo.findByName(req.tenantId, req.subaccountId, req.name);
    if (dest.id.isEmpty) {
      resp.found = false;
      resp.error = "Destination '" ~ req.name ~ "' not found";
      return resp;
    }

    if (dest.status == DestinationStatus.inactive) {
      resp.found = false;
      resp.error = "Destination '" ~ req.name ~ "' is inactive";
      return resp;
    }

    // Resolve fragments
    DestinationFragment[] fragments;
    string[] fragmentNames;
    foreach (fid; dest.fragmentIds) {
      auto frag = fragRepo.findById(fid);
      if (!frag.id.isEmpty) {
        fragments ~= frag;
        fragmentNames ~= frag.name;
      }
    }

    // Apply fragments to the destination
    auto resolved = DestinationResolver.applyFragments(dest, fragments);

    // Resolve auth token
    auto token = DestinationResolver.resolveAuthToken(resolved);

    // Collect referenced certificates
    Certificate[] certs;
    if (!resolved.keystoreId.isEmpty) {
      auto ks = certRepo.findById(resolved.keystoreId);
      if (!ks.id.isEmpty)
        certs ~= ks;
    }
    if (!resolved.truststoreId.isEmpty) {
      auto ts = certRepo.findById(resolved.truststoreId);
      if (!ts.id.isEmpty)
        certs ~= ts;
    }

    // Build response
    resp.found = true;
    resp.destinationName = resolved.name;
    resp.url = resolved.url;
    resp.authenticationType = resolved.authenticationType.to!string;
    resp.proxyType = resolved.proxyType.to!string;
    resp.destinationType = resolved.destinationType.to!string;
    resp.properties = resolved.properties;
    resp.appliedFragments = fragmentNames;

    if (token.type_.length > 0) {
      AuthTokenDto td;
      td.type_ = token.type_;
      td.value_ = token.value_;
      td.expiresAt = token.expiresAt;
      td.httpHeaderSuggestion = token.httpHeaderSuggestion;
      resp.authTokens ~= td;
    }

    foreach (c; certs) {
      CertificateDto cd;
      cd.name = c.name;
      cd.type_ = c.certificateType.to!string;
      cd.format_ = c.format_.to!string;
      cd.status = c.status.to!string;
      resp.certificates ~= cd;
    }

    return resp;
  }
}
