using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostDarkDitherFeature : ScriptableRendererFeature
{
    [field: SerializeField] public bool Active { get; set; } = false;

    PostDarkDitherPass postProcessGraphPass;

    public override void Create()
    {
        postProcessGraphPass = new PostDarkDitherPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        postProcessGraphPass.Setup(renderer.cameraColorTarget);
        postProcessGraphPass.isActive = Active;
        renderer.EnqueuePass(postProcessGraphPass);
    }
}