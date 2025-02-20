---
title: "Tracing mHuBERT"
last_modified_at: 2025-02-10T10:20:02+05:00
toc: true
categories:
  - Blog
tags:
  - text-to-speech
  - HuBERT
  - tracing
---

Clustering of self-supervised embeddings is commonly used as "semantic" tokens in audio generation.
Typically wav2vec 2.0 or HuBERT outputs are used.
A 95M-params multilingual HuBERT model (147 languages) was [released](https://huggingface.co/utter-project/mHuBERT-147) recently. Despite its modest size, the model is competetive on the SUPERB leaderboard.
This makes it a string candidate for use as a semantic tokens extractor in multilingual speech generation
experiments.

## Tracing

Converting model into Torch JIT file allows to run inference with minimal dependencies (just PyTorch) or deployment on inference servers (e.g. Triton).
In this tracing, we integrate the clustering step into the Torch module, eliminating the need to carry around custom clustering code.

Unfortunately, the FAISS index for clustering step is only available for model after the second iteration.
As a result, the traced model is slightly less capable.

The traced model is available at [balacoon/mhubert-147](https://huggingface.co/balacoon/mhubert-147).
The full notebook used for tracing and testing can be found [here](https://github.com/balacoon/balacoon.github.io/blob/master/assets/posts/mhubert/trace_hubert.ipynb).

Many thanks to @dathudeptrai for [posting](https://huggingface.co/utter-project/mHuBERT-147/discussions/6) a snippet on discrete tokens extraction.

## Notes

Here are some notes and practical findings from the mHuBERT model tracing.
Please drop a message if any of these are incorrect or incomplete.
* The attention mask is ignored by mHuBERT. As a result, during batched inference, you can get different discrete codes depending on the padding:
<figure style="width: 500px" class="align-center">
  <img src="{{ site.url }}{{ site.baseurl }}/assets/images/posts/mhubert/batching.png" alt="">
  <figcaption class="figure-caption text-center">Effect of padding during batching</figcaption>
</figure>

* mHuBERT applies mean/std normalization to input audio.
* `faiss` has a lot of clustering methods implemented. Fortunately a linear transformation was used for clustering in mHuBERT, allowing it to be extracted into a transformation matrix. See `TorchFaiss` in the notebook for details.
