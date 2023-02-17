using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RenderDepthSimple : VolumeComponent, IPostProcessComponent
{
    public BoolParameter trigger = new BoolParameter(true);

    public bool IsActive() => trigger.value == true;

    public bool IsTileCompatible() => false;
}