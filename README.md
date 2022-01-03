# Everest OS

Sistema Operacional Everest/Everest Operating System

# Português

## Origem

Esse software se baseia em uma versão bastante antiga do sistema operacional de domínio público [Snowdrop OS](http://www.sebastianmihai.com/snowdrop/) bastante modificada, com diversas alterações, desde o kernel até os utilitários. O Everest OS não é compatível a nível binário com o Snowdrop OS, no entanto.

## Construção do sistema

Para construir as imagens de disquete e disco contendo o sistema, você precisará de uma versão de 32 ou 64 bits do Windows. A seguir, você deve executar o script build.bat, na raiz do repositório. As imagens poderão ser encontradas em discos/ após este processo. A ferramenta de virtualização [qemu](https://www.qemu.org/) pode ser utilizada para executar o sistema em alguma das duas imagens disponíveis.

Linha de comando para a execução das imagens:

```
qemu-system-i386 -fda Everest.img -m 1 -soundhw pcspk
qemu-system-i368 -cdrom Everest.iso -m 1 -soundhw pcspk
``` 

# English

## Origin

This software is based on a very old version of the public domain operating system [Snowdrop OS](http://www.sebastianmihai.com/snowdrop/) which has been heavily modified, with several changes, from the kernel to the utilities. Everest OS is not binary-compatible with Snowdrop OS, however.

## System build

To build the floppy and disk images containing the system, you will need a 32-bit or 64-bit version of Windows. Next, you must run the build.bat script at the root of the repository. Images can be found on discos/ after this process. The [qemu](https://www.qemu.org/) virtualization tool can be used to run the system on either of the two available images.

Command line for executing the images:

```
qemu-system-i386 -fda Everest.img -m 1 -soundhw pcspk
qemu-system-i368 -cdrom Everest.iso -m 1 -soundhw pcspk
```
