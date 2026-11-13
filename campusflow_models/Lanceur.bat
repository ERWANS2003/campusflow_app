@echo off
rem Ouvre l'interface graphique du lanceur (double-clic).
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0outils\lanceur.ps1"
