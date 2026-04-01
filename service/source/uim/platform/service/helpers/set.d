module uim.platform.service.helpers.set;

import uim.platform.service;

mixin(ShowModule!());

@safe:

Json set(Json data, string key, Json value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(Json data, string key, string value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(Json data, string key, bool value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(Json data, string key, int value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(Json data, string key, long value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(Json data, string key, double value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(Json data, string key, size_t value) {
  if (!data.isObject) return data;
  
  data[key] = value;
  return data;
}

Json set(T)(Json data, string key, T[] values) {
  if (!data.isObject) return data;
  
  data[key] = values.toJson;
  return data;
}