SET IMAGEM_CD=Everest.iso
SET IMAGEM_DISQUETE=Everest.img


del /F /Q ..\discos\%IMAGEM_CD%>>NUL

IF EXIST ..\discos\%IMAGEM_DISQUETE% (
..\Ferramentas\cdrtools\mkisofs.exe -pad -b ..\discos\%IMAGEM_DISQUETE% -R -o ..\discos\%IMAGEM_CD% ..\discos\%IMAGEM_DISQUETE%>>NUL
@echo ===============================================
@echo             Criando imagem de CD
@echo ===============================================
) ELSE (
@ECHO ===============================================================
@ECHO 
@ECHO              Imagem de disquete nao encontrada!
@ECHO 
@ECHO ===============================================================
)
