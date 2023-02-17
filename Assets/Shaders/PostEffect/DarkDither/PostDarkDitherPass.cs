using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostDarkDitherPass : ScriptableRenderPass
{

    static readonly string k_RenderTag = "Render testProcess Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTargetTestProcess");

    PostDarkDither postProcessGraph;
    Material postProcessGraphMaterial;
    RenderTargetIdentifier currentTarget;

    public bool isActive { get; set; }

    public PostDarkDitherPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("PostEffect/PostDarkDither"); // ここパスかえる
        if (shader == null)
        {
            return;
        }
        postProcessGraphMaterial = CoreUtils.CreateEngineMaterial(shader);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (!isActive) { return; }

        if (postProcessGraphMaterial == null)
        {
            Debug.LogError("Material not created.");
            return;
        }

        if (!renderingData.cameraData.postProcessEnabled) return;

        var stack = VolumeManager.instance.stack;
        postProcessGraph = stack.GetComponent<PostDarkDither>();
        if (postProcessGraph == null) { return; }
        if (!postProcessGraph.IsActive()) { return; }

        if (postProcessGraph.NoiseTexture != null) postProcessGraphMaterial.SetTexture("_NoiseTexture",    postProcessGraph.NoiseTexture.value);
        postProcessGraphMaterial.SetVector("_NoiseTiling",      postProcessGraph.NoiseTiling.value);
        postProcessGraphMaterial.SetColor("_BlendColor",       postProcessGraph.BlendColor.value);

        var cmd = CommandBufferPool.Get(k_RenderTag);
        Render(cmd, ref renderingData);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

    public void Setup(in RenderTargetIdentifier currentTarget)
    {
        this.currentTarget = currentTarget;
    }

    void Render(CommandBuffer cmd, ref RenderingData renderingData)
    {
        ref var cameraData = ref renderingData.cameraData;
        var source = currentTarget;
        int destination = TempTargetId;

        var w = cameraData.camera.scaledPixelWidth;
        var h = cameraData.camera.scaledPixelHeight;

        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, postProcessGraphMaterial, shaderPass);
    }
}