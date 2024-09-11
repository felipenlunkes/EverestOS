<div align="center">

<h1>Everest OS</h1>
<h1>Sistema Operacional Everest</h3>

![](https://img.shields.io/github/license/felipenlunkes/EverestOS.svg)
![](https://img.shields.io/github/stars/felipenlunkes/EverestOS.svg)
![](https://img.shields.io/github/issues/felipenlunkes/EverestOS.svg)
![](https://img.shields.io/github/issues-closed/felipenlunkes/EverestOS.svg)
![](https://img.shields.io/github/issues-pr/felipenlunkes/EverestOS.svg)
![](https://img.shields.io/github/issues-pr-closed/felipenlunkes/EverestOS.svg)
![](https://img.shields.io/github/downloads/felipenlunkes/EverestOS/total.svg)
![](https://img.shields.io/github/release/felipenlunkes/EverestOS.svg)
[![](https://img.shields.io/twitter/follow/lunx8086.svg?style=social&label=Follow%20%40lunx8086)](https://twitter.com/lunx8086)

</div>

<hr>

## Dependencies/Dependências

<div align="center">

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![NASM](https://img.shields.io/badge/NASM-0C322C?style=for-the-badge&logo=nasm&logoColor=white)

</div>

<hr>

## English

### Origin

<div align="justify">

This software is based on a very old version of the public domain operating system [Snowdrop OS](http://www.sebastianmihai.com/snowdrop/) which has been heavily modified, with several changes, from the kernel to the utilities. Everest OS is not binary-compatible with Snowdrop OS, however.

</div>

### System build

<div align="justify">

To build the floppy and disk images containing the system, you will need a 32-bit or 64-bit version of Windows. Next, you must run the build.bat script at the root of the repository. Images can be found on discos/ after this process. The [qemu](https://www.qemu.org/) virtualization tool can be used to run the system on either of the two available images.

Command line for executing the images:

```
qemu-system-i386 -fda Everest.img -m 1 -soundhw pcspk
qemu-system-i368 -cdrom Everest.iso -m 1 -soundhw pcspk
```

</div>

## Português

### Origem

<div align="justify">

Esse software se baseia em uma versão bastante antiga do sistema operacional de domínio público [Snowdrop OS](http://www.sebastianmihai.com/snowdrop/) bastante modificada, com diversas alterações, desde o kernel até os utilitários. O Everest OS não é compatível a nível binário com o Snowdrop OS, no entanto.

</div>

### Construção do sistema

<div align="justify">

Para construir as imagens de disquete e disco contendo o sistema, você precisará de uma versão de 32 ou 64 bits do Windows. A seguir, você deve executar o script build.bat, na raiz do repositório. As imagens poderão ser encontradas em discos/ após este processo. A ferramenta de virtualização [qemu](https://www.qemu.org/) pode ser utilizada para executar o sistema em alguma das duas imagens disponíveis.

Linha de comando para a execução das imagens:

```
qemu-system-i386 -fda Everest.img -m 1 -soundhw pcspk
qemu-system-i368 -cdrom Everest.iso -m 1 -soundhw pcspk
``` 

</div>
