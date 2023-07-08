---
title: "Balacoon TTS self-hosted service"
permalink: /use/tts/service
toc: true
---

Balacoon offers a Docker image for Text-to-Speech endpoints, designed to run on NVIDIA GPU machines.
This pre-built image enables fast synthesis with minimal latency.
Batching is utilized to process multiple synthesis requests concurrently,
maximizing hardware resource utilization.

## Getting **balacoon/tts_server** image

Pull the image from [Docker Hub](https://hub.docker.com/r/balacoon/tts_server).
Follow up with [NVIDIA docs](https://docs.nvidia.com/deeplearning/triton-inference-server/release-notes/rel_22-08.html) for GPU and driver requirements.

```bash
docker pull balacoon/tts_server:0.2
```

## Starting the endpoint

Similar to synthesis with **balacoon_tts** package, you will need a single
addon file with models and resources required for synthesis. Search for those,
marked with *_gpu* suffix at [HuggingFace Hub](https://huggingface.co/balacoon/tts).

```bash
# get the addon compiled for GPU
wget https://huggingface.co/balacoon/tts/resolve/main/en_us_cmartic_jets_gpu.addon
```

Start a container from the previously pulled image:

```bash
docker run --gpus all -it --rm -e CUDA_VISIBLE_DEVICES=0 --network host -v $PWD:/workspace \
    balacoon/tts_server:0.1 balacoon_tts_server 0.0.0.0 3333 16 16 /workspace/en_us_cmartic_jets_gpu.addon
```

Where `balacoon_tts_server` is a precompiled binary which takes following positional arguments:

- **ip-address**, we use non-routable meta-address for the host in this example.
- **port** on which the service is accessible.
- **threads**, number of threads that process input requests in parallel.
- **batch-size**, maximum batch size, during batching of input requests.
- **addon-path**, location of the addon with models and resources.

Playing with number of threads and batch-size allows you to balance latency and hardware utilization.
Too high batch-size can cause Out-Of-Memory however, so you have to tune it for resources available.

**WARNING**: several first requests will be taking unusually long due to so called "warming up",
which happens under the hood for each new batch size observed.

## Sending synthesis request to the endpoint

TTS endpoint that you started is a websocket server, which gets json with a text as a request,
and sends back a raw waveform. An example how to send a request using python:

```python
import json
import asyncio
import websockets

async def run_request(text: str, out_path: str):
    """
    Sends text for synthesis and saves produced audio into a file
    """
    async with websockets.connect("ws://localhost:3333") as websocket:
        request = json.dumps({"text": text, "speaker": "slt"})
        await websocket.send(request)
        
        with open(out_path, "wb") as fp:
            while True:
                try:
                    data = await websocket.recv()
                except websockets.exceptions.ConnectionClosed:
                    break
                if data is None:
                    break
                fp.write(data)

# it will write raw waveform to a file
# to convert it to wav, you can use sox:
# sox -r 24000 -c 1 -b 16 -e signed-integer output.raw output.wav
asyncio.run(run_request('hello world', 'output.raw'))
```
