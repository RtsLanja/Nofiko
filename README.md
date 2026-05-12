# 🔔 Nofiko — Plateforme intelligente d'alertes d'emploi

> **Nofiko** est une application mobile intelligente conçue pour automatiser la recherche d'emploi et améliorer la pertinence des candidatures grâce à un système de recommandation basé sur les compétences et les profils utilisateurs.

---

## 📋 Table des matières

- [Aperçu](#-aperçu)
- [Fonctionnalités](#-fonctionnalités)
- [Architecture](#-architecture)
- [Technologies](#-technologies)
- [Structure du projet](#-structure-du-projet)
- [Installation](#-installation)
- [Roadmap](#-roadmap)
- [Auteur](#-auteur)

---

## 🧭 Aperçu

Nofiko centralise les offres d'emploi provenant de **plusieurs plateformes de recrutement** en un seul endroit. Grâce au web scraping automatique et à un moteur de recommandation intelligent, l'application envoie des alertes personnalisées en temps réel adaptées au profil et aux compétences de chaque utilisateur.

---

## ✨ Fonctionnalités

### ✅ Implémentées
- 🔍 **Collecte automatique d'offres** via web scraping (Playwright) depuis plusieurs plateformes de recrutement
- 🎯 **Système de recommandation** basé sur les compétences et le profil utilisateur
- 🔔 **Alertes personnalisées en temps réel** pour les nouvelles offres correspondant au profil
- 📦 **Centralisation des offres** provenant de multiples sources

### 🚧 En cours de développement
- 📄 **Génération automatique de CV** adapté à chaque offre d'emploi

---

## 🏗️ Architecture

Le projet est organisé en un seul dépôt contenant deux dossiers principaux :

```
Nofiko/
├── nofiko_app/     # Application mobile (Flutter)
└── API-Nofiko/     # Backend API (FastAPI)
```

### `nofiko_app/` — Frontend mobile
Application mobile cross-platform développée avec Flutter, disponible sur Android, iOS, Web, Linux, macOS et Windows.

### `API-Nofiko/` — Backend
API REST développée avec FastAPI, comprenant le moteur de scraping, le système de recommandation et la gestion des alertes.

---

## 🛠️ Technologies

| Couche | Technologie |
|--------|-------------|
| Mobile | Flutter / Dart |
| Backend API | FastAPI (Python) |
| Web Scraping | Playwright |
| Base de données | PostgreSQL (via Alembic) |
| Migrations | Alembic |
| Versioning | Git / GitHub |

---

## 📁 Structure du projet

### `nofiko_app/`
```
nofiko_app/
├── android/        # Configuration Android
├── ios/            # Configuration iOS
├── lib/            # Code source Flutter (Dart)
├── assets/         # Ressources (images, fonts...)
├── web/            # Configuration Web
├── linux/          # Configuration Linux
├── macos/          # Configuration macOS
├── windows/        # Configuration Windows
├── test/           # Tests unitaires et d'intégration
└── README.md
```

### `API-Nofiko/`
```
API-Nofiko/
├── app/            # Code source FastAPI (routes, modèles, services)
├── scraper/        # Modules de web scraping (Playwright)
├── alembic/        # Migrations de base de données
├── uploads/        # Fichiers uploadés
├── requirements.txt
└── test.py
```

---

## 🚀 Installation

### Prérequis
- Flutter SDK ≥ 3.x
- Python ≥ 3.10
- PostgreSQL

```bash
# Cloner le dépôt
git clone https://github.com/RtsLanja/Nofiko.git
cd Nofiko
```

### Backend (API-Nofiko)

```bash
cd API-Nofiko

# Créer un environnement virtuel
python -m venv venv
source venv/bin/activate  # Windows : venv\Scripts\activate

# Installer les dépendances
pip install -r requirements.txt

# Installer le navigateur pour Playwright
playwright install

# Appliquer les migrations
alembic upgrade head

# Lancer le serveur
uvicorn app.main:app --reload
```

### Frontend (nofiko_app)

```bash
cd ../nofiko_app

# Installer les dépendances Flutter
flutter pub get

# Lancer l'application
flutter run
```

---

## 🗺️ Roadmap

- [x] Système de scraping automatique des offres d'emploi
- [x] Moteur de recommandation basé sur les compétences
- [x] Alertes personnalisées en temps réel
- [x] Centralisation multi-sources
- [ ] Génération automatique de CV adapté aux offres
- [ ] Tableau de bord de suivi des candidatures
- [ ] Support de nouvelles plateformes de recrutement

---

## 👤 Auteur

**Razakamanana Rantosoa Lanja**  
Développeur Full-Stack  
📧 rantorazaka12@gmail.com  
🌐 [rtslanja-portfolio.netlify.app](https://rtslanja-portfolio.netlify.app)  
💼 [linkedin.com/in/rantorazakamanana-9605a9310](https://linkedin.com/in/rantorazakamanana-9605a9310)  
🐙 [github.com/RtsLanja](https://github.com/RtsLanja)

---

> Projet en cours de développement — Démarré en février 2026
