@echo off
rem Lance l'application CampusFlow.
rem Double-clic : menu. Ou directement : lancer chrome | lancer android | lancer tests
chcp 65001 >nul
cd /d "%~dp0"
title CampusFlow

set "cible=%~1"
if not "%cible%"=="" goto preparer

echo.
echo   CampusFlow - suivi des echeances
echo   --------------------------------
echo   1. Lancer dans Chrome
echo   2. Lancer sur telephone ou emulateur Android
echo   3. Lancer les tests
echo.
choice /c 123 /n /m "  Ton choix (1, 2 ou 3) : "
if errorlevel 3 (set "cible=tests") else if errorlevel 2 (set "cible=android") else (set "cible=chrome")

:preparer
echo.
echo === Dependances ===
call flutter pub get || goto erreur

if /i "%cible%"=="chrome" goto chrome
if /i "%cible%"=="android" goto android
if /i "%cible%"=="tests" goto tests
echo Cible inconnue : %cible% (chrome, android ou tests)
goto erreur

:chrome
echo.
echo === Lancement dans Chrome (r = recharger, q = quitter) ===
call flutter run -d chrome || goto erreur
goto fin

:android
echo.
echo === Appareils detectes ===
call flutter devices
echo.
echo === Lancement sur Android (r = recharger, q = quitter) ===
call flutter run -d android || goto erreur
goto fin

:tests
echo.
echo === Analyse ===
call flutter analyze || goto erreur
echo.
echo === Tests ===
call flutter test || goto erreur
echo.
echo Tout est OK.
goto fin

:erreur
echo.
echo ECHEC : voir le message ci-dessus.
if "%~1"=="" pause
exit /b 1

:fin
if "%~1"=="" pause
exit /b 0
