using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class RenderDepthFeature : ScriptableRendererFeature
{
    class CustomRenderPass : ScriptableRenderPass
    {
        public Material material; // レンダリングに使用するマテリアル

        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (material == null) return;

            var camera = renderingData.cameraData.camera; // 現在レンダリングを行っているカメラ
            var cmd = CommandBufferPool.Get("RenderDepth"); // 適当なコマンドバッファをとってくる
            cmd.Blit(Texture2D.whiteTexture, camera.activeTexture, material); // カメラにマテリアルを適用

            context.ExecuteCommandBuffer(cmd); // コマンドバッファ実行
            context.Submit();
        }
    }

    CustomRenderPass m_ScriptablePass;

    public override void Create()
    {
        m_ScriptablePass = new CustomRenderPass();
        m_ScriptablePass.material = Resources.Load<Material>("Material/RenderDepthMat"); 
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRendering + 2;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}