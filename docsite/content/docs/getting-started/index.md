---
title: 'Getting Started'
date: 2019-02-11T19:27:37+10:00
weight: 2
summary: Start here if you are unfamiliar with this documentation.
---
We tried various combinations of I/O drives for relative performance, with the following results:

| Model                            | Capacity | Cost | Relative Performance |
| -------------------------------- | -------- | ---- | -------------------- |
| Sandisk Ultra SDCard A1          | 32GB     | $7   | 1,078                |
| Sandisk Ultra Fit USB flashdrive | 128GB    | $19  | 1,393                |
| Kingston A400 (+cable)           | 120GB    | $32  | 7,533                |
| WD Blue SN500 NVMe (+adapter)    | 250GB    | $94  | 7,912                |

N.B. a larger Kingston A400 with 240GB capacity is available for $42 including the USB<->SATA cable.

Full details of the I/O benchmark are available on our [I/O benchmarks page](/docs/io-benchmarks/).

## Additional Documentation
- [Preparing a bootable Pi 4 Ubuntu 18.04.3 image](/docs/preparing-an-image/)
- [Cloud-init - bootstrapping a new Ubuntu Pi 4](/docs/cloud-init/)
- [PoE testing](/docs/poe-testing/)
- [Cases and heatsinks](casesetc.html)
- Networking
- [I/O - tested configurations and benchmark results](/docs/io-benchmarks/)

## Other Tools
Documentation is written in markdown using the [Ghostwriter](https://wereturtle.github.io/ghostwriter/) markdown editor.
It is rendered using the [Hugo static site generator](https://gohugo.io) and makes use of the simple [Whisper theme](https://themes.gohugo.io/hugo-whisper-theme/) for style, which will be modified slightly in due course. Deployment is [via `rsync`](https://gohugo.io/hosting-and-deployment/deployment-with-rsync/).
