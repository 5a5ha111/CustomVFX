Shader "Custom/CustomVFX"
{
    Properties
    {
        [Header(Emmiter)]
        _EmitterDimensions("EmitterDimensions", Vector) = (2, 2, 2, 0)
        
        _StartColor("StartColor", Color) = (1, 1, 1, 1)
        _EndColor("EndColor", Color) = (1, 1, 1, 1)
        [Space]
        [Header(Fade in and out and Opacity)]
        _Opacity("Opacity", Float) = 4
        _FadeInPower("FadeInPower", Float) = 0.75
        _FadeOutPower("FadeOutPower", Float) = 2
        [ToggleUI]_UseTextureRGBAlpha("Use Texture RGB as alpha", Float) = 0
        _TextureAlphaSmoothstep("Smoothstep max value for alpha transition", Float) = 1
        [ToggleUI]_UseTextureAlpha("Use Texture Alpha. Override use Texture RGB as alpha", Float) = 0
        [Space]
        [Header(Scale)]
        _ParticleStartSize("ParticleStartSize", Float) = 2
        _ParticleEndSize("ParticleEndSize", Float) = 2
        [Space]
        [Header(Debug)]
        [ToggleUI]_DebugTime("DebugTime", Float) = 0
        _ManualTime("ManualTime", Range(0, 1)) = 0
        [Space]
        [Header(Movement)]
        _ParticleSpeed("ParticleLifeSpeed", Float) = 1
        _ParticleDirectional("ParticleDirectional", Vector) = (0, 0, -1, 0)
        _ParticleSpead("ParticleSpead", Range(0, 360)) = 60
        _ParticleVelocityStart("ParticleVelocityStart", Float) = 0
        _ParticleVelocityEnd("ParticleVelocityEnd", Float) = 0
        [Space]
        [Header(Rotation)]
        _Rotation("Rotation", Range(-180, 180)) = 0
        [ToggleUI]_RotationRandomOffset("RotationRandomOffset", Float) = 1
        _RotationSpeed("RotationSpeed", Float) = 0
        [ToggleUI]_RandomizeRotationDirection("RandomizeRotationDirection", Float) = 1
        [Space]
        [Header(Forces)]
        _Wind("Wind", Vector) = (0, 0, 0, 0)
        _Gravityy("Gravity", Vector) = (0, 0, 0, 0)
        [Space]
        [Header(FlipBook)]
        _FlipBookDimenions("FlipBookDimenions", Vector) = (13, 13, 0, 0)
        [NoScaleOffset]_FlipBook("FlipBook", 2D) = "white" {}
        [ToggleUI]_FlipX("Inverse Flipbook X", float) = 0
        [ToggleUI]_FlipY("Inverse Flipbook Y", float) = 0
        [ToggleUI]_MatchParticlePhase("MatchParticlePhase", Float) = 1
        _FlipBookSpeed("FlipBookSpeed", Float) = 20
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }


    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
        }
        LOD 100
        Cull Back
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
        ZTest LEqual
        ZWrite Off

        HLSLINCLUDE

            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"



            // Structs
			struct Attributes 
            {
				float4 positionOS	: POSITION;
				float2 uv		    : TEXCOORD0;
				float4 color		: COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings 
            {
				float4 positionCS 	: SV_POSITION;
				float2 uv		    : TEXCOORD0;
                float4 particleData : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
			};



            CBUFFER_START(UnityPerMaterial)
                half3 _EmitterDimensions;
                half _ParticleStartSize;
                half _ParticleEndSize;
                half _ParticleSpeed;
                half _DebugTime;
                half _ManualTime;
                half3 _ParticleDirectional;
                half _ParticleSpead;
                half _ParticleVelocityStart;
                half _ParticleVelocityEnd;
                half3 _Wind;
                half3 _Gravityy;
                half _Rotation;
                half _RotationRandomOffset;
                half _RotationSpeed;
                half _RandomizeRotationDirection;
                half2 _FlipBookDimenions;
                float _FlipX;
                float _FlipY;
                half _MatchParticlePhase;
                half _FlipBookSpeed;
                float4 _FlipBook_TexelSize;
                half _Opacity;
                half _FadeInPower;
                half _FadeOutPower;
                half _UseTextureRGBAlpha;
                half _TextureAlphaSmoothstep;
                half _UseTextureAlpha;
                half4 _StartColor;
                half4 _EndColor;

                float4 _FlipBook_ST;
            CBUFFER_END
            

            TEXTURE2D(_FlipBook);
			SAMPLER(sampler_FlipBook);



            float3 BillbordFaceCamera(float3 PositionOS, float Scale)
            {
                float3 _Object_Scale = float3(length(float3(UNITY_MATRIX_M[0].x, UNITY_MATRIX_M[1].x, UNITY_MATRIX_M[2].x)),
                                             length(float3(UNITY_MATRIX_M[0].y, UNITY_MATRIX_M[1].y, UNITY_MATRIX_M[2].y)),
                                             length(float3(UNITY_MATRIX_M[0].z, UNITY_MATRIX_M[1].z, UNITY_MATRIX_M[2].z)));


                float3 tempPos = PositionOS * _Object_Scale * Scale;
                float3 worldPos = GetAbsolutePositionWS(UNITY_MATRIX_M._m03_m13_m23);

                float4 tempPosForTransform = float4(tempPos, 0);
                float3 OutMatrix = mul(UNITY_MATRIX_I_V, tempPosForTransform).xyz + worldPos;

                float3 res = TransformWorldToObject(OutMatrix);
                return res;
            }


            float3 Hash33(float3 InVector3)
            {
                uint3 v = (uint3) (int3) round(InVector3);
                v.x ^= 110351U;
                v.y ^= v.x + v.z;
                v.y = v.y * 134;
                v.z += v.x ^ v.y;
                v.y += v.x ^ v.z;
                v.x += v.y * v.z;
                v.x = v.x * 0x27d4eb2du;
                v.z ^= v.x << 3;
                v.y += v.z << 3; 
                float3 Out = v * (1.0 / float(0xffffffff));
                return Out;
            }

            half3 GetLifeTime(half _DebugTime, half _ManualTime, half _ParticleLifeSpeed, half offset)
            {
                
                half lifeTime;
    
                if (_DebugTime)
                {
                    lifeTime = _ManualTime;
                }
                else
                {
                    lifeTime = _Time.y * _ParticleLifeSpeed;
                }

                lifeTime += offset;

                half lifeTimeFrac = frac(lifeTime);
                half lifeTimeCeil = ceil(lifeTime);

                half3 result = half3(lifeTime, lifeTimeFrac, lifeTimeCeil);

                return result;
            }

            float Remap_float(float In, float2 InMinMax, float2 OutMinMax)
            {
                float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }

            float3 RotateAboutAxis_Degrees_float(float3 In, float3 Axis, float Rotation)
            {
                Rotation = radians(Rotation);
                float s = sin(Rotation);
                float c = cos(Rotation);
                float one_minus_c = 1.0 - c;

                Axis = normalize(Axis);
                float3x3 rot_mat =
                {   one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
                    one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
                    one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
                };
                float3 Out = mul(rot_mat,  In);
                return Out;
            }


            void Unity_Flipbook_float(float2 UV, float Width, float Height, float Tile, float2 Invert, out float2 Out)
            {
                Tile = floor(fmod(Tile + float(0.00001), Width*Height));
                float2 tileCount = float2(1.0, 1.0) / float2(Width, Height);
                float base = floor((Tile + float(0.5)) * tileCount.x);
                float tileX = (Tile - Width * base);
                float tileY = (Invert.y * Height - (base + Invert.y * 1));
                Out = (UV + float2(tileX, tileY)) * tileCount;
            }

            float2 GetflipBookUV(half FlipbookSpeed, half MatchParticlePhase, half2 FlipBookDimenions, half RandHalf, half ParticleLife, float2 UV)
            {
                half FlipBookRandPos = frac(FlipbookSpeed * _Time.y) + RandHalf;
                half FlipbookSize = FlipBookDimenions.x * FlipBookDimenions.y - 1;
                half FlipBookPos;

                if (MatchParticlePhase)
                {
                    FlipBookPos = ParticleLife * FlipbookSize;
                }
                else
                {
                    FlipBookPos = FlipBookRandPos * FlipbookSize;
                }
                float2 resUV;
                
                float2 _Flipbook_Invert = float2(_FlipX, _FlipY);
                Unity_Flipbook_float(UV, FlipBookDimenions.x, FlipBookDimenions.y, FlipBookPos, _Flipbook_Invert, resUV);


                return resUV;    
            }
            




            Varyings UnlitPassVertex(Attributes IN) 
            {
				Varyings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                
                float3 HashedHash3 = Hash33((IN.color.rrr ) * 255);
                half3 lifeTime = GetLifeTime(_DebugTime, _ManualTime, _ParticleSpeed, IN.color.r + HashedHash3.x);
                HashedHash3 = Hash33((IN.color.rrr + lifeTime.z) * 255); //re
                float3 ExtendedHash3 = HashedHash3 * 2 - 1;

                float SpreadRemapped = Remap_float(_ParticleSpead, float2(0, 360), float2(0, 2));
                float3 DirectionToMove = normalize(SpreadRemapped * ExtendedHash3 + _ParticleDirectional);
                float3 VelocityNow = lerp(_ParticleVelocityStart, _ParticleVelocityEnd, lifeTime.y);

                
                float3 GravityAndWind = TransformWorldToObject(_Wind + _Gravityy + GetAbsolutePositionWS(UNITY_MATRIX_M._m03_m13_m23)) * lifeTime.y;

                float3 MoveAndVelocity = (DirectionToMove * VelocityNow + GravityAndWind) * lifeTime.y;
                float3 SpawnPoint = _EmitterDimensions * ExtendedHash3;

                float3 PositionToAdd = MoveAndVelocity + SpawnPoint;

                float RotationRandDir = sign(ExtendedHash3.r);
                float RotationRandOffset = ExtendedHash3.g * 180;
                float RotationAmount = _RotationSpeed * _Time.y + _Rotation;
                if (_RotationRandomOffset)
                {
                    RotationAmount += RotationRandOffset;
                }
                if (_RandomizeRotationDirection)
                {
                    RotationAmount *= RotationRandDir;
                }

                float3 RotatedPos = RotateAboutAxis_Degrees_float(IN.positionOS.xyz, float3(0,0,1), RotationAmount);


                float Scale = lerp(_ParticleStartSize, _ParticleEndSize, lifeTime.y);


                float2 flipbookUV = GetflipBookUV(_FlipBookSpeed, _MatchParticlePhase, _FlipBookDimenions, HashedHash3.g, lifeTime.y, IN.uv);

                float fadeIn = pow(lifeTime.y, _FadeInPower);
                float fadeOut = pow(1 - lifeTime.y, _FadeInPower);
                float fadeInAndOut = saturate(fadeIn * fadeOut * _Opacity);

                
                OUT.positionCS = TransformObjectToHClip(BillbordFaceCamera(RotatedPos, Scale) + PositionToAdd);
                OUT.uv = IN.uv;
                OUT.particleData = float4(flipbookUV.x, flipbookUV.y, lifeTime.y, fadeInAndOut);
				return OUT;
			}




			// Fragment Shader
			half4 UnlitPassFragment(Varyings IN) : SV_Target 
            {
				half4 baseMap = SAMPLE_TEXTURE2D(_FlipBook, sampler_FlipBook, IN.particleData.xy);

                half4 ColorToAdd = lerp(_StartColor, _EndColor, IN.particleData.z);
                float alph;
                if (_UseTextureRGBAlpha)
                {
                    float baseMapAlph = smoothstep(0, _TextureAlphaSmoothstep, (baseMap.r + baseMap.g + baseMap.b) / 3);
                    alph = IN.particleData.a * baseMapAlph * ColorToAdd.a;
                }
                else if (_UseTextureAlpha)
                {
                     alph = IN.particleData.a * baseMap.a * ColorToAdd.a;
                }
                else
                {
                    alph = IN.particleData.a * ColorToAdd.a;
                }

                clip(baseMap - 0.04); 
				return half4(baseMap.rgb * ColorToAdd, alph);
			}

        ENDHLSL

        Pass
        {
            Name "VFX Pass"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha


            HLSLPROGRAM

                #pragma vertex UnlitPassVertex
                #pragma fragment UnlitPassFragment

            ENDHLSL
        }

        Pass {
	        Name "ShadowCaster"
	        Tags { "LightMode"="ShadowCaster" }

	        Cull Back
            ZTest LEqual
            ZWrite On

	        HLSLPROGRAM
	            #pragma vertex UnlitPassVertex
	            #pragma fragment ShadowPassFragment

	            // Material Keywords
	            #pragma shader_feature _ALPHATEST_ON
	            #pragma shader_feature _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

	            // GPU Instancing
	            #pragma multi_compile_instancing
	            // (Note, this doesn't support instancing for properties though. Same as URP/Lit)
	            // #pragma multi_compile _ DOTS_INSTANCING_ON

	            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
	            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
	            //#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"

                half4 ShadowPassFragment(Varyings input) : SV_TARGET
                {
                    UNITY_SETUP_INSTANCE_ID(input);
                    half4 baseMap = SAMPLE_TEXTURE2D(_FlipBook, sampler_FlipBook, input.particleData.xy);

                    #if defined(_ALPHATEST_ON)
                        Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, _Cutoff);
                    #endif

                    #if defined(LOD_FADE_CROSSFADE)
                        LODFadeCrossFade(input.positionCS);
                    #endif
                    clip(baseMap - 0.04);

                    return 0;
                }

	        ENDHLSL
        }

        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
            // Render State
            Cull Off
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
                // Pragmas
                #pragma target 2.0
                #pragma vertex UnlitPassVertex
                #pragma fragment frag
        

                #define SCENESELECTIONPASS
                //#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

                #ifdef SCENEPICKINGPASS
                float4 _SelectionID;
                #endif
        
                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                int _ObjectId;
                int _PassValue;
                #endif



                half4 frag(Varyings input) : SV_TARGET
                {
                    Varyings unpacked = input;
                    UNITY_SETUP_INSTANCE_ID(unpacked);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(unpacked);
                    //SurfaceDescription surfaceDescription = BuildSurfaceDescription(unpacked);
                    half4 baseMap = SAMPLE_TEXTURE2D(_FlipBook, sampler_FlipBook, input.particleData.xy);
                    clip(baseMap - 0.04);
                

                    half4 outColor = 0;
                    #ifdef SCENESELECTIONPASS
                        // We use depth prepass for scene selection in the editor, this code allow to output the outline correctly
                        outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
                    #elif defined(SCENEPICKINGPASS)
                        outColor = unity_SelectionID;
                    #endif

                    return outColor;
                }

            ENDHLSL

        }


        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
            // Render State
            Cull Back
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
                // Pragmas
                #pragma target 2.0
                #pragma vertex UnlitPassVertex
                #pragma fragment frag
        
        
                // Defines
        
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_COLOR
                #define FEATURES_GRAPH_VERTEX
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define SCENEPICKINGPASS 1
                #define ALPHA_CLIP_THRESHOLD 1
                #define _ALPHATEST_ON 1
        

                #ifdef SCENEPICKINGPASS
                    float4 _SelectionID;
                #endif
        
                // -- Properties used by SceneSelectionPass
                #ifdef SCENESELECTIONPASS
                    int _ObjectId;
                    int _PassValue;
                #endif

                half4 frag(Varyings input) : SV_TARGET
                {
                    Varyings unpacked = input;
                    UNITY_SETUP_INSTANCE_ID(unpacked);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(unpacked);
                    half4 baseMap = SAMPLE_TEXTURE2D(_FlipBook, sampler_FlipBook, input.particleData.xy);
                    clip(baseMap - 0.04);
                

                    half4 outColor = 0;
                    #ifdef SCENESELECTIONPASS
                        // We use depth prepass for scene selection in the editor, this code allow to output the outline correctly
                        outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
                    #elif defined(SCENEPICKINGPASS)
                        outColor = unity_SelectionID;
                    #endif

                    return outColor;
                }

            ENDHLSL
        }


        
        

    }
    FallBack "Diffuse"
}
