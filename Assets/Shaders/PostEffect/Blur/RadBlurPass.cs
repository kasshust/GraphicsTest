using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RadBlurPass : ScriptableRenderPass
{

    static readonly string k_RenderTag = "Render Blur Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTargetTestProcess");

    RadBlur postProcessGraph;
    Material postProcessGraphMaterial;
    RenderTargetIdentifier currentTarget;

    public bool Active { get; set; }
    public float Samples{ get; set; }
    public float BlurStrength { get; set; }
    public Vector2 Center { get; set; }

    public RadBlurPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("PostEffect/RadBlur"); // ここパスかえる
        if (shader == null)
        {
            return;
        }
        postProcessGraphMaterial = CoreUtils.CreateEngineMaterial(shader);
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
    {
        if (!Active) { return; }

        if (postProcessGraphMaterial == null)
        {
            Debug.LogError("Material not created.");
            return;
        }

        if (!renderingData.cameraData.postProcessEnabled) return;

        var stack = VolumeManager.instance.stack;
        postProcessGraph = stack.GetComponent<RadBlur>();
        if (postProcessGraph == null) { return; }
        if (!postProcessGraph.IsActive()) { return; }

        postProcessGraphMaterial.SetFloat("_BlurSamples", postProcessGraph.Samples.value);
        postProcessGraphMaterial.SetFloat("_BlurStrength", postProcessGraph.BlurStrength.value);
        postProcessGraphMaterial.SetVector("_Center", postProcessGraph.Center.value);

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
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.DefaultHDR);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, postProcessGraphMaterial, shaderPass);
    }
}