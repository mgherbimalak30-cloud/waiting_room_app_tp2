# Compte-rendu des discussions avec l’IA

## 1. Introduction

Pour réaliser le Workshop 4, j’ai utilisé ChatGPT (OpenAI) pour m’aider à comprendre les étapes du TP et à poursuivre le développement de mon projet Flutter existant.

L’objectif de ce workshop est de transformer l’application Waiting Room en une application connectée à Supabase, permettant de stocker les clients dans une base de données en ligne et de synchroniser les changements en temps réel.

## 2. Travail réalisé avec l’IA

J’ai demandé à ChatGPT de m’expliquer les étapes du TP progressivement et de m’aider à adapter le code à mon projet existant, sans supprimer les fonctionnalités déjà réalisées.

Les principales tâches effectuées sont les suivantes :

- Vérifier la structure du projet Flutter et les fichiers existants.
- Installer et configurer les packages `supabase_flutter` et `flutter_dotenv`.
- Configurer les informations de connexion à Supabase à l’aide du fichier `.env`.
- Créer et adapter le modèle `Client` pour représenter les données de la table `clients`.
- Modifier `queue_provider.dart` pour récupérer les clients depuis Supabase.
- Mettre en place l’ajout et la suppression des clients dans la base de données.
- Utiliser Provider et `ChangeNotifier` pour mettre à jour l’interface utilisateur.
- Mettre en place un flux Realtime pour écouter les changements de la table `clients`.
- Vérifier la configuration de la publication `supabase_realtime` dans le tableau de bord Supabase.
- Tester l’application dans le navigateur Chrome et analyser les problèmes de synchronisation.

## 3. Difficultés rencontrées

Pendant le développement, plusieurs difficultés ont été rencontrées.

La première concernait la configuration de Supabase et la connexion entre Flutter et la base de données. J’ai également rencontré une erreur liée à la reconnaissance de la classe `Client` et à l’adaptation des types de données utilisés dans le projet.

Une autre difficulté concernait la synchronisation en temps réel. Les clients étaient bien enregistrés dans Supabase et apparaissaient dans l’application après l’actualisation de la page, mais les changements n’étaient pas immédiatement visibles dans les deux onglets Chrome.

Avec l’aide de ChatGPT, j’ai vérifié le code du flux Realtime et identifié la publication `supabase_realtime` dans le tableau de bord Supabase afin de corriger la configuration.

J’ai également essayé d’utiliser Antigravity, mais son agent a rencontré une erreur. J’ai donc poursuivi le travail avec ChatGPT.

## 4. Ce que j’ai appris

Grâce à ce travail, j’ai appris à :

- Connecter une application Flutter à une base de données Supabase.
- Utiliser le fichier `.env` pour organiser les informations de configuration.
- Comprendre le rôle de Provider et de `ChangeNotifier` dans la gestion de l’état.
- Récupérer, ajouter et supprimer des clients dans une base de données distante.
- Utiliser les flux Supabase pour recevoir les changements de données.
- Comprendre l’importance de la configuration Realtime et des politiques d’accès à la base de données.
- Tester une application sur plusieurs onglets du navigateur.
- Analyser les erreurs et vérifier le code avec les outils Flutter.

## 5. Conclusion

L’utilisation de ChatGPT m’a aidée à comprendre les différentes étapes du Workshop 4 et à résoudre progressivement les difficultés rencontrées pendant le développement.

Ce travail m’a permis de découvrir la connexion entre Flutter et Supabase, ainsi que le principe de synchronisation des données en temps réel. Il m’a également permis d’améliorer ma compréhension de Provider et de la gestion de l’état dans une application Flutter.

L’intelligence artificielle a été utilisée comme un outil d’assistance à l’apprentissage et au développement. Les explications et les corrections proposées m’ont aidée à avancer dans le projet et à mieux comprendre les technologies utilisées.