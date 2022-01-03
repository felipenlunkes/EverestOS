mkdir ..\saida>>NUL
@del /F /Q ..\saida\*.*>>NUL

cd ..\src


cd CRGEVER
nasm.exe -O0 CRGEVER.asm -f bin -o ..\..\saida\CRGEVER.bin
cd..


cd kernel
nasm.exe -O0 kernel.asm -f bin -o ..\..\saida\EVEREST.SIS
cd..

cd apps

nasm.exe -O0 ola.asm -f bin -o ..\..\saida\OLA.EVO
nasm.exe -O0 dir.asm -f bin -o ..\..\saida\DIR.EVO
nasm.exe -O0 desligar.asm -f bin -o ..\..\saida\DESLIGAR.EVO
nasm.exe -O0 reinit.asm -f bin -o ..\..\saida\REINIT.EVO
nasm.exe -O0 musica.asm -f bin -o ..\..\saida\MUSICA.EVO
nasm.exe -O0 mouse.asm -f bin -o ..\..\saida\MOUSE.EVO
nasm.exe -O0 sh.asm -f bin -o ..\..\saida\SH.EVO
nasm.exe -O0 mem.asm -f bin -o ..\..\saida\MEM.EVO
nasm.exe -O0 multi.asm -f bin -o ..\..\saida\MULTI.EVO
nasm.exe -O0 spartan.asm -f bin -o ..\..\saida\SPARTAN.EVO
nasm.exe -O0 sobre.asm -f bin -o ..\..\saida\SOBRE.EVO
nasm.exe -O0 cls.asm -f bin -o ..\..\saida\CLS.EVO
nasm.exe -O0 serial.asm -f bin -o ..\..\saida\SERIAL.EVO
nasm.exe -O0 echo.asm -f bin -o ..\..\saida\ECHO.EVO


cd..


copy config\*.* ..\saida\>>NUL

cd..
cd build
