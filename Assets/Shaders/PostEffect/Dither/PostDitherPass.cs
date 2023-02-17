using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class PostDitherPass : ScriptableRenderPass
{

    static readonly string k_RenderTag = "Render testProcess Effects";
    static readonly int MainTexId = Shader.PropertyToID("_MainTex");
    static readonly int TempTargetId = Shader.PropertyToID("_TempTargetTestProcess");

    PostDither postProcessGraph;
    Material postProcessGraphMaterial;
    RenderTargetIdentifier currentTarget;

    public bool Active { get; set; }
    public float Weight{ get; set; }

    public PostDitherPass(RenderPassEvent evt)
    {
        renderPassEvent = evt;
        var shader = Shader.Find("PostEffect/PostDither"); // ここパスかえる
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
        postProcessGraph = stack.GetComponent<PostDither>();
        if (postProcessGraph == null) { return; }
        if (!postProcessGraph.IsActive()) { return; }

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
        
        /*
            float w = postProcessGraph.testFloat.value;
        */
        // postProcessGraphMaterial.SetFloat("_Param", Weight);

        int shaderPass = 0;
        cmd.SetGlobalTexture(MainTexId, source);
        cmd.GetTemporaryRT(destination, w, h, 0, FilterMode.Point, RenderTextureFormat.Default);
        cmd.Blit(source, destination);
        cmd.Blit(destination, source, postProcessGraphMaterial, shaderPass);
    }
}