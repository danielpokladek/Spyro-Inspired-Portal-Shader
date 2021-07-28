// Used to block out the geometry of the 3D model used for the portal;
//  without this you'd be able to see the portal model through the actual portal.

// Additionally, this also uses "GrabPass", to capture what is behind this object,
//  this way we can display it on the final layer of the portal shader.

Shader "DP/Spyro/PortalBlocker"
{
    Properties
    {
        _StencilMask("Stencil Mask Layer", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry-2" }
        GrabPass { "_PortalBackground" }
        
        ColorMask 0
        ZWrite Off

        Stencil
        {
            Ref[_StencilMask]
            Comp Equal
            Pass Replace
        }

        CGPROGRAM
        #pragma surface surf NoLighting noshadow
        #pragma target 3.0

        struct Input
        {
            float2 worldPos;
        };

        // This face shouldn't be affected by the light, so I just use a simple lighting model
        //  which passes the values through and doesn't change any of them.
        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo;
            c.a = s.Alpha;
            return c;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = float4(1, 0, 1, 1);
        }
        ENDCG
    }
}
