Shader "DP/Spyro/PortalBackground"
{
    Properties
    {
        _StencilMask ("Stencil Mask Layer", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry-3" }
        ColorMask 0
        ZWrite Off

        Stencil
        {
            Ref [_StencilMask]
            Comp Always
            Pass Replace
        }

        CGPROGRAM
        #pragma surface surf Lambert noshadow
        #pragma target 3.0
        
        struct Input
        {
            float4 vertex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = fixed3(1, 0, 1);
        }

        ENDCG
    }
}
