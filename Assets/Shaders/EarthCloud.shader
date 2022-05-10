Shader "Planet/EarthCloud"
{
	Properties
	{
	  _MainTex("Main Texture", 2D) = "black" {}
	  _Normals("Normals", 2D) = "black" {}

	  _CloudMap("Cloud Map", 2D) = "black" {}
	  _CloudSpeed("Cloud speed", Float) = 0.01
	  _CloudStrength("Cloud strength", Range(0, 5)) = 1.0

	  _Lights("Lights", 2D) = "black" {}
	  _LightScale("Light Scale", Float) = 1
	  _Shininess("Shininess", Range(0.03, 1)) = 0.078125
	  _AtmosNear("Atmos Near Color", Color) = (0.1686275,0.7372549,1,1)
	  _AtmosFar("Atmos Far Color", Color) = (0.4557808,0.5187039,0.9850746,1)
	  _AtmosFalloff("Atmos Falloff", Float) = 3
	}

		SubShader
	  {
		  Tags
		  {
			  "Queue" = "Geometry"
			  "IgnoreProjector" = "False"
			  "RenderType" = "Opaque"
		  }
		  LOD 250

	  CGPROGRAM
		#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd 

		  #pragma target 2.0

		  sampler2D _MainTex;
		  sampler2D _Normals;

		  sampler2D _CloudMap;
		  float		_CloudSpeed;
		  half		_CloudStrength;

		  sampler2D _Lights;
		  float _LightScale;
		  float4 _AtmosNear;
		  float4 _AtmosFar;
		  float _AtmosFalloff;
		  half _Shininess;
		  
		  struct SurfOutput {
			  half3 Albedo;
			  half3 Normal;
			  half3 Emission;
			  half3 Gloss;
			  half Specular;
			  half Alpha;
			  half4 Custom;
		  };

		  struct Input {
			  float3 viewDir;
			  float2 uv_MainTex;
			  float2 uv_Normals;
			  float2 uv_Lights;
		  };

		  inline half4 LightingMobileBlinnPhong(SurfOutput s, half3 lightDir, half3 viewDir, half atten)
		  {
			  //simple light effect
			  half3 h = normalize(lightDir + viewDir);
			  fixed diff = max(0, dot(s.Normal, lightDir));
			  fixed nh = max(0, dot(s.Normal, h));
			  fixed spec = pow(nh, s.Specular * 128) * s.Gloss;

			  fixed4 c;
			  c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2);
			  c.a = 1.0;

			  half invdiff = 1 - saturate(128 * diff);
			  s.Alpha = invdiff;

			  //apply city lights on back side
			  c.rg += min(s.Custom, s.Alpha);
			  c.b += 0.75 * min(s.Custom, s.Alpha);

			  return c;
		  }

		  void surf(Input IN, inout SurfOutput o) {
			  o.Specular = _Shininess;

			  float4 Fresnel0_1_NoInput = float4(0, 0, 1, 1);
			  float4 Fresnel0 = (1.0 - dot(normalize(float4(IN.viewDir.x, IN.viewDir.y, IN.viewDir.z, 1.0).xyz), normalize(Fresnel0_1_NoInput.xyz))).xxxx;
			  float4 Pow0 = pow(Fresnel0, _AtmosFalloff.xxxx);
			  float4 Saturate0 = saturate(Pow0);
			  float4 Lerp0 = lerp(_AtmosNear, _AtmosFar, Saturate0);
			  float4 Multiply1 = Lerp0 * Saturate0;
			  float4 mainTexColor = tex2D(_MainTex, IN.uv_MainTex);
			  float4 finalColor = Multiply1 + mainTexColor;

			  // prepare cloud color
			  float2 uv = IN.uv_MainTex;
			  uv.x += _Time * _CloudSpeed;
			  fixed3 cloud = tex2D(_CloudMap, uv) * _CloudStrength;
			  fixed cloudPower = (1 - cloud.r) * (1 - cloud.r);
			  cloud += Multiply1 + mainTexColor * 0.2;
			  // apply cloud
			  finalColor.x = max(finalColor.x, cloud.x);
			  finalColor.y = max(finalColor.y, cloud.y);
			  finalColor.z = max(finalColor.z, cloud.z);
			  
			  o.Albedo = finalColor;

			  o.Normal = UnpackNormal(  lerp(  tex2D(_Normals, IN.uv_Normals.xy), float4(0.5, 0.5, 1, 1), cloud.r)  );
			  o.Emission = 0.0;

			  o.Gloss = mainTexColor.a * cloudPower;
			  o.Alpha = mainTexColor.a;

			  o.Custom = tex2D(_Lights, IN.uv_Lights.xy).r * _LightScale * cloudPower;
		  }
			ENDCG
	  }
		  FallBack "Mobile/VertexLit"
}