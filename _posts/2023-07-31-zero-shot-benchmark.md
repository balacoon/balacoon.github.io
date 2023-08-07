---
title: "Zero-shot speech generation benchmark"
last_modified_at: 2023-07-31T16:20:02-05:00
toc: true
categories:
  - Blog
tags:
  - text-to-speech
  - voice conversion
  - zero-shot
---

Synthesizing speech with a speaker identity not seen during training presents a significant challenge. Traditionally, achieving this required extensive training on many speakers to ensure a continuous speaker space[[1]](#1). The most performant methods, such as [RVC](https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI/blob/main/docs/README.en.md), still need minimal fine-tuning with ~10 minutes of target speaker data to achieve reasonable quality. However, the approaches leveraging the power of big models are gaining momentum. For instance, Microsoft's VALL-E[[2]](#2) boldly claims to clone a speaker's voice with just 3 seconds of speech as a reference. In this blog post, we aim to present a benchmark of voice conversion technologies, comparing [Revoice](https://play.google.com/store/apps/details?id=com.app.vc&hl=en_US) to the widely spread zero-shot VC baselines.

## Testsets

Typical evaluations of Voice Conversion systems rely on objective metrics collected from running conversion on unseen multi-speaker corpora.
We design the evaluation to be insightful for the `Revoice` use-case. We use multi-speaker corpora as a source or input audio and
a library of speakers from Revoice app as a target or reference audio. Input audio is derived from:

* [VCTK](https://datashare.ed.ac.uk/handle/10283/3443) - classical voice conversion benchmark. Clean recordings, multiple accents.
* DAPS corpus[[3]](#3) - emulated mobile device recordings in various conditions. This dataset resembles the audio quality
  we obtain as a Voice Conversion service more closely.

## Metrics

We measure three model-based objective metrics for the converted speech:

* Speaker similarity: we measure a cosine distance between a latent speaker representation from converted speech and reference audio.
  We use ECAPA[[4]](#4) speaker encoder by [Speechbrain](https://huggingface.co/speechbrain/spkrec-ecapa-voxceleb) to extract speaker representation.
* Speech intelligibility: we run speech recognition with [Conformer-Transducer ASR model by NVIDIA](https://huggingface.co/nvidia/stt_en_conformer_transducer_xlarge#model-architecture) on the converted speech and measure the Character Error Rate with respect to the transcription.
* Naturalness: we use a pre-trained Mean Opinion Score estimator UTMOS[[5]](#5) [released](https://huggingface.co/spaces/sarulab-speech/UTMOS-demo) by the authors.

## Baselines

We select two widely-spread systems as the baselines. Both are trained on a large number of speakers and are capable of zero-shot speech generation. 

* YourTTS[[6]](#6) (from 2021) is a VITS architecture model with adjustments trained on VCTK + LibriTTS datasets.
  It uses an invertible normalizing flow to disentangle speaker identity from the spectrogram representation.
  Handy tutorial on how to run it can be found [here](https://colab.research.google.com/drive/1gjdwOKCZuavPn_5oy8QA01sKmXpEq5AZ?usp=sharing#scrollTo=jeQ9O6llm8D5).
* [BARK](https://github.com/suno-ai/bark) (from 2022) is a large (350M parameters) decoder-only transformer that generates speech from "semantic tokens." Those are self-supervised representations extracted with HuBERT[[7]](#7) that effectively disentangle content (semantics) and speaker characteristics. Running Voice Conversion with BARK is not straightforward, because extraction of semantic tokens is not released.
Suno.ai only provides prediction of semantic tokens from text. Fortunately, there is a [community contributed semantic tokens extractors](https://github.com/gitmylo/bark-voice-cloning-HuBERT-quantizer) that are compatible with BARK. This addition allows to [create own voice profiles](https://github.com/gitmylo/bark-voice-cloning-HuBERT-quantizer/blob/master/notebook.ipynb) and perform voice conversion, adjusting semantic tokens and voice profiles in [this notebook](https://github.com/serp-ai/bark-with-voice-clone/blob/main/generate.ipynb).

The autoregressive transformer decoder in BARK is significantly slower than parallel conversion in YourTTS, but it has greater potential due to the model's scalability.

## Results

We present results of the evaluations in the tables below.
Here is performance of the systems on `VCTK`:

| Model | Naturalness(MOS↑)  | Intelligibility(CER, %↓) | Similarity(inverted cosine distance↓)
| --- | :---: | :---: | :---: |
| no model | 4.06 | 0.17 | - |
| YourTTS[*](#0) | 3.21 | **1.08** | 0.613 |
| BARK | **3.49** | 2.58 | 0.692 |
| Revoice | 3.45 | 1.36 | 0.614 |

And performance on `DAPS`:

| Model | Naturalness(MOS↑)  | Intelligibility(CER, %↓) | Similarity(inverted cosine distance↓)
| --- | :---: | :---: | :---: |
| no model | 2.39 | 2.755 | - |
| YourTTS | 2.08 | 26.7 | 0.655 |
| BARK | **2.85** | **14.77** | 0.738 |
| Revoice | 2.81 | 16.56 | **0.564** |

Small example of how systems actually sound. For the these inputs:

{% include embed-audio.html src="/assets/posts/vc_benchmark/source.mp3" name="Source audio" %}
{% include embed-audio.html src="/assets/demo_audio/vc/kratos_short.mp3" name="Reference of target voice" %}

The systems produce following outputs:

{% include embed-audio.html src="/assets/posts/vc_benchmark/yourtts.mp3" name="YourTTS" %}
{% include embed-audio.html src="/assets/posts/vc_benchmark/bark.mp3" name="BARK" %}
{% include embed-audio.html src="/assets/posts/vc_benchmark/revoice.mp3" name="Revoice" %}

YourTTS shows excellent performance on `VCTK` but degrades significantly on more noisy inputs.
BARK consistently delivers clean and intelligible audio, but the speaker similarity lags.
Revoice competes with BARK in terms of naturalness and intelligibility while making a leap
forward in terms of speaker similarity.

## References
<a id="1">[1]</a>
[Transfer Learning from Speaker Verification to Multispeaker Text-To-Speech Synthesis](https://arxiv.org/abs/1806.04558)

<a id="2">[2]</a>
[Neural Codec Language Models are Zero-Shot Text to Speech Synthesizers](https://arxiv.org/abs/2301.02111)

<a id="3">[3]</a>
[Can we Automatically Transform Speech Recorded on Common Consumer Devices in Real-World Environments into Professional Production Quality Speech? — A Dataset, Insights, and Challenges](https://ccrma.stanford.edu/~gautham/Site/daps_files/mysore-spl2015.pdf)

<a id="4">[4]</a>
[ECAPA-TDNN Embeddings for Speaker Diarization](https://arxiv.org/abs/2104.01466)

<a id="5">[5]</a>
[UTMOS: UTokyo-SaruLab System for VoiceMOS Challenge 2022](https://arxiv.org/abs/2204.02152)

<a id="6">[6]</a>
[YourTTS: Towards Zero-Shot Multi-Speaker TTS and Zero-Shot Voice Conversion for everyone](https://arxiv.org/abs/2112.02418)

<a id="7">[7]</a>
[HuBERT: Self-Supervised Speech Representation Learning by Masked Prediction of Hidden Units](https://arxiv.org/pdf/2106.07447.pdf)

***

<a id="0">*</a>
YourTTS uses `VCTK` in training, which might give slightly overly optimistic results.



