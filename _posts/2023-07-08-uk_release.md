---
title: "Українська мова в Balacoon"
last_modified_at: 2023-07-08T16:20:02-05:00
toc: true
categories:
  - Blog
tags:
  - text-to-speech
  - ukrainian
---

Швидкий, зручний та якісний нейромережевий синтез українського мовлення тепер в Balacoon.
[Інтеграція бібліотеки синтезу](https://balacoon.com/use/) ще ніколи не була такою простою:
[Python пакети без залежностей](https://balacoon.com/use/tts/package) для real-time генерації на CPU,
[Docker контейнер](https://balacoon.com/use/tts/service) здатний обробляти десятки паралельних запитів на GPU,
[найшвидший on-device синтезатор](https://balacoon.com/blog/on-device/), який дозволяє real-time синтез навіть на RaspberryPi.
І це все тепер безкоштовно доступне для української мови під [MIT ліцензією](https://balacoon.com/license.html).

{% include embed-audio.html src="/assets/demo_audio/uk_example.mp3" name="Приклад:" %}

Сгенеруйте більше прикладів в нашому [онлайн демо](https://huggingface.co/spaces/balacoon/tts).

# Реліз

Дякуємо [спільноті синтезу українського мовлення](https://t.me/speech_synthesis_uk)
за створення, популяризацію і підтримку [відкритих датасетів](https://github.com/egorsmkv/ukrainian-tts-datasets).
На їх основі, ми побудували [2 моделі](https://huggingface.co/balacoon/tts):

* [JETS](https://arxiv.org/abs/2203.16852) - стандартна мульти-спікер модель з частотою дискретизації 24kHz.
  Підтримує усі наявні голоси: Лада, Тетяна і Микита. Росповсюджується
  в двох варіантах:
    - `uk_ltm_jets_cpu.addon` - для синтезу на CPU за допомогою Python пакету `balacoon_tts`.
    - `uk_ltm_jets_gpu.addon` - для сервісу в Docker контейнері з використанням GPU.
* [Light](https://balacoon.com/blog/on-device/#introducing-light) - полегшена модель з частотою дискретизації 16kHz для надшвидкої генерації.
  Підтримує голос Тетяни. Розповсюджується тільки варіант для CPU: `uk_tetiana_light_cpu.addon`.

Для аналізу тексту, усі моделі використовують [espeak](https://github.com/balacoon/espeak-ng)
з додатковим [словником наголосів](https://github.com/lang-uk/ukrainian-word-stress).

# Чого бракує

Було б добре оновити підхід до аналізу тексту, а саме:

* побудувати правила для нормалізації тексту за допомогою Finite-State-Transducers.
  Balacoon [підтримує цю технологію](https://github.com/balacoon/learn_to_normalize)
  і має [реалізацію для англійської мови](https://github.com/balacoon/en_us_normalization).
  Такий підхід легше пітримувати і розширювати, додаючи нові правила.
* Визначення наголосів потребує рішення з контекстуалізованою генерацію вимови[[1]](#1),[[2]](#2).
  Цей підхід нажаль ще [не підтримується в Balacoon](https://github.com/balacoon/learn_to_pronounce) але ми сподіваємося додати
  загальне рішення, яке б було корисним для усіх мов з омографами.
  Як тимчасове рішення, користувачі можуть вказувати бажані наголоси за допомогою 
  ["акутів"](https://uk.wikipedia.org/wiki/%D0%90%D0%BA%D1%83%D1%82).

Також планується додати підтримку багатомовного синтезу.
Зараз проблема генерації латиниці вирішується [простими правилами](https://github.com/balacoon/espeak-ng/blob/master/packing_info/uk/phoneme_mapping).
Але сучасним рішенням було б створення системи синтезу з підтримкою багатьох мов.
Balacoon працює з [уніфікованим набором фонем](https://balacoon.com/blog/balacoon_phonemeset/), що має спростити такий перехід.

# Підтримка та відгуки

Долучайтеся до нашого [slack каналу](https://join.slack.com/t/balacoon/shared_invite/zt-1syqpvq75-s7iCBJhZcQrsmrLrAU3fhw).
Обов'язково пишіть як ви використовуєте Balacoon, що працює добре, а що не дуже.

## Посилання
<a id="1">[1]</a>
[SoundChoice: Grapheme-to-Phoneme Models with Semantic Disambiguation](https://arxiv.org/pdf/2207.13703.pdf)

<a id="2">[2]</a>
[Homograph disambiguation with contextual word embeddings for TTS systems](https://assets.amazon.science/c3/db/23ca18d7450d8dbb5b80a11fcdd3/homograph-disambiguation-with-contextual-word-embeddings-for-tts-systems.pdf)