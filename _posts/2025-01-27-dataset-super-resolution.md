---
title: "Super-resolution for TTS data"
last_modified_at: 2025-01-27T10:20:02+05:00
toc: true
categories:
  - Blog
tags:
  - text-to-speech
  - data
  - super resolution
  - upsampling
---

Zero-shot speech generation requires massive amounts of data.
Large-scale speech datasets however are commonly collected for ASR and therefore sampled at 16khz.
LibriTTS-R[[1]](#1) work suggests that audio enhancement and super-resolution methods can be beneficial for TTS data processing. This blog compares a few open-source upsampling methods,
aiming a usecase of preparing a TTS dataset (24kHz) from an ASR one (16kHz).

## Methods

We compare the following methods:

* SoX - vanilla upsampling via interpolation, the higher frequencies are not restored. 
* [Resemble Enhance](https://github.com/resemble-ai/resemble-enhance) - diffusion-based denoising / enhancement / upsampling.
* [AudioSR](https://github.com/haoheliu/versatile_audio_super_resolution) - diffusion-based audio super resolution.
* [AP-BWE](https://yxlu-0102.github.io/AP-BWE/) - GAN-based bandwidth extension in spectral domain.

Processing speed per file on a single RTX 3090:

| Method | Resemble Enhance | AudioSR | AP-BWE |
| --- | :---: | :---: | :---: |
| Processing speed per file, sec | 8.0 | 5.0 | 0.035 |

We measure intelligibility, audio quality and speaker similarity of the processed audio on two datasets: VCTK[[2]](#2) and DAPS[[3]](#3). First represents clean audio that simply lacks higher frequencies. Second - is a more challenging usecase of speech recorded on consumer microphones with background noise present.
We use ECAPA[[4]](#4) speaker encoder by [Speechbrain](https://huggingface.co/speechbrain/spkrec-ecapa-voxceleb) to extract speaker representation and measure speaker similarity. We run speech recognition with [Conformer-Transducer ASR model by NVIDIA](https://huggingface.co/nvidia/stt_en_conformer_transducer_xlarge#model-architecture) to evaluate intelligibility in terms of Character Error Rate. Finally, we use a pre-trained Mean Opinion Score estimator UTMOS[[5]](#5) to access the naturalness.
Keep in mind that all the metrics are computed on 16khz audio, so they are mainly tracking if upsampling
introduces any changes to the information that is already there. 

## VCTK testset

A 2k subset is sampled.

| Method | Naturalness(MOS↑)  | Intelligibility(CER, %↓) | Similarity(inverted cosine distance↓) |
| --- | :---: | :---: | :---: |
| original audio | 4.078 | 0.178 | 0 |
| SoX | 4.075 | 0.178 | 0.002 |
| Resemble Enhance | 3.86 | 0.18 | 0.079 |
| AudioSR | 4.05 | 0.178 | 0.039 |
| AP-BWE | 4.06 | 0.178 | 0.042 |

Example of the upsampling in spectral domain:

<figure style="width: 800px" class="align-center">
  <img src="{{ site.url }}{{ site.baseurl }}/assets/images/posts/dataset_super_resolution/vctk_example.png" alt="">
</figure>

Audio samples:

<iframe src="https://balacoonwebsite.s3.eu-north-1.amazonaws.com/posts/dataset_super_resolution/sr_vctk_demo.html" width="800" height="600"></iframe>

## DAPS testset

Dataset is segmented into sentence-level, a 2k subset is sampled.

| Model | Naturalness(MOS↑)  | Intelligibility(CER, %↓) | Similarity(inverted cosine distance↓) |
| --- | :---: | :---: | :---: |
| original audio | 2.48 | 2.75 | 0 |
| SoX | 2.48 | 2.748 | 0.008 |
| Resemble Enhance | 3.32 | 12.98 | 0.43 |
| AudioSR | 2.45 | 3.15 | 0.07 |
| AP-BWE | 2.456 | 2.73 | 0.007 |

Example of the upsampling in spectral domain:

<figure style="width: 800px" class="align-center">
  <img src="{{ site.url }}{{ site.baseurl }}/assets/images/posts/dataset_super_resolution/daps_example.png" alt="">
</figure>

Audio samples:

<iframe src="https://balacoonwebsite.s3.eu-north-1.amazonaws.com/posts/dataset_super_resolution/sr_daps_demo.html" width="800" height="600"></iframe>

## Conclusions

`Resemble-Enhance` strives to also perform denoising and enhancement.
It corrupts the noisy audio files substantially which is reflected in greatly degraded intelligibility.
Both `AudioSR` and `AP-BWE` are very gentle to existing information and do not change the metrics.
Former adds more details and combines with existing high-freq information more smoothly.
Latter is however almost 150x faster. Our pick is `AudioSR` if the amount of data is managable, otherwise `AP-BWE`.

## References
<a id="1">[1]</a>
[LibriTTS-R: A Restored Multi-Speaker Text-to-Speech Corpus](https://arxiv.org/abs/2305.18802)

<a id="2">[2]</a>
[CSTR VCTK Corpus: English Multi-speaker Corpus for CSTR Voice Cloning Toolkit](https://datashare.ed.ac.uk/handle/10283/3443)

<a id="3">[3]</a>
[Device and Produced Speech (DAPS) Dataset](https://ccrma.stanford.edu/~gautham/Site/daps_files/mysore-spl2015.pdf)

<a id="4">[4]</a>
[ECAPA-TDNN Embeddings for Speaker Diarization](https://arxiv.org/abs/2104.01466)

<a id="5">[5]</a>
[UTMOS: UTokyo-SaruLab System for VoiceMOS Challenge 2022](https://arxiv.org/abs/2204.02152)