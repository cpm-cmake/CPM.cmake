#include <pxr/imaging/garch/glApi.h>
#include <pxr/imaging/glf/contextCaps.h>
#include <pxr/imaging/glf/diagnostic.h>
#include <pxr/imaging/glf/glContext.h>
#include <pxr/imaging/hgi/blitCmdsOps.h>
#include <pxr/imaging/hgiGL/hgi.h>
#include <pxr/imaging/hio/image.h>

// GLFW (include after pxr/imaging/garch/glApi.h)
#include <GLFW/glfw3.h>

PXR_NAMESPACE_USING_DIRECTIVE

static const int _imgSize = 512;
static const HgiFormat _imgFormat = HgiFormatUNorm8Vec4;
static const HioFormat _imgHioFormat = HioFormatUNorm8Vec4;

void _SaveToPNG(int width, int height, const char* pixels, const std::string& filePath) {
  HioImage::StorageSpec storage;
  storage.width = width;
  storage.height = height;
  storage.format = _imgHioFormat;
  storage.flipped = false;
  storage.data = (void*)pixels;

  HioImageSharedPtr image = HioImage::OpenForWriting(filePath);
  TF_VERIFY(image && image->Write(storage));
}

void _SaveGpuTextureToFile(HgiGL& hgiGL, HgiTextureHandle const& texHandle, int width, int height,
                           HgiFormat format, std::string const& filePath) {
  // Copy the pixels from gpu into a cpu buffer so we can save it to disk.
  const size_t bufferByteSize = width * height * HgiGetDataSizeOfFormat(format);
  std::vector<char> buffer(bufferByteSize);

  HgiTextureGpuToCpuOp copyOp;
  copyOp.gpuSourceTexture = texHandle;
  copyOp.sourceTexelOffset = GfVec3i(0);
  copyOp.mipLevel = 0;
  copyOp.cpuDestinationBuffer = buffer.data();
  copyOp.destinationByteOffset = 0;
  copyOp.destinationBufferByteSize = bufferByteSize;

  HgiBlitCmdsUniquePtr blitCmds = hgiGL.CreateBlitCmds();
  blitCmds->CopyTextureGpuToCpu(copyOp);
  hgiGL.SubmitCmds(blitCmds.get(), HgiSubmitWaitTypeWaitUntilCompleted);

  _SaveToPNG(width, height, buffer.data(), filePath);
}

HgiGraphicsCmdsDesc _CreateGraphicsCmdsColor0Color1Depth(HgiGL& hgiGL, GfVec3i const& size,
                                                         HgiFormat colorFormat) {
  // Create two color attachments
  HgiTextureDesc texDesc;
  texDesc.dimensions = size;
  texDesc.type = HgiTextureType2D;
  texDesc.format = colorFormat;
  texDesc.sampleCount = HgiSampleCount1;
  texDesc.usage = HgiTextureUsageBitsColorTarget;
  HgiTextureHandle colorTex0 = hgiGL.CreateTexture(texDesc);
  HgiTextureHandle colorTex1 = hgiGL.CreateTexture(texDesc);

  // Create a depth attachment
  texDesc.usage = HgiTextureUsageBitsDepthTarget;
  texDesc.format = HgiFormatFloat32;
  HgiTextureHandle depthTex = hgiGL.CreateTexture(texDesc);

  // Setup color and depth attachments
  HgiAttachmentDesc colorAttachment0;
  colorAttachment0.loadOp = HgiAttachmentLoadOpClear;
  colorAttachment0.storeOp = HgiAttachmentStoreOpStore;
  colorAttachment0.format = colorFormat;
  colorAttachment0.usage = HgiTextureUsageBitsColorTarget;

  HgiAttachmentDesc colorAttachment1;
  colorAttachment1.loadOp = HgiAttachmentLoadOpClear;
  colorAttachment1.storeOp = HgiAttachmentStoreOpStore;
  colorAttachment1.format = colorFormat;
  colorAttachment1.usage = HgiTextureUsageBitsColorTarget;

  HgiAttachmentDesc depthAttachment;
  depthAttachment.format = HgiFormatFloat32;
  depthAttachment.usage = HgiTextureUsageBitsDepthTarget;

  // Configure graphics cmds
  HgiGraphicsCmdsDesc desc;
  desc.colorAttachmentDescs.push_back(colorAttachment0);
  desc.colorAttachmentDescs.push_back(colorAttachment1);
  desc.depthAttachmentDesc = depthAttachment;
  desc.colorTextures.push_back(colorTex0);
  desc.colorTextures.push_back(colorTex1);
  desc.depthTexture = depthTex;

  return desc;
}

bool TestGraphicsCmdsClear() {
  HgiGL hgiGL;

  const size_t width = _imgSize;
  const size_t height = _imgSize;
  const HgiFormat format = _imgFormat;

  // Create a default cmds description and set the clearValue for the
  // first attachment to something other than black.
  // Setting 'loadOp' tp 'Clear' is important for this test since we expect
  // the attachment to be cleared when the graphics cmds is created.
  HgiGraphicsCmdsDesc desc
      = _CreateGraphicsCmdsColor0Color1Depth(hgiGL, GfVec3i(width, height, 1), format);
  desc.colorAttachmentDescs[0].loadOp = HgiAttachmentLoadOpClear;
  desc.colorAttachmentDescs[0].storeOp = HgiAttachmentStoreOpStore;
  desc.colorAttachmentDescs[0].clearValue = GfVec4f(1, 0, 0.5, 1);

  // We expect attachment0 to be cleared when the cmds is created via
  // the loadOp property in desc.
  HgiGraphicsCmdsUniquePtr gfxCmds = hgiGL.CreateGraphicsCmds(desc);
  hgiGL.SubmitCmds(gfxCmds.get());

  // Save attachment0 to disk
  _SaveGpuTextureToFile(hgiGL, desc.colorTextures[0], width, height, format,
                        "CPMExampleOpenUSD.png");

  // Cleanup
  for (HgiTextureHandle& tex : desc.colorTextures) {
    hgiGL.DestroyTexture(&tex);
  }
  if (desc.depthTexture) {
    hgiGL.DestroyTexture(&desc.depthTexture);
  }

  return true;
}

class ScopeExit {
public:
  explicit ScopeExit(const std::function<void()>& f) : func(f) {}
  ~ScopeExit() { func(); }

private:
  std::function<void()> func;
};

int main(int argc, char** argv) {
  if (!glfwInit()) return EXIT_FAILURE;

  // Offscreen contexts (https://www.glfw.org/docs/latest/context.html#context_offscreen)
  glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE);
  GLFWwindow* window = glfwCreateWindow(100, 100, "CPMExampleOpenUSD", NULL, NULL);
  glfwMakeContextCurrent(window);
  ScopeExit onExit([window]() { glfwDestroyWindow(window); });

  if (!GarchGLApiLoad()) return EXIT_FAILURE;
  GlfRegisterDefaultDebugOutputMessageCallback();
  GlfSharedGLContextScopeHolder sharedContext;
  GlfContextCaps::InitInstance();
  if (!TestGraphicsCmdsClear()) return EXIT_FAILURE;
  return EXIT_SUCCESS;
}
