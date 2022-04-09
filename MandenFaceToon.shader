Shader "Manden/MandenFaceToon"
{
    Properties
    {
        [Header(Diffuse_Property)]
        _MainTex ("Base", 2D) = "white" {}
        _SSSTex ("SSS", 2D) = "white" {}

        [PowerSlider(3.0)] _WhiteLevel("White Level", Range(0, 1.0)) = 0.2
        [PowerSlider(3.0)] _Size("Size", Range(0, 1.0)) = 0.65
        [PowerSlider(3.0)] _Smooth("Smooth", Range(0, 1.0)) = 0.0

        [Space(10)]
        [Header(Outline)]

        [PowerSlider(3.0)] _OutlineThickness("Thickness", Range(0, 5.0)) = 1.0
        _OutlineColor("Color", Color) = (0.0,0.0,0.0,0.0)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent" 
        }
            
        LOD 200
        Cull Off

        Pass
        {
            Tags {
                "LightMode"="ForwardBase"
            }
            Stencil
            {
                 Ref 1
                 Comp Always
                 Pass Replace
            }
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Interpolation.cginc"

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"
            
            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1)
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SSSTex;
            float4 _SSSTex_ST;

            fixed _WhiteLevel;
            fixed _Size;
            fixed _Smooth;

            float4 FaceToon(float4 base, float4 sss, fixed shadow) 
            {
                float invSize = 1 - _Size;
                float smoothness = max(0.03, _Smooth);

                float r1 = remap(0.0, _WhiteLevel, 0.0, 1.0, shadow);
                float r2 = remap(invSize, invSize + smoothness, 0.0, 1.0, r1);
                float4 col = (clamp(1.0 - r2, 0.0, 1.0) * sss) + (clamp(r2, 0.0, 1.0) * base);
                col.a = 1.0;
                return col;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 base = tex2D(_MainTex, i.uv) ;
                float4 sss = tex2D(_SSSTex, i.uv);
                fixed shadow = SHADOW_ATTENUATION(i);
                float4 col = FaceToon(base, sss, shadow);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
        Pass {
            Tags {"Queue" = "Geometry"}
            Stencil {
                Ref 1
                Comp NotEqual
            }
           
            Cull Off
       
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            half _OutlineThickness;
            fixed4 _OutlineColor;

            struct v2f {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_base v) {
                v2f o;
                v.vertex.xyz += v.normal * _OutlineThickness / 100;
                o.pos = UnityObjectToClipPos (v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
