@echo off
rem Lance l'application CampusFlow et son serveur API (dossier server/).
rem Double-clic : menu. Ou directement : lancer chrome | lancer android | lancer tests | lancer serveur
chcp 65001 >nul
cd /d "%~dp0"
title CampusFlow

set "cible=%~1"
if not "%cible%"=="" goto preparer

echo.
echo   CampusFlow - suivi des echeances
echo   --------------------------------
echo   1. Lancer dans Chrome (+ serveur API)
echo   2. Lancer sur telephone ou emulateur Android (+ serveur API)
echo   3. Lancer les tests
echo   4. Lancer seulement le serveur API
echo.
echo   Compte de demo : amina@etudiant.bf / campus
echo.
choice /c 1234 /n /m "  Ton choix (1, 2, 3 ou 4) : "
if errorlevel 4 (set "cible=serveur") else if errorlevel 3 (set "cible=tests") else if errorlevel 2 (set "cible=android") else (set "cible=chrome")

:preparer
if /i "%cible%"=="serveur" goto serveur
echo.
echo === Dependances ===
rem D'abord depuis le cache (sans internet), sinon telechargement normal.
call flutter pub get --offline >nul 2>&1 || call flutter pub get || goto erreur
echo OK

if /i "%cible%"=="chrome" goto chrome
if /i "%cible%"=="android" goto android
if /i "%cible%"=="tests" goto tests
echo Cible inconnue : %cible% (chrome, android, tests ou serveur)
goto erreur

:chrome
call :demarrer_serveur || goto erreur
echo.
echo === Lancement dans Chrome (r = recharger, q = quitter) ===
rem --no-web-resources-cdn : le moteur web est servi en local, pas depuis Google.
call flutter run -d chrome --no-web-resources-cdn || goto erreur
goto fin

:android
call :demarrer_serveur || goto erreur
echo.
echo === Appareils detectes ===
call flutter devices
echo.
echo === Lancement sur Android (r = recharger, q = quitter) ===
rem Sur l'emulateur, l'appli joint le serveur du PC par 10.0.2.2:3000.
call flutter run -d android || goto erreur
goto fin

:tests
echo.
echo === Analyse ===
call flutter analyze || goto erreur
echo.
echo === Tests (sans serveur : depots simules) ===
call flutter test || goto erreur
echo.
echo Tout est OK.
goto fin

:serveur
call :demarrer_serveur || goto erreur
goto fin

rem Ouvre le serveur json-server dans sa propre fenetre (Ctrl+C pour l'arreter).
:demarrer_serveur
where node >nul 2>&1 || (echo Node.js est introuvable : installe-le depuis nodejs.org & exit /b 1)
if not exist "server\node_modules" (
  echo.
  rem Pas de parentheses dans ce echo : elles fermeraient le bloc if.
  echo === Installation du serveur, une seule fois ===
  pushd server
  call npm install --no-audit --no-fund || (popd & exit /b 1)
  popd
)
echo.
echo === Serveur API sur http://localhost:3000 (fenetre separee) ===
start "CampusFlow API" /d "%~dp0server" cmd /k npm start
exit /b 0

:erreur
echo.
echo ECHEC : voir le message ci-dessus.
if "%~1"=="" pause
exit /b 1

:fin
if "%~1"=="" pause
exit /b 0
