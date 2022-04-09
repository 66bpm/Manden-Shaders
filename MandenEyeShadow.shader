Shader "Manden/MandenEyeShadow"
{
    Properties
    {
        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        [PowerSlider(3.0)] _Alpha("Alpha", Range(0, 1.0)) = 0.5
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

            float _Alpha;
            float4 _Color;

            struct appdata
            {
                float4 pos : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.pos);
                return o;
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = _Color;
                col.a = _Alpha;
                return col;
            }
            ENDCG
        }
    }
}
