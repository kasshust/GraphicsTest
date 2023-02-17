using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;

[System.Serializable]
public class PostDither : VolumeComponent, IPostProcessComponent
{
    public BoolParameter testTrigger = new BoolParameter(true);

    [Range(0f, 100f), Tooltip("tool tip")]
    public FloatParameter testFloat = new FloatParameter(0f);

    public bool IsActive() => testTrigger.value == true;

    public bool IsTileCompatible() => false;
}