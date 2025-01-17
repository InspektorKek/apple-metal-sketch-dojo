//
//  LightingHelpers.h
//  MetalDojo
//
//  Created by Georgi Nikoloff on 19.01.23.
//

#ifndef LightingHelpers_h
#define LightingHelpers_h

vector_float3 phongLighting(vector_float3 normal,
                            vector_float3 position,
                            vector_float3 cameraPosition,
                            uint lightCount,
                            constant Light *lights,
                            Material material);

vector_float3 calculateSun(Light light,
                           vector_float3 normal,
                           vector_float3 cameraPosition,
                           Material material);

vector_float3 calculatePoint(Light light,
                             vector_float3 position,
                             vector_float3 normal,
                             Material material);

vector_float3 calculateFog(vector_float3 position,
                           vector_float3 color);

vector_float4 PBRLighting(constant Light *lights,
                          uint lightsCount,
                          Material material,
                          vector_float3 cameraPosition,
                          vector_float3 worldPos,
                          vector_float3 normal,
                          float opacity,
                          float shadow);

vector_float3 computeSpecular(vector_float3 normal,
                              vector_float3 viewDirection,
                              vector_float3 lightDirection,
                              float roughness,
                              vector_float3 F0);

vector_float3 computeDiffuse(Material material,
                             vector_float3 normal,
                             vector_float3 lightDirection);

#endif /* LightingHelpers_h */
