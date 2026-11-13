# Interface graphique pour lancer le projet campusflow_models.
# Démarrer avec Lanceur.bat (double-clic) à la racine du projet.

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Lance une commande dart en arrière-plan et récupère sa sortie ligne par ligne,
# pour que la fenêtre ne se fige pas pendant l'exécution (comme un Future).
Add-Type -TypeDefinition @'
using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Text;

public class DartRunner {
    public ConcurrentQueue<string> Lignes = new ConcurrentQueue<string>();
    public volatile bool Termine = true;
    public int CodeSortie;

    public void Lancer(string arguments, string dossier) {
        Termine = false;
        var info = new ProcessStartInfo("cmd.exe", "/c dart " + arguments);
        info.WorkingDirectory = dossier;
        info.UseShellExecute = false;
        info.CreateNoWindow = true;
        info.RedirectStandardOutput = true;
        info.RedirectStandardError = true;
        info.StandardOutputEncoding = Encoding.UTF8;
        info.StandardErrorEncoding = Encoding.UTF8;

        var p = new Process();
        p.StartInfo = info;
        p.EnableRaisingEvents = true;
        p.OutputDataReceived += (s, e) => { if (e.Data != null) Lignes.Enqueue(e.Data); };
        p.ErrorDataReceived += (s, e) => { if (e.Data != null) Lignes.Enqueue(e.Data); };
        p.Exited += (s, e) => {
            p.WaitForExit(); // attend la fin de la lecture de la sortie
            CodeSortie = p.ExitCode;
            Termine = true;
        };
        p.Start();
        p.BeginOutputReadLine();
        p.BeginErrorReadLine();
    }
}
'@

$projet = Split-Path -Parent $PSScriptRoot
$runner = New-Object DartRunner
$file = New-Object System.Collections.Queue   # étapes en attente
$etapeCourante = $null

$etapes = [ordered]@{
    'Dependances' = @{ Titre = 'Dépendances'; Args = 'pub get' }
    'Analyse'     = @{ Titre = 'Analyse';     Args = 'analyze' }
    'Tests'       = @{ Titre = 'Tests';       Args = 'test --reporter expanded --no-color' }
    'Exemple'     = @{ Titre = 'Exemple';     Args = 'run example/campusflow_models_example.dart' }
}

# --- Couleurs ---
$rouge  = [System.Drawing.Color]::FromArgb(236, 48, 19)   # accent CampusFlow
$fond   = [System.Drawing.Color]::FromArgb(30, 30, 30)
$texte  = [System.Drawing.Color]::FromArgb(220, 220, 220)
$vert   = [System.Drawing.Color]::FromArgb(110, 200, 120)
$erreur = [System.Drawing.Color]::FromArgb(255, 110, 100)
$titre  = [System.Drawing.Color]::FromArgb(120, 170, 255)

# --- Fenêtre ---
$form = New-Object System.Windows.Forms.Form
$form.Text = 'CampusFlow · Lanceur'
$form.Size = New-Object System.Drawing.Size(900, 620)
$form.MinimumSize = New-Object System.Drawing.Size(640, 400)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)

$entete = New-Object System.Windows.Forms.Label
$entete.Text = 'CampusFlow · campusflow_models'
$entete.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 15)
$entete.ForeColor = $rouge
$entete.Dock = 'Top'
$entete.Height = 44
$entete.Padding = New-Object System.Windows.Forms.Padding(12, 10, 0, 0)

$barre = New-Object System.Windows.Forms.FlowLayoutPanel
$barre.Dock = 'Top'
$barre.Height = 52
$barre.Padding = New-Object System.Windows.Forms.Padding(8, 6, 8, 0)

$console = New-Object System.Windows.Forms.RichTextBox
$console.Dock = 'Fill'
$console.ReadOnly = $true
$console.BackColor = $fond
$console.ForeColor = $texte
$console.Font = New-Object System.Drawing.Font('Consolas', 10)
$console.BorderStyle = 'None'

$statut = New-Object System.Windows.Forms.StatusStrip
$statutTexte = New-Object System.Windows.Forms.ToolStripStatusLabel
$statutTexte.Text = 'Prêt.'
[void]$statut.Items.Add($statutTexte)

