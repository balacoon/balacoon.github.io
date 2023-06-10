---
title: "Balacoon TTS as a service"
excerpt: Discover the Future of Text-to-Speech: Self-Hosted Service for Lightning-Fast Speech Generation
seo_title: Revolutionary Self-Hosted Text-to-Speech Service: GPU-Powered, Parallel Requests, Unmatched Speed
seo_description: Unleash the power of a self-hosted text-to-speech service with a Docker container on your GPU machine. Handle hundreds of parallel requests and generate up to 3.5 hours of speech in just 30 seconds. Experience the low-latency streaming synthesis technology with response times as low as 100ms. Revolutionize your speech synthesis capabilities like never before.
last_modified_at: 2023-03-20T16:20:02-05:00
categories:
  - Blog
tags:
  - text-to-speech
---

In recent years, text-to-speech technology has made tremendous strides,
thanks in large part to advances in machine learning and artificial intelligence.
As a result, synthetic speech is now almost indistinguishable from human speech,
and is being used in a variety of applications, from voice assistants to audiobooks.

However, while there are many cloud-based text-to-speech services available,
([AWS Polly](https://aws.amazon.com/polly/),
[Azure Text-to-speech](https://azure.microsoft.com/en-us/products/cognitive-services/text-to-speech),
[Google cloud Text-to-speech](https://cloud.google.com/text-to-speech) to name a few)
these services can be expensive, and may not always be the best fit for every use case.
That's why we're excited to announce the release of our new self-hosted text-to-speech service,
which is available as a Docker image that you can spin up on a GPU instance.

With our self-hosted text-to-speech service, you can get state-of-the-art speech synthesis
within your own infrastructure, without having to rely on cloud service providers.
This can be especially useful for practitioners who need to power their app or service
with synthetic speech in production, and who may have concerns about cost or security.

As the rest of the post delves into the internal workings of the service,
we recommend taking a moment to review the
[usage documentation]({{ site.url }}{{ site.baseurl }}/use/tts/service),
which demonstrates  how straightforward it is to establish a TTS endpoint.

## How far 1 GPU can take you

This section aims to set expectations regarding the efficiency of Balacoon TTS,
specifically in terms of how many users can be served using just one GPU to handle requests.
Two primary metrics to consider are:

* **Latency** - the amount of time a user must wait before obtaining the first chunk of audio.
* **Real-time factor (RTF)** - the ratio of the duration of the synthesized audio to the time it took to produce it.

Configuring the endpoint involves finding a balance between these two metrics.
Balacoon TTS server uses [NVIDIA Triton Server](https://developer.nvidia.com/nvidia-triton-inference-server) internally,
which enables batching of inference requests.
The greater the number of requests that are batched and processed in parallel,
the better the real-time factor will be. However, this comes at the cost of increased
latency since processing more data in parallel requires more time. You have control over the
maximum batch size to process, when you are launching the endpoint.
<figure style="width: 900px" class="align-center">
  <img src="{{ site.url }}{{ site.baseurl }}/assets/images/tts_server_performance.png" alt="">
  <figcaption class="figure-caption text-center">Balacoon TTS Service performance</figcaption>
</figure>
It can be observed that beyond a certain point,
increasing the batch size does not result in any significant increase in the amount of audio produced.
In total, it is possible to generate **3.5 hours of speech in just 30 seconds**,
with each user starting to receive audio in as little as 100 milliseconds after the request.
Check out the [performance of classical combination of Tacotron2 and Waveglow](https://developer.nvidia.com/blog/getting-real-time-factor-over-60-for-text-to-speech-using-riva/) for comparison.

There are other parameters that affect Latency/RTF,
but these are hardcoded into the server and cannot be adjusted:

* **Chunk size** - the amount of audio synthesized in a single processing unit.
  It is more efficient to synthesize larger chunks of audio, but this can increase latency.
  The chunk size for Balacoon TTS is set at 2 seconds.
* **Batching queue delay** - the time to wait for the new requests before sending previously
  obtained ones as a batch. Balacoon TTS aggregates requests for 10ms.
