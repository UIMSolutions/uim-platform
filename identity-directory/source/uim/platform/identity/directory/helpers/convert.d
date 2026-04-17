/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.helpers.convert;

import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:

Address[] toAddresses(Json json) {
  Address[] result;
  if (!json.isObject)
    return null;

  if ("addresses" !in json)
    return null;

  auto value = json["addresses"];
  if (!value.isArray)
    return result;

  return value.toArray.map!(item => Address(
      item.getString("formatted"), item.getString("streetAddress"),
      item.getString("locality"), item.getString("region"),
      item.getString("postalCode"), item.getString("country"),
      item.getString("type"), getBoolean(item, "primary"))).array;
}

UserName toUserName(Json json) {
  if (!json.isObject)
    return UserName.init;

  if ("name" !in json)
    return UserName.init;

  auto value = json["name"];
  if (!value.isObject)
    return UserName.init;

  return UserName(value.getString("formatted"), value.getString("familyName"),
    value.getString("givenName"), value.getString("middleName"),    
    value.getString("honorificPrefix"), value.getString("honorificSuffix"));
}