function Nouveau-Bouton($texteBouton, $principal) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $texteBouton
    $b.AutoSize = $true
    $b.Height = 36
    $b.FlatStyle = 'Flat'
    $b.Margin = New-Object System.Windows.Forms.Padding(4)
    $b.Padding = New-Object System.Windows.Forms.Padding(8, 0, 8, 0)
    if ($principal) {
        $b.BackColor = $rouge
        $b.ForeColor = [System.Drawing.Color]::White
        $b.FlatAppearance.BorderSize = 0
    }
    $barre.Controls.Add($b)
    return $b
}

function Ecrire($ligne, $couleur) {
    $ligne = $ligne -replace "$([char]27)\[[0-9;]*m", ''   # retire les codes couleur du terminal
    if (-not $couleur) {
        $couleur = $texte
        if ($ligne -match 'All tests passed|No issues found|Got dependencies|^\s+- Task') { $couleur = $vert }
        elseif ($ligne -match 'Erreur|error|failed|\[E\]|Exception') { $couleur = $erreur }
    }
    $console.SelectionStart = $console.TextLength
    $console.SelectionColor = $couleur
    $console.AppendText($ligne + "`r`n")
    $console.ScrollToCaret()
}

function Activer-Boutons($actif) {
    foreach ($b in $barre.Controls) { if ($b.Tag -ne 'toujours') { $b.Enabled = $actif } }
}

function Lancer-Suivante {
    if ($file.Count -eq 0) {
        $script:etapeCourante = $null
        Activer-Boutons $true
        return
    }
    $script:etapeCourante = $file.Dequeue()
    Ecrire ''
    Ecrire ("=== {0}  (dart {1}) ===" -f $etapeCourante.Titre, $etapeCourante.Args) $titre
    $statutTexte.Text = "En cours : $($etapeCourante.Titre)…"
    $runner.Lancer($etapeCourante.Args, $projet)
}

function Demarrer($cles) {
    if ($etapeCourante) { return }
    $file.Clear()
    foreach ($c in $cles) { $file.Enqueue($etapes[$c]) }
    Activer-Boutons $false
    Lancer-Suivante
}

# --- Boutons ---
$bTout = Nouveau-Bouton '▶  Tout lancer' $true
$bTout.Add_Click({ Demarrer @($etapes.Keys) })

foreach ($cle in $etapes.Keys) {
    $b = Nouveau-Bouton $etapes[$cle].Titre $false
    $b.Tag = $cle
    $b.Add_Click({ param($s) Demarrer @($s.Tag) })
}

$bEffacer = Nouveau-Bouton 'Effacer' $false
$bEffacer.Tag = 'toujours'
$bEffacer.Add_Click({ $console.Clear() })

$bDossier = Nouveau-Bouton 'Dossier' $false
$bDossier.Tag = 'toujours'
$bDossier.Add_Click({ Start-Process explorer.exe $projet })

$bGithub = Nouveau-Bouton 'GitHub' $false
$bGithub.Tag = 'toujours'
$bGithub.Add_Click({ Start-Process 'https://github.com/ERWANS2003/campusflow_models' })

# --- Boucle de lecture : vide la sortie et enchaîne les étapes ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 100
$timer.Add_Tick({
    $ligne = $null
    while ($runner.Lignes.TryDequeue([ref]$ligne)) { Ecrire $ligne }

    if ($etapeCourante -and $runner.Termine -and $runner.Lignes.IsEmpty) {
        if ($runner.CodeSortie -eq 0) {
            Ecrire ("✔ {0} : OK" -f $etapeCourante.Titre) $vert
            $statutTexte.Text = "$($etapeCourante.Titre) : OK"
            Lancer-Suivante
        } else {
            Ecrire ("✘ {0} : échec (code {1})" -f $etapeCourante.Titre, $runner.CodeSortie) $erreur
            $statutTexte.Text = "Échec : $($etapeCourante.Titre)"
            $file.Clear()
            Lancer-Suivante
        }
    }
})
$timer.Start()

$form.Controls.Add($console)
$form.Controls.Add($barre)
$form.Controls.Add($entete)
$form.Controls.Add($statut)

Ecrire 'Choisis une étape, ou « Tout lancer » pour tout enchaîner.' $titre
Ecrire "Projet : $projet"

[void]$form.ShowDialog()
$timer.Stop()
