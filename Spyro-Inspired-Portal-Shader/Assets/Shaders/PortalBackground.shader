// Used to render the background of the portal; the shader inverts normals
//  so that we can see the textures on the inside of the mesh.

Shader "DP/Spyro/PortalBackground"
{
    Properties
    {
        _MainTex ("Albedo Texture (RGB)", 2D) = "white" { }
        _BackgroundBrightness("Background Brightness", float) = 0.8
        _StencilMask ("Stencil Mask Layer", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue" = "Geometry-3" }
        // Don't display the front face, and only display the back faces.
        //  Otherwise we wouldn't see the background in the portal.
        Cull Front

        // Only display the background on the face that belongs to the portal.
        //  Setting _StencilMask to '0' will display the mesh all the time.
        Stencil
        {
            Ref[_StencilMask]
            Comp equal
        }

        CGPROGRAM
        #pragma surface surf NoLighting vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;

        float _BackgroundBrightness;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo;
            c.a = s.Alpha;
            return c;
        }

        void vert(inout appdata_full v)
        {
            // Invert the normal to face the opposite direction, this way
            //  the mesh will render on the inside rather than the outside.
            v.normal.xyz = v.normal * -1;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb * _BackgroundBrightness;
        }

        ENDCG
    }
}
