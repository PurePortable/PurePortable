
;;----------------------------------------------------------------------------------------------------------------------
; Константы для IAT Hooks
#PORTABLE_IAT = $20000

;;----------------------------------------------------------------------------------------------------------------------
; Константы для #PORTABLE_REGISTRY

; Способ хранения реестра и разрешение перехвата
; Если все младшие биты, определяемые маской #PORTABLE_REG_STORAGE_MASK равны нулю, перехват реестра не осуществляется
#PORTABLE_REG_STORAGE_MASK = $F
#PORTABLE_REG_PPORT = 1 ; В текстовом файле
#PORTABLE_REG_LOADAPPKEY = 2 ; Куст реестра, загружаемый RegLoadAppKey
#PORTABLE_REG_LOADKEY = 3 ; Куст реестра, загружаемый RegLoadKey
#PORTABLE_REG_SQLITE = 4 ; В базе sqlite (резерв)

; Прочее для реестра
#PORTABLE_REG_KERNELBASE = $100 ; Перехватывать kernelbase вместо advapi32
#PORTABLE_REG_SHLWAPI = $10 ; Замена #DETOUR_REG_SHLWAPI (основные функции)
#PORTABLE_REG_SHLWAPI2 = $20 ; Замена #DETOUR_REG_SHLWAPI (дополнительные функции US)
#PORTABLE_REG_TRANSACTED = $40 ; Замена #DETOUR_REG_TRANSACTED
#PORTABLE_REG_ALL = #PORTABLE_REG_SHLWAPI+#PORTABLE_REG_SHLWAPI2+#PORTABLE_REG_TRANSACTED

#PORTABLE_REG_NOT_INIT = $10000 ; ??? Не осуществлять инициализацию
#PORTABLE_REG_IAT = $20000 ; TODO
#PORTABLE_REG_CS = $40000  ; TODO: регистрозависимое хранение ключей

; Выбор через #DETOUR_REG_DLL dll для установки хуков реестра
#DETOUR_REG_DLL_ADVAPI32 = 0
#DETOUR_REG_DLL_KERNELBASE = 1

; Для вывода диагностики
#DBG_REG_MODE_MASK = $0F ; пока используем значения 0-15
#DBG_REG_MODE_ALIENS = 1 ; только не прошедшие фильтр ключи
#DBG_REG_MODE_KEYS = 2 ; только разделы реестра
#DBG_REG_MODE_EXT = 3 ; + кода возврата и другая дополнительная информация
#DBG_REG_MODE_VIRT = 4 ; + диагностика работы с виртуальным реестром
#DBG_REG_MODE_MAX = $0F

;;----------------------------------------------------------------------------------------------------------------------
; Константы #PORTABLE_SPECIAL_FOLDERS

#PORTABLE_SF_ON = 1
#PORTABLE_SF_SHFOLDER = $10 ; Замена #DETOUR_SHFOLDER
#PORTABLE_SF_USERENV = $20 ; Замена #DETOUR_USERENV
#PORTABLE_SF_IAT = $20000  ; TODO

; Для вывода диагностики
#DBG_SF_MODE_MASK = $0F
#DBG_SF_MODE_MAX = $0F

;;----------------------------------------------------------------------------------------------------------------------
; Константы #PORTABLE_ENVIRONMENT_VARIABLES
#PORTABLE_ENV_KERNELBASE = $100 ; Перехватывать kernelbase вместо kernel32

;;----------------------------------------------------------------------------------------------------------------------
; Константы #PORTABLE_CBT_HOOK и для управлением при выходе
; Начиная с версии 4.10.31 эти значения частично не актуальны
#PORTABLE_CBT_ON = 1
#PORTABLE_CBTR_NONE = 0
#PORTABLE_CBTR_EXIT = $1 ; Снять CBT-хук, выполнить DetachProcess (полное завершение работы программы)
#PORTABLE_CBTR_SAVECFG = $2 ; Выполнить SaveCfg
#PORTABLE_CBTR_UNHOOK = $4 ; Снимать хук
#PORTABLE_CBTR_UNINITIALIZE = $8 ; Снимать MinHook-и и прочие
#PORTABLE_CBTR_DETACHPROCESS = $10 ; Выполнить DetachProcess
#PORTABLE_CBTR_FULL = #PORTABLE_CBTR_SAVECFG|#PORTABLE_CBTR_UNHOOK|#PORTABLE_CBTR_UNINITIALIZE|#PORTABLE_CBTR_DETACHPROCESS

#PORTABLE_CBTR_NO_CALLNEXTHOOK = $100 ; Не выполнять CallNextHookEx

;;----------------------------------------------------------------------------------------------------------------------


; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 53
; FirstLine = 27
; EnableThread
; DisableDebugger
; EnableExeConstant