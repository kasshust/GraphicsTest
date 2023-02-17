using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;

[System.Serializable]
public class RadBlur : VolumeComponent, IPostProcessComponent
{
    public BoolParameter Enable = new BoolParameter(true);

    [field: SerializeField, Range(0, 10)] public FloatParameter Samples = new FloatParameter(0f);
    [field: SerializeField, Range(0, 100)] public FloatParameter BlurStrength = new FloatParameter(0f);
    [field: SerializeField] public Vector2Parameter Center { get; set; } = new Vector2Parameter(Vector2.zero);

    public bool IsActive() => BlurStrength.value > 0.0f;

    public bool IsTileCompatible() => false;
}