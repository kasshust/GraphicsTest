using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RadBlurFeature : ScriptableRendererFeature
{
    // ここ無効
    [field: SerializeField] public bool Active { get; set; } = false;
    [field: SerializeField, Range(0, 10)] public float Samples { get; set; } = 6f;
    [field: SerializeField, Range(0, 100)] public float BlurStrength { get; set; } = 0f;
    [field: SerializeField] public Vector2 Center { get; set; }


    RadBlurPass postProcessGraphPass;

    public override void Create()
    {
        postProcessGraphPass = new RadBlurPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        postProcessGraphPass.Setup(renderer.cameraColorTarget);
        postProcessGraphPass.Active         = Active;
        postProcessGraphPass.Samples        = Samples;
        postProcessGraphPass.BlurStrength   = BlurStrength;
        postProcessGraphPass.Center         = Center;
        renderer.EnqueuePass(postProcessGraphPass);
    }
}