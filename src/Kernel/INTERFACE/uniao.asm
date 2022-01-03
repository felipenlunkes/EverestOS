;;*****************************************************************************
;;
;; Sistema Operacional Everest
;;
;;
;;
;;
;;
;;
;;*****************************************************************************

%ifdef LX

%include "INTERFACE/video.asm"
%include "INTERFACE/gui.asm"

%endif

%ifndef LX

%include "INTERFACE\video.asm"
%include "INTERFACE\gui.asm"

%endif
