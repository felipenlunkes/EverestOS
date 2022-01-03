@SET IMAGEM=Everest.img

@echo ===============================================
@echo  Gerando sistema e imagens de disquete e CD...
@echo ===============================================

mkdir ..\discos>>NUL
del /F /Q ..\discos\%IMAGEM%>>NUL

@echo Criando a imagem de disquete...
..\Ferramentas\mtools\imginit\imginit.exe -fat12 ..\discos\%IMAGEM%>>NUL

@echo Copiando arquivos para a imagem do sistema...
cd ..\saida
for %%i in (*.*) do ..\Ferramentas\mtools\imgcpy\imgcpy.exe %%i ..\discos\%IMAGEM%=a:\%%i>>NUL
cd..

cd build

@echo Limpando bootloader padrao...
..\Ferramentas\mtools\mdel.exe ..\discos\%IMAGEM% LOADER.BIN>>NUL

@echo Copiando setor novo...
..\Ferramentas\mkbt\mkbt.exe ..\saida\CRGEVER.bin ..\discos\%IMAGEM%>>NUL

@echo ===============================================
@echo                    Pronto!
@echo ===============================================
