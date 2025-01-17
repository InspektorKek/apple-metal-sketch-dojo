//
//  ShaderHelpers.metal
//  MetalDojo
//
//  Created by Georgi Nikoloff on 19.01.23.
//

#include <metal_stdlib>
#import <simd/simd.h>
using namespace metal;

float2 uvBackgroundSizeCover(float2 uv, float2 imageSize, float2 surfaceSize) {
  float2 s = surfaceSize;
  float2 i = imageSize;
  float rs = s.x / s.y;
  float ri = i.x / i.y;
  float2 n = rs < ri ? float2(i.x * s.y / i.y, s.y) : float2(s.x, i.y * s.x / i.x);
  float2 offset = (rs < ri ? float2((n.x - s.x) / 2.0, 0.0) : float2(0.0, (n.y - s.y) / 2.0)) / n;
  return uv * s / n + offset;
}

float2 encodeNormals(float3 n) {
  float p = sqrt(n.z * 8.0 + 8.0);
  return float2(n.xy / p + 0.5);
}

float3 decodeNormals(float2 enc) {
  float2 fenc = enc * 4.0 - 2.0;
  float f = dot(fenc, fenc);
  float g = sqrt(1.0 - f / 4.0);
  return float3(fenc * g, 1.0 - f / 2.0);
}

matrix_float4x4 rotation3d(float3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return matrix_float4x4(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s, 0.0,
                         oc * axis.x * axis.y + axis.z * s, oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 0.0,
                         oc * axis.z * axis.x - axis.y * s, oc * axis.y * axis.z + axis.x * s, oc * axis.z * axis.z + c, 0.0,
                         0.0, 0.0, 0.0, 1.0);
}
