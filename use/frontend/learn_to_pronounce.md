---
title: "Adjusting pronunciation"
permalink: /use/frontend/learn_to_pronounce
---

**Frontend** utilizes pre-packed resources,
to add pronunciations to the words. Pronunciation is either
looked-up in a dictionary or generated using a model.
All resources required for it are stored in a pronunciation
addon, which is part of frontend addon.

You can build your own using **learn_to_pronounce**
([github](https://github.com/balacoon/learn_to_pronounce), 
[documentation](../../../packages_docs/learn_to_pronounce/index.html)) package.
It works with pronunciation resource repositories:

- [en_us](https://github.com/balacoon/en_us_pronunciation)

Following the documentation you can add or adjust pronunciation for the word(s)
of interest, rebuild pronunciation generation and finally wrap it all into your own
custom pronunciation addon. Pull requests are very welcome.
