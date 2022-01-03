@echo off
title Realizando limpeza...
echo.
echo Realizando limpeza...

del /F /Q saida\*.*>>NUL
del /F /Q disco\*.*>>NUL
rmdir saida>>NUL
rmdir disco>>NUL
cls
