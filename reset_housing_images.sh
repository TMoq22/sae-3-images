#!/usr/bin/env bash
set -euo pipefail

# Configuration 
REPO_URL="URL_DE_TON_REPO_GIT.git"
BRANCH="main"

TARGET_UPLOADS_DIR="$HOME/sae/data/web/html/uploads"
TARGET_HOUSING_DIR="$TARGET_UPLOADS_DIR/housing"
TMP_DIR="$(mktemp -d)"

# Nettoyage automatique du dossier temporaire en fin d'exécution
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# Vérifications de sécurité 
if [[ "$REPO_URL" == "URL_DE_TON_REPO_GIT.git" ]]; then
    echo "Erreur : remplace REPO_URL par l'URL de ton dépôt Git avant d'exécuter le script." >&2
    exit 1
fi

if [[ ! -d "$TARGET_UPLOADS_DIR" ]]; then
    echo "Erreur : le dossier cible $TARGET_UPLOADS_DIR n'existe pas." >&2
    exit 1
fi

# Suppression des images/sous-dossiers existants dans housing/ 
echo "Nettoyage de $TARGET_HOUSING_DIR..."
mkdir -p "$TARGET_HOUSING_DIR"
find "$TARGET_HOUSING_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

# Clonage du dépôt dans un dossier temporaire 
echo "Clonage du dépôt depuis $REPO_URL..."
git clone --depth 1 --branch "$BRANCH" "$REPO_URL" "$TMP_DIR/repo"

if [[ ! -d "$TMP_DIR/repo/housing" ]]; then
    echo "Erreur : le dossier 'housing/' est introuvable à la racine du dépôt cloné." >&2
    exit 1
fi

# Copie du dossier housing/ vers uploads/  
echo "Copie des nouvelles images vers $TARGET_HOUSING_DIR..."
cp -a "$TMP_DIR/repo/housing/." "$TARGET_HOUSING_DIR/"

# Optionnel : ajuster les droits si un serveur web (Apache/Nginx/Docker) lit ces fichiers
chmod -R a+rX "$TARGET_HOUSING_DIR"
echo "Terminé : les images de housing/ ont été réinitialisées avec succès."