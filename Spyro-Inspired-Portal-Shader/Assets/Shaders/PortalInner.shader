// Main part of the portal shader, the inner part that creates the final look of the portal.
//  All effects are applied on this shader.

Shader "DP/Spyro/PortalInner"
{
    Properties
    {
        _DistortTexture("Distortion Texture", 2D) = "white" {}
        _DistortSpeed("Distortion Scroll Speed", float) = 2
        _DistortStrength("Distortion Strength", float) = 5
        _OutlineColor("Outline Color (RGB)", Color) = (0, 1, 0, 1)
        _OutlineStrength("Outline Strength", float) = 8
        _OutlineThresholdMax("Outline Threshold Max", float) = 1
        _FadeDistance("Distortion Fade Start Distance", float) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        

        CGPROGRAM
        #pragma surface surf NoLighting noshadow vertex:vert
        #pragma target 3.5

        sampler2D _PortalBackground;
        sampler2D _DistortTexture;
        sampler2D _CameraDepthTexture;

        float4 _DistortTexture_ST;

        float _DistortSpeed;
        float _DistortStrength;

        float4 _OutlineColor;
        float _OutlineThresholdMax;
        float _OutlineStrength;

        float _FadeDistance;

        struct Input
        {
            float4 vertex;

            // The reason why distrotUV is a float4 and not float2 is because it contains two UVs;
            //  channels "xy" contain one set of UVs, and channels "zw" contain a second set of UVs.
            float4 distortUV;
            float4 backgroundUV;
            float4 screenPos;
            float3 worldPos;
        };

        fixed4 LightingNoLighting(SurfaceOutput s, fixed3 lightDir, fixed atten)
        {
            fixed4 c;
            c.rgb = s.Albedo;
            c.a = s.Alpha;
            return c;
        }

        void vert (inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            o.vertex = UnityObjectToClipPos(v.vertex);
            o.screenPos = ComputeScreenPos(o.vertex);

            // To get the UVs for portal background, we need to use the built-in ComputeGrabScreenPos()
            //  function, to display the result from portal blocker's grab pass properly.
            o.backgroundUV = ComputeGrabScreenPos(o.vertex);

            // DISTORTION UVs : TRANSFORM_TEX only needs to be done once, and we can apply the same result
            //  to other channels to get the same distortion texture twice with different animations.
            o.distortUV.xy = TRANSFORM_TEX(v.texcoord, _DistortTexture);
            o.distortUV.zw = o.distortUV.xy;
            
            // Animating the distortion UVs using Unity's built in "_Time.x" variable.
            o.distortUV.y -= _DistortSpeed * _Time.x;
            o.distortUV.z += _DistortSpeed * _Time.x;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // --- Distortion Effect : Using a texture to distort the background of portal,
            //  and create the waves effect as seen in original shader.
            float2 distortTexture = UnpackNormal(tex2D(_DistortTexture, IN.distortUV.xy)).xy;
            float2 distortTexture2 = UnpackNormal(tex2D(_DistortTexture, IN.distortUV.zw)).xy;
            distortTexture *= _DistortStrength / 100;
            distortTexture2 *= _DistortStrength / 100;

            float combinedDistortion = distortTexture + distortTexture2;

            // --- Background UVs : In order to use the grab pass texture, we need to calculate
            //  the correct UV coordinates; in order to do that we use the screen position that
            //  Unity calculates for us; we add the distortion to the UVs and multiply it by the
            //  fade value to scale the effect down at a distance.

            float4 portalBackgroundUV = IN.backgroundUV;
            float fade = 1 - saturate(fwidth(portalBackgroundUV) * _FadeDistance);
            //portalBackgroundUV.xy += combinedDistortion * fade * IN.backgroundUV;
            portalBackgroundUV.xy += combinedDistortion;

            fixed4 grabPassTexture = tex2Dproj(_PortalBackground, UNITY_PROJ_COORD(portalBackgroundUV));

            // --- Outline Effect : In order to create the portal outline effect, we need access
            //  to the depth texture that is created by our camera (see attached script); we then get
            //  the scene depth, object depth and get the difference and calculate the intersection
            //  based on the depth difference. Finally we add colour to the outline.

            float sceneDepth = 
                LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos)));
            float surfaceDepth = -mul(UNITY_MATRIX_V, float4(IN.worldPos.xyz, 1)).z;
            float difference = sceneDepth - surfaceDepth;
            float intersect = 0;

            if (difference > 0)
                intersect = 1 - saturate(difference / _OutlineThresholdMax);

            float4 intersectColor = (intersect * _OutlineStrength) * _OutlineColor;
            fixed4 finalColor = grabPassTexture + intersectColor;

            // --- Applying the final color to the shader albedo channel.

            o.Albedo = finalColor;
        }
        ENDCG
    }
}