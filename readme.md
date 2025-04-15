## Projet403

**Binôme** : CHEN Florent (21101813), TOROSSI Valentino (28715028)  

**GitHub** : [Lien vers le projet 1](https://github.com/FlorentChen2002/Beta/tree/main)

**Vidéo** : [Lien vers la vidéo de démonstration du projet 1](https://www.youtube.com/watch?v=nqbnR5M5GTs&ab_channel=FlorentChen)

**GitHub** : [Lien vers le TME 10/11 ](https://github.com/FlorentChen2002/Alpha)

**Vidéo** : [Lien vers la vidéo de démonstration du tme 10/11](https://www.youtube.com/watch?v=mbJdkHJON4s&ab_channel=FlorentChen)

---
### 🚀 Lancement du projet

Dans la racine du projet, vous trouverez un script **`commande.sh`** qui permet de lancer ou d'arrêter le projet en fonction de l'argument passé en paramètre. (il manque le dossier node_modules, car il était trop volumineux)

#### Commandes disponibles :

- `start` : Lance le projet.
- `stop` : Arrête le projet.

Exemple d'utilisation du script :

```bash
# Pour démarrer le projet
./commande.sh start

# Pour arrêter le projet
./commande.sh stop
```
---

## Partie 1 : Infrastructure de base (Strapi, PostgreSQL, Frontend React)

Afin de faciliter l'exécution, la communication entre les conteneurs et la compréhension du projet, nous avons décidé d'utiliser **Docker Compose**.

### Prérequis

#### Étape 1 : Déploiement de la base de données PostgreSQL

Exécuter la commande suivante pour déployer PostgreSQL :

```bash
docker run -dit -p 5432:5432 -e POSTGRES_PASSWORD=safepassword -e POSTGRES_USER=strapi --name strapiDB postgres:latest
```

### Étape 2 : Création du projet Strapi

1. Créer un projet Strapi avec la commande suivante :

   ```bash
   yarn create strapi-app@4.12.0 mon-projet-strapi
   ```
   > ℹ️ Dans notre cas, le projet s'appelle **`projet-omega`**.
2. Ajouter les fichiers nécessaires à la conteneurisation :
   - Un fichier `Dockerfile`
   - Un fichier `docker-compose.yml`
### Étape 3 : Création d'un modèle **Product** et **Event**

Dans l'interface Strapi, créez une nouvelle collection nommé **product** avec les champs suivants :

| Champ              | Type          | Description                                   |
|--------------------|---------------|-----------------------------------------------|
| `name`             | Short text    | Nom du produit                                |
| `description`      | Long text     | Description complète                          |
| `stock_available`  | Integer       | Quantité disponible (défaut : `0`)            |
| `image`            | Media (image) | Une seule image autorisée                     |
| `barcode`          | Short text    | Code-barres du produit                        |
| `status`           | Enumeration   | Valeurs possibles : `safe`, `danger`, `empty` |

créez une nouvelle collection nommé **event** avec les champs suivants :
| Champ       | Type   | Description                       |
|-------------|--------|-----------------------------------|
| `value`     | String | Valeur de l’événement             |
| `metadata`  | JSON   | Informations supplémentaires      |

### Étape 4 : Génération d’un **Token API**
Créez un nouveau token en donnant accès aux collections dans strapi

### Étape 5 : Installation du frontend
1. Se déplacer dans le dossier du projet :
   ```bash
   cd projet-omega
   yarn install
   ```
2. Cloner le frontend :
   ```bash
   git clone https://github.com/arthurescriou/opsci-strapi-frontend.git
   ```
3. Modifier le fichier `opsci-strapi-frontend/src/conf.ts` :
	- Remplacer l'URL par `http://localhost:1337`
	- Remplacer le token par celui généré dans Strapi
### Étape 6 : Mise à jour du docker compose
Mettre en lien les différents contenaires à l'aide du docker compose

## Informations

### Frontend react

- **Nom du projet** : `opsci-strapi-frontend`  
- **Port** : `5173`  
- **Adresse IP locale** : [http://localhost:5173/](http://localhost:5173/)  
- **Nom du conteneur** : `opsci-strapi-frontend`

---

### Strapi

- **Nom du projet** : `projet-omega`  
- **Port** : `1337`  
- **Adresse IP locale** : [http://localhost:1337](http://localhost:1337)  
- **Nom du conteneur** : `strapi`  
- **Nom de la base de données** : `projet-omega`

---

### Base de données PostgreSQL

- **Nom du conteneur** : `strapiDB`
- **Port** : `5432` 
- **Image**:`postgres:15`

## Logs et Images

Les logs et les images du projet sont disponibles dans les répertoires suivants :

- **`image_docker_ps`** : Contient les informations sur l'état des conteneurs Docker en cours d'exécution.
- **`image_event_strapi`** : Image relatifs aux événements traités par Strapi.
- **`image_prod_strapi`** : Image liés à la gestion des produits dans Strapi.
- **`image_react`** et **`image_react2`**: Image concernant le frontend React de l'application.
- **`log_Bdd`** et **`log_Bdd2`** : Logs de la base de données, incluant les interactions avec PostgreSQL et Strapi.

---
## Partie 2 : Architecture avec Kafka

On souhaite créer un système permettant d’intégrer de grande quantité de données venant de différents flux avec beaucoup de résilience à l’erreur. Donc on va mettre en place une architecture de gestion de flux de données en temps réel à l’aide de **Kafka**, en intégrant **Strapi** pour l’interface de gestion des produits et événements.

### Déploiement de Kafka & Zookeeper  
 Kafka nécessite plusieurs **topics** pour fonctionner correctement. Voici les principaux topics utilisés dans ce projet :

| Topic   | Description                                                                                  |
|---------|----------------------------------------------------------------------------------------------|
| `product` | Un topic dédié à la création de nouveaux produits en masse, venant de différentes sources. |
| `event`   | Un topic dédié à la création d'événements, en lien avec la gestion des produits.           |
| `stock`   | Un topic pour enregistrer et appliquer tous les mouvements de stocks de nos produits.      |
| `error`   | Un topic pour le stockage des erreurs diverses rencontrées lors des échanges de données.   |

Installer les Producers & Consumers disponibles danzs le github :
```bash
cd projet-omega
git clone https://github.com/opsci-su/stock-consumer.git
git clone https://github.com/opsci-su/event-producer.git
git clone https://github.com/opsci-su/stock-producer.git
git clone https://github.com/opsci-su/product-producer.git
git clone https://github.com/opsci-su/product-consumer.git
git clone https://github.com/opsci-su/event-consumer.git
```
### Flux de données avec Kafka

- **Producers** envoient des messages aux **consumers** via Kafka.
- Ces messages sont utilisés pour alimenter Strapi avec des données concernant les produits, les événements, et les mouvements de stocks.

### Logs

Les logs des **producers** et **consumers** sont disponibles dans le dossier **log**. Vous y trouverez les fichiers suivants :

- `log_product_consumer` : Logs du consumer pour les produits.
- `log_product_producer` : Logs du producer pour les produits.
- `log_event_consumer` : Logs du consumer pour les événements.
- `log_event_producer` : Logs du producer pour les événements.
- `log_stock_consumer` : Logs du consumer pour les mouvements de stock.
- `log_stock_producer` : Logs du producer pour les mouvements de stock.

## TME 10-11 : Intégration IoT via MQTT et Kafka

Le but de la seconde partie du projet, est de mettre en place un support de communication permettant à un objet connecté (via MQTT) de mettre à jour le stock d’un produit, et que cette info remonte jusqu’à Strapi, grâce à Kafka.

---
### Prérequis

1. Mettre en place un scripte dans /mosquitto/mosquitto.conf
```conf
persistence true
persistence_location /mosquitto/data/
log_dest file /mosquitto/log/mosquitto.log
allow_anonymous true
listener 1883
protocol websockets
```
2. Configurer le docker compose en ajoutant le lancement du scripte mosquitto et de la connexion avec kafka

---

### Architecture mise en place

**Frontend (MQTT over WebSocket)**
   ↓
**Mosquitto** *(broker MQTT)*
   ↓
**Connecteur MQTT → Kafka** *(arthurescriou/mqtt-kafka-connector)*
   ↓
**Kafka** *(topic: `stock`)*
   ↓
**Consumer Kafka**
   ↓
**Strapi** *(mise à jour du stock produit)*


---

### Déroulé de la chaîne

1. Le **navigateur** publie un message MQTT vers **Mosquitto**, via WebSocket (port `1883`) (site:`https://mqtt-test-front.onrender.com/` ).
2. Le **connecteur** `mqtt-kafka-connector` écoute le topic MQTT `"topic"` et publie le message dans le topic Kafka `"stock"`.
3. Un **consumer Kafka** lit le message et effectue une requête vers le **Strapi** pour mettre à jour le stock du produit correspondant.
4. Le **changement de stock** est alors visible dans le **dashboard Strapi** et dans le **Frontend**.

### Logs

- `log_mosquitto_connexion` : Logs des réceptions des messages et la transmission des messages à kafka.
- `log_stock_consumer_mqtt` : Logs du consumer pour les mouvements de stock.