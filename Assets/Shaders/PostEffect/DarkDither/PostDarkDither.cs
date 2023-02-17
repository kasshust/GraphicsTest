using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;

[System.Serializable]
public class PostDarkDither : VolumeComponent, IPostProcessComponent
{
    public BoolParameter Avtive = new BoolParameter(true);

    [field: SerializeField]   public TextureParameter   NoiseTexture  = new TextureParameter(null);
    [field: SerializeField]   public ColorParameter     BlendColor      = new ColorParameter(Color.black);
    [field: SerializeField]   public Vector2Parameter   NoiseTiling   = new Vector2Parameter(Vector2.zero);
    public bool IsActive() => Avtive.value == true;

    public bool IsTileCompatible() => false;
}