;ytp+ suite Installer
;Based on Basic Example Script by Joost Verburg
;Modified by TeamPopplio
;https://github.com/YTP-Plus/YTPPlusSuiteInstaller

;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

;--------------------------------
;General

  ;Name and file
  Name "ytp+ suite"
  OutFile "YTPPlusSuiteInstaller.exe"
  Unicode True

  ;Default installation folder
  InstallDir "$APPDATA\YTPPlusSuite"
  ;Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\YTPPlusSuite" ""

  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

  !include "include\junction.nsh"

  !include "WinVer.nsh"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_LICENSE "docs\YTPPlusStudioSuiteInstaller-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\YTPPlusStudio-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\YTPPlusCLI-License.txt"

  !insertmacro MUI_PAGE_LICENSE "docs\Chocolatey-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\FFmpeg-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\Git-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\LOVE-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\MediaInfo-License.txt"
  !insertmacro MUI_PAGE_LICENSE "docs\NodeJS-License.txt"

  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------
;Languages
 
  !insertmacro MUI_LANGUAGE "English"
;--------------------------------
;Installer Sections

Section "Chocolatey" SecChocolatey ;https://gist.github.com/jstine35/d46e7c61caeee639b9e9733dd81fa3b0
  ;SectionIn RO
  SetDetailsView show
  ExpandEnvStrings $0 "%SystemRoot%"

  nsExec::ExecToLog '"$0\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString($\'https://chocolatey.org/install.ps1$\'))"'
  Pop $0

  ${If} $0 == "error"
    ; try running powershell in path, just in case ...
    nsExec::ExecToLog '"powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString($\'https://chocolatey.org/install.ps1$\'))"'
    Pop $0

    ${If} $0 == "error"
      DetailPrint "ERROR: Powershell is not installed!"
      DetailPrint "Powershell is a Microsoft product that normally comes pre-installed"
      DetailPrint "on Windows Vista and above. Its installer can be found on the web."
      Abort
    ${EndIf}
  ${EndIf}

  ${If} $0 = 0
    ; Check if the path entry already exists and write result to $0
    nsExec::Exec 'echo %PATH% | find "%ALLUSERSPROFILE%\chocolatey\bin"'
    Pop $0   ; gets result code

    ${If} $0 <> 0
      DetailPrint "Adding Chocolatey to PATH..."
      nsExec::Exec 'set PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin'
    ${EndIf}
  ${EndIf}

  nsExec::ExecToLog "cmd /c refreshenv"

SectionEnd

Section "Git for Windows" SecGit

  nsExec::ExecToLog 'cmd /c choco upgrade git -y --params "/NoShellIntegration /GitOnlyOnPath"'
  nsExec::ExecToLog "cmd /c refreshenv"

SectionEnd

Section "NodeJS" SecNodejs

  nsExec::ExecToLog 'cmd /c choco upgrade nodejs -y'
  nsExec::ExecToLog "cmd /c refreshenv"
  nsExec::ExecToLog "npm install --global --production windows-build-tools --vs2015"

SectionEnd

Section "FFmpeg" SecFfmpeg

  nsExec::ExecToLog 'cmd /c choco upgrade ffmpeg -y'

SectionEnd

Section "MediaInfo" SecMediainfo

  nsExec::ExecToLog 'cmd /c choco upgrade mediainfo -y'

SectionEnd

Section "LOVE" SecLove

  nsExec::ExecToLog 'cmd /c choco upgrade love -y'

SectionEnd

Section "ytp+ cli" SecCli

  SetOutPath "$INSTDIR\YTPPlusCLI"
  IfFileExists "$INSTDIR\YTPPlusCLI\version.txt" +2 0
  nsExec::ExecToLog "git clone https://github.com/YTP-Plus/YTPPlusCLI.git $INSTDIR\YTPPlusCLI"

  nsExec::ExecToLog "git pull origin main"

  nsExec::ExecToLog 'cmd /c npm install $INSTDIR\YTPPlusCLI'

SectionEnd

