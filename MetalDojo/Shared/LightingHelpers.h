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

#endif /* LightingHelpers_h */