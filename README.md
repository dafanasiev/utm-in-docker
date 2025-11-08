# utm-in-docker

## Prereq

*NOTE: see [Dockerfile](./Dockerfile) for dl links*

```sha256sum
8fa924f94966ddf8146ac99c5320fa048d9339fe84ad13e6b096b63367e6fb40  rutoken.asc
0e3de2f175fbab17f1299acf122e2f410c75ebf28cae88d91ede009bbbd57dcc  u-trans-4.2.0-2660-i386.deb
```

## Final notes

1. Dont forget to stop pcscd on host machine:

```sh
systemctl disable --now pcscd.socket
systemctl disable --now pcscd.service
```