Section "ytp+ studio" SecStudio

  SetOutPath "$INSTDIR\YTPPlusStudio"

  IfFileExists "$INSTDIR\windows.zip" 0 +2
  Delete "$INSTDIR\windows.zip"

  nsExec::ExecToLog 'curl -L --output "$INSTDIR\windows.zip" --url "https://github.com/YTP-Plus/YTPPlusStudio/releases/latest/download/windows.zip"'

  nsExec::ExecToLog 'tar -xvf "$INSTDIR\windows.zip" --directory "$INSTDIR\YTPPlusStudio"'

  ;Make junction from CLI
  IfFileExists "$INSTDIR\YTPPlusCLI" 0 +2
  ${CreateJunction} "$INSTDIR\YTPPlusStudio\YTPPlusCLI" "$INSTDIR\YTPPlusCLI"

  Delete "$INSTDIR\windows.zip"

  CreateDirectory "$SMPROGRAMS\ytp+ suite"
  CreateShortCut "$SMPROGRAMS\ytp+ suite\ytp+ studio.lnk" "$INSTDIR\YTPPlusStudio\YTPPlusStudio.exe" "" "" "" "" "" "The nonsensical video generator."

SectionEnd

Section /o "ytp+ studio Source" SecStudioSource

  SetOutPath "$INSTDIR\YTPPlusStudioSource"

  IfFileExists "$INSTDIR\YTPPlusStudioSource\main.lua" +2 0
  nsExec::ExecToLog "git clone https://github.com/YTP-Plus/YTPPlusStudio.git $INSTDIR\YTPPlusStudioSource"
  nsExec::ExecToLog "git pull origin master --rebase $INSTDIR\YTPPlusStudioSource"

  ;Make junction from CLI
  IfFileExists "$INSTDIR\YTPPlusCLI" 0 +2
  ${CreateJunction} "$INSTDIR\YTPPlusStudioSource\YTPPlusCLI" "$INSTDIR\YTPPlusCLI" 

SectionEnd

;--------------------------------
;Descriptions

  ;Language strings
  LangString DESC_SecChocolatey ${LANG_ENGLISH} "Required for installation of Git, NodeJS, FFmpeg, MediaInfo, and LOVE. Chocolatey is a package manager that is used to easily install the required tools and software."
  LangString DESC_SecGit ${LANG_ENGLISH} "Used to download the latest versions of the ytp+ suite. Git for Windows is a version control software."
  LangString DESC_SecNodejs ${LANG_ENGLISH} "Used to install and launch ytp+ cli. NodeJS is a JavaScript runtime."
  LangString DESC_SecFfmpeg ${LANG_ENGLISH} "Used to generate videos using ytp+ cli. FFmpeg is an open-source video converter tool."
  LangString DESC_SecMediainfo ${LANG_ENGLISH} "Used to detect video length using ytp+ cli. MediaInfo CLI is a video information tool."
  LangString DESC_SecLove ${LANG_ENGLISH} "Provided for redundancy in ytp+ studio. LOVE is a framework for Lua games and projects."

  LangString DESC_SecCli ${LANG_ENGLISH} "This is required for ytp+ studio to function. ytp+ cli is a NodeJS console UI (CLI) used to generate nonsensical videos."
  LangString DESC_SecStudio ${LANG_ENGLISH} "Recommended for basic users. ytp+ studio is a LOVE-based UI front-end for ytp+ cli."
  LangString DESC_SecStudioSource ${LANG_ENGLISH} "Provided for advanced users only. This clones or updates ytp+ studio's source code."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecChocolatey} $(DESC_SecChocolatey)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecGit} $(DESC_SecGit)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecNodejs} $(DESC_SecNodejs)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecFfmpeg} $(DESC_SecFfmpeg)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMediainfo} $(DESC_SecMediainfo)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecLove} $(DESC_SecLove)

    !insertmacro MUI_DESCRIPTION_TEXT ${SecCli} $(DESC_SecCli)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStudio} $(DESC_SecStudio)
    !insertmacro MUI_DESCRIPTION_TEXT ${SecStudioSource} $(DESC_SecStudioSource)

  !insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Functions

Function .onInit
  ${If} ${AtMostBuild} 17063
    MessageBox MB_OK|MB_ICONEXCLAMATION "This installer requires Windows 10 build 17063 or newer."
    Quit
  ${EndIf}
  ;Section sizes
  SectionSetSize ${SecChocolatey} 70500
  SectionSetSize ${SecGit} 70000
  SectionSetSize ${SecNodeJS} 15000000 ;windows build tools mostly
  SectionSetSize ${SecFfmpeg} 70000
  SectionSetSize ${SecLove} 20000
  SectionSetSize ${SecCli} 300000
  SectionSetSize ${SecStudio} 10000
  SectionSetSize ${SecStudioSource} 1000
FunctionEnd
