//
//  Common.h
//  MetalDojo
//
//  Created by Georgi Nikoloff on 27.12.22.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef enum {
  Position = 0,
  UV = 1,
  Normal = 2,
  Color = 3,
  Tangent = 4,
  Bitangent = 5,
  Joints = 6,
  Weights = 7
} Attributes;

typedef enum {
  VertexBuffer = 0,
  UVBuffer = 1,
  ColorBuffer = 2,
  TangentBuffer = 3,
  BitangentBuffer = 4,

  JointBuffer = 8,
  MaterialBuffer = 9,
  LightBuffer = 10,
  UniformsBuffer = 11,
  ParamsBuffer = 12,
  CameraUniformsBuffer = 13,
} BufferIndices;

typedef enum {
  BaseColor = 0,
  NormalTexture = 1,
  RoughnessTexture = 2,
  MetallicTexture = 3,
  AOTexture = 4,
  ShadowTexture = 5,
  OpacityTexture = 6,
  SkyboxTexture = 11,
  SkyboxDiffuseTexture = 12,
  BRDFLutTexture = 13,
  MiscTexture = 30
} TextureIndices;

typedef enum {
  unused = 0,
  Sun = 1,
  Spot = 2,
  Point = 3,
  Ambient = 4
} LightType;

typedef struct {
  matrix_float4x4 viewMatrix;
  matrix_float4x4 projectionMatrix;
  vector_float3 position;
  float near;
  float far;
} CameraUniforms;

typedef struct {
  matrix_float4x4 modelMatrix;
  matrix_float3x3 normalMatrix;
  matrix_float3x3 uvMatrix;
} Uniforms;

typedef struct {
  vector_float3 position;
  vector_float3 color;
  vector_float3 specularColor;
  vector_float3 attenuation;
  vector_float3 coneDirection;
  float coneAngle;
  float coneAttenuation;
  LightType type;
  float speed;
  vector_float3 prevPosition;
  vector_float3 velocity;
} Light;

typedef struct {
  float shininess;
  vector_float3 baseColor;
  vector_float3 specularColor;
  float roughness;
  float metallic;
  float ambientOcclusion;
  float opacity;
} Material;

typedef struct {
  uint lightsCount;
  vector_float3 worldSize;
} Params;

typedef enum {
  RendersToTargetArray = 0,
  IsSkeletonAnimation = 1,
  RendersDepth = 2,
  HasUV = 3,
  CustomFnConstant = 10
} FunctionConstants;

#endif /* Common_h */
