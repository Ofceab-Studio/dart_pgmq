"use strict";
var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);
var getPlatform_exports = {};
__export(getPlatform_exports, {
  computeLibSSLSpecificPaths: () => import_chunk_EY5MORMD.computeLibSSLSpecificPaths,
  getArchFromUname: () => import_chunk_EY5MORMD.getArchFromUname,
  getBinaryTargetForCurrentPlatform: () => import_chunk_EY5MORMD.getBinaryTargetForCurrentPlatform,
  getBinaryTargetForCurrentPlatformInternal: () => import_chunk_EY5MORMD.getBinaryTargetForCurrentPlatformInternal,
  getPlatformInfo: () => import_chunk_EY5MORMD.getPlatformInfo,
  getPlatformInfoMemoized: () => import_chunk_EY5MORMD.getPlatformInfoMemoized,
  getSSLVersion: () => import_chunk_EY5MORMD.getSSLVersion,
  getos: () => import_chunk_EY5MORMD.getos,
  parseDistro: () => import_chunk_EY5MORMD.parseDistro,
  parseLibSSLVersion: () => import_chunk_EY5MORMD.parseLibSSLVersion,
  parseOpenSSLVersion: () => import_chunk_EY5MORMD.parseOpenSSLVersion,
  resolveDistro: () => import_chunk_EY5MORMD.resolveDistro
});
module.exports = __toCommonJS(getPlatform_exports);
var import_chunk_EY5MORMD = require("./chunk-EY5MORMD.js");
var import_chunk_FWMN4WME = require("./chunk-FWMN4WME.js");
var import_chunk_YVXCXD3A = require("./chunk-YVXCXD3A.js");
var import_chunk_2ESYSVXG = require("./chunk-2ESYSVXG.js");
