---
title: "Speech Generation Evaluation and Leaderboard"
last_modified_at: 2025-02-16T10:20:02+05:00
toc: true
categories:
  - Blog
tags:
  - text-to-speech
  - leaderboard
  - evaluation
---

As speech generation research grows, many new models have emerged.
For a comprehensive list, see [open_tts_tracker](https://huggingface.co/datasets/Pendrokar/open_tts_tracker).
Similar to LLM evaluation, [TTSArena](https://huggingface.co/spaces/TTS-AGI/TTS-Arena) (and its [clone](https://huggingface.co/spaces/Pendrokar/TTS-Spaces-Arena))
provides rankings of popular systems.

While ELO-based ranking relies on human judgment, objective metrics are also commonly used for leaderboards.
Though speech generation lacks a universal standard for objective evaluation,
the community has developed several useful metrics:

* Intelligibility - measured by speech recognition error rates on synthetic speech
* Naturalness - predicted using models trained on human naturalness ratings
* Similarity - for voice cloning systems, measured by cosine similarity between speaker embeddings of reference and generated speech

## We would like to introduce:

### `speech_gen_eval` ([github](https://github.com/balacoon/speech_gen_eval))
An open-source library for objective evaluation of speech generation models

### `speech_gen_eval_testsets` ([huggingface](https://huggingface.co/datasets/balacoon/speech_gen_eval_testsets))
A collection of test sets for evaluating speech generation models

### `speech_gen_baselines` ([github](https://github.com/balacoon/speech_gen_baselines))
A dataset containing synthetic speech from common models and their evaluation results

### `TTSLeaderboard` ([huggingface](https://huggingface.co/spaces/balacoon/TTSLeaderboard))
A leaderboard for speech generation models

There are other tools for objective evaluation of speech generation, including [ZS-TTS-Evaluation](https://github.com/Edresson/ZS-TTS-Evaluation), [seed-tts-eval](https://github.com/BytedanceSpeech/seed-tts-eval), [tts-scores](https://github.com/neonbjb/tts-scores), [evaluate-zero-shot-tts](https://github.com/keonlee9420/evaluate-zero-shot-tts), and another leaderboard called [TTSDS Scores](https://huggingface.co/spaces/ttsds/benchmark).
Our contribution focuses on:
* Simple addition of new metrics and test sets
* Support for various speech generation models (vocoders, zero-shot TTS, zero-shot VC, etc.), where tools can be reused
* Mature engineering with easy installation and fast evaluation
* Allowing to listen to the generated speech side-by-side to build a relation between metrics and perceived quality

Having most of these tools internally for a while, we are now making them publicly available.

We plan to expand the leaderboard with more models and add new metrics to the library.
We welcome your suggestions and contributions!