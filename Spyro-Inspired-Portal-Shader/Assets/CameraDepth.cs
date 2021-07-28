using UnityEngine;

[ExecuteInEditMode]
public class CameraDepth : MonoBehaviour
{
    private Camera cam;

    private void OnEnable()
    {
        cam = GetComponent<Camera>();
        cam.depthTextureMode = DepthTextureMode.DepthNormals;
    }
}