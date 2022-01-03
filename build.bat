@echo off
title Construindo sistema...
@call limpar.bat
title Construindo sistema...
cd build


@call montar.bat

@call disquete.bat

@call disco.bat

cd..


@echo =======================================================================
@echo =                              Pronto                                 =
@echo =======================================================================

@pause