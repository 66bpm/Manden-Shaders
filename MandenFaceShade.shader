Shader "Manden/MandenFaceShade"
{
    Properties
    {
        _ShadeColor("Color", Color) = (0.0,0.0,0.0,0.0)
        [PowerSlider] _VHighPos("High V Pos", Range(0, 1.0)) = 0.5
        [PowerSlider] _VLowPos("Low V Pos", Range(0, 1.0)) = 0.3
        [PowerSlider] _Alpha("Alpha", Range(0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        Lighting Off 
        Cull Off 
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Interpolation.cginc"

            float4 _ShadeColor;
            float _VHighPos;
            float _VLowPos;
            float _Alpha;
            float _ControlAlpha;

            struct appdata
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.pos = UnityObjectToClipPos(v.pos);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = _ShadeColor;
                col.a = (step(_VLowPos, i.uv.y)*step(i.uv.y, _VHighPos)*remap(_VLowPos, _VHighPos, 0.0, col.a, i.uv.y)) + (step(_VHighPos, i.uv.y)*col.a);
                col.a *= _Alpha;
                return col;
            }
            ENDCG
        }
    }
}
