# vllm-omni

[vLLM-Omni](https://github.com/vllm-project/vllm-omni) is an omni-modality model
serving framework that extends vLLM to support text, image, video, audio, and
interactive world model inference.

## Introduction

This chart deploys vLLM-Omni on a Kubernetes cluster, providing:

- **OpenAI-compatible API** for omni-modality inference
- **World Model support** (RFC #1987) for robotics control and interactive video/simulation
- **GPU-optimized deployment** with configurable resource limits
- **Persistent storage** for Hugging Face model cache
- **Flexible configuration** for model selection, quantization, and parallelism

## Prerequisites

- Kubernetes 1.24+
- Helm 3.2+
- NVIDIA GPU with CUDA support (or ROCm / Ascend NPU)
- NVIDIA GPU Operator or device plugin installed
- Sufficient GPU memory for the selected model

## Installing the Chart

```bash
helm install my-vllm-omni ./vllm-omni \
  --namespace ai-inference \
  --create-namespace \
  --set model.name="Qwen/Qwen2.5-Omni-7B"
```

For gated models requiring a Hugging Face token:

```bash
helm install my-vllm-omni ./vllm-omni \
  --namespace ai-inference \
  --create-namespace \
  --set model.name="Qwen/Qwen2.5-Omni-7B" \
  --set huggingface.token="hf_your_token_here"
```

## World Model Deployment (RFC #1987)

To enable interactive world model support for robotics or interactive video:

```bash
helm install my-vllm-omni ./vllm-omni \
  --namespace ai-inference \
  --create-namespace \
  --set model.name="your-world-model" \
  --set worldModel.enabled=true \
  --set worldModel.maxSessions=32 \
  --set worldModel.websocketEnabled=true \
  --set worldModel.kvBuffer.maxWindowSize=17
```

### World Model API Endpoints

When `worldModel.enabled=true`, the following additional endpoints are available:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/v1/world/predict` | POST | Predict next chunk (creates session on first call) |
| `/v1/world/sessions` | POST | Explicitly create a session |
| `/v1/world/sessions/{id}` | DELETE | Destroy session and free resources |
| `/v1/world/stream` | WebSocket | Real-time bidirectional streaming for 7Hz+ control loops |

### WebSocket Protocol (`/v1/world/stream`)

```
Client → Server:
  {"type": "session.config", "model": "dreamzero-droid", "embodiment_id": 0}
  {"type": "observation", "images": ["base64..."], "robot_state": [...]}
  {"type": "instruction", "text": "pick up the red block"}
  {"type": "predict"}
  {"type": "session.destroy"}

Server → Client:
  {"type": "session.created", "session_id": "..."}
  {"type": "prediction", "actions": [[...]], "video_frame": "base64...", "latency_ms": 142}
  {"type": "session.reset", "reason": "buffer_full"}
  {"type": "session.destroyed"}
```

## Uninstalling the Chart

```bash
helm uninstall my-vllm-omni --namespace ai-inference
```

## Configuration

### Image

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Container image registry | `m.daocloud.io/docker.io` |
| `image.repository` | Container image repository | `vllm/vllm-omni` |
| `image.tag` | Container image tag | `v0.16.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Model

| Parameter | Description | Default |
|-----------|-------------|---------|
| `model.name` | Model name or Hugging Face path | `Qwen/Qwen2.5-Omni-7B` |
| `model.tensorParallelSize` | Number of GPUs for tensor parallelism | `1` |
| `model.pipelineParallelSize` | Pipeline parallel size | `1` |
| `model.dtype` | Model data type (auto/float16/bfloat16) | `auto` |
| `model.gpuMemoryUtilization` | GPU memory utilization ratio | `0.90` |
| `model.maxModelLen` | Maximum model context length | `null` |
| `model.quantization` | Quantization method | `null` |
| `model.trustRemoteCode` | Trust remote code for custom models | `false` |

### World Model (RFC #1987)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `worldModel.enabled` | Enable world model API endpoints | `false` |
| `worldModel.maxSessions` | Maximum concurrent sessions | `64` |
| `worldModel.sessionTimeoutSeconds` | Session inactivity timeout | `300` |
| `worldModel.websocketEnabled` | Enable WebSocket streaming | `true` |
| `worldModel.apiPrefix` | World model API prefix | `/v1/world` |
| `worldModel.kvBuffer.maxWindowSize` | KV buffer context window size | `17` |
| `worldModel.kvBuffer.preallocate` | Pre-allocate KV buffer at load time | `true` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits."nvidia.com/gpu"` | GPU count | `"1"` |
| `resources.limits.cpu` | CPU limit | `"8"` |
| `resources.limits.memory` | Memory limit | `"32Gi"` |

### Storage

| Parameter | Description | Default |
|-----------|-------------|---------|
| `storage.enabled` | Enable persistent storage for model cache | `true` |
| `storage.existingClaim` | Use existing PVC | `""` |
| `storage.storageClass` | StorageClass name | `""` |
| `storage.size` | Storage size | `"100Gi"` |
| `storage.mountPath` | Mount path in container | `/root/.cache/huggingface` |

## Supported Models

vLLM-Omni supports a wide range of models. For the full list, see the
[vLLM-Omni model documentation](https://vllm-omni.readthedocs.io/en/latest/models/supported_models/).

Key model families:
- **Omni-modality**: Qwen2.5-Omni, Qwen3-Omni
- **Audio/TTS**: Qwen3-TTS, MiMo-Audio
- **Image/Video**: Wan2.1, HunyuanImage3, BAGEL, GLM-Image
- **World Models** (RFC #1987, forthcoming): DreamZero, Matrix Game, HunYuan World

## References

- [vLLM-Omni GitHub](https://github.com/vllm-project/vllm-omni)
- [vLLM-Omni Documentation](https://vllm-omni.readthedocs.io)
- [RFC #1987: Interactive World Model Support](https://github.com/vllm-project/vllm-omni/issues/1987)
- [DaoCloud dce-charts-repackage](https://github.com/DaoCloud/dce-charts-repackage)
