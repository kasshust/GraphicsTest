using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostDitherFeature : ScriptableRendererFeature
{

     [field: SerializeField] public bool Active { get; set; } = false;
     [field: SerializeField, Range(0, 1)] public float Weight { get; set; } = 1f;

    PostDitherPass postProcessGraphPass;

    public override void Create()
    {
        postProcessGraphPass = new PostDitherPass(RenderPassEvent.BeforeRenderingPostProcessing);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        postProcessGraphPass.Setup(renderer.cameraColorTarget);
        postProcessGraphPass.Active = Active;
        postProcessGraphPass.Weight = Weight;
        renderer.EnqueuePass(postProcessGraphPass);
    }
}