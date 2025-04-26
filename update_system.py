#!/usr/bin/env python3
import subprocess
import logging
import os
import sys
from datetime import datetime

# Chemin du fichier de log
LOG_FILE = "/var/log/update_kali.log"

def run_cmd(cmd):
    """Exécute cmd (liste) et journalise stdout/stderr."""
    logging.info(f"Démarrage de la commande : {' '.join(cmd)}")
    try:
        result = subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.stdout:
            logging.info(result.stdout.strip())
        if result.stderr:
            logging.warning(result.stderr.strip())
    except subprocess.CalledProcessError as e:
        logging.error(f"Erreur (code {e.returncode}) sur {' '.join(cmd)}")
        logging.error(e.stderr.strip())
        sys.exit(e.returncode)

def main():
    # Vérification des droits root
    if os.geteuid() != 0:
        sys.exit("ERREUR : ce script doit être exécuté en tant que root.")

    # Configuration du logging
    logging.basicConfig(
        filename=LOG_FILE,
        level=logging.INFO,
        format="%(asctime)s %(levelname)s: %(message)s"
    )
    logging.info("=== Début de la mise à jour système ===")

    # Séquence de commandes APT
    commands = [
        ["apt-get", "update"],
        ["apt-get", "dist-upgrade", "-y"],
        ["apt-get", "autoremove", "-y"],
        ["apt-get", "autoclean", "-y"]
    ]

    for cmd in commands:
        run_cmd(cmd)

    logging.info("=== Mise à jour système terminée avec succès ===")

if __name__ == "__main__":
    main()
