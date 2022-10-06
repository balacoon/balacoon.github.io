---
title: "Adjusting Text Normalization"
permalink: /use/frontend/learn_to_normalize
---

**Frontend** utilizes pre-packed grammars,
to expand written text into a spoken form.
[Pynini](https://www.openfst.org/twiki/bin/view/GRM/Pynini)
is used to write grammars that tokenize input text,
classify tokens into semiotic classes and verbalize them.

You can see how addons with text-normalizatio rules are built
or even build your own using **learn_to_normalize**
([github](https://github.com/balacoon/learn_to_normalize), 
[documentation](../../../packages_docs/learn_to_normalize/index.html)) package.
Text normalization rules are stored in separate repositories:

- [english](https://github.com/balacoon/en_us_normalization)

Following the documentation you can adjust text normalization rules and pack them
to your custom addon. Pull requests are very welcome.
