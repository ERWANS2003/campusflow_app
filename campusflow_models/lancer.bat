@echo off
rem Lance le projet campusflow_models : dependances, analyse, tests, puis exemple.
rem Double-cliquer sur ce fichier, ou taper "lancer" dans un terminal ouvert ici.
chcp 65001 >nul
cd /d "%~dp0"

echo === 1/4 Dependances ===
call dart pub get || goto erreur

echo.
echo === 2/4 Analyse du code ===
call dart analyze || goto erreur

echo.
echo === 3/4 Tests ===
call dart test || goto erreur

echo.
echo === 4/4 Exemple : chargement des taches ===
call dart run example/campusflow_models_example.dart || goto erreur

echo.
echo Tout est OK.
pause
exit /b 0

:erreur
echo.
echo ECHEC : voir le message ci-dessus.
pause
exit /b 1
