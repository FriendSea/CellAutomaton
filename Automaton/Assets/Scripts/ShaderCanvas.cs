using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderCanvas : MonoBehaviour
{
    [SerializeField]
    int UpdateSpan = 5;
    [SerializeField]
    Material mat;
    [SerializeField]
    Texture InitialTexture;
    [SerializeField]
    RenderTexture texture;
    RenderTexture buffer;

    [SerializeField]
    GameObject Slice;
    Vector3 SlicePosition;

    void Start()
    {
        Graphics.Blit(InitialTexture, texture);
        buffer = new RenderTexture(texture.width, texture.height, texture.depth, texture.format);
        mat.SetInt("_Size", texture.width);
        if (Slice != null) SlicePosition = Slice.transform.position;
    }

    void UpdateShader()
    {
        Graphics.Blit(texture, buffer, mat);
        Graphics.Blit(buffer, texture);
    }

    int count = 0;
    int MaxSlice = 1000;
    private void Update()
    {
        count++;
        if (count < UpdateSpan) return;
        count = 0;
        UpdateShader();
        if (Slice == null) return;
        if (MaxSlice <= 0) return;

        MaxSlice--;
        SlicePosition += Vector3.up / texture.width;
        GameObject newslice = Instantiate(Slice, SlicePosition, Slice.transform.rotation);
        RenderTexture newtex = new RenderTexture(texture);
        newtex.wrapMode = TextureWrapMode.Repeat;
        Graphics.Blit(texture, newtex);
        newslice.GetComponent<Renderer>().material.mainTexture = newtex;
    }
}
