v0.1.0

# Rostra - S'engager ensemble

## Définition

Rostra est un moteur de gouvernance participative. Il est collaboratif, intuitif (complexité progressive paramétrable), orienté-action.

Rostra permet à tout individu ou organisation de créer un espace dans lequel la prise de décision est abordée collaborativement, en toute transparence.

Rostra existe pour rendre la prise de décision communautaire simple : des votes d'assemblée générale à la direction d'un projet open-source, dès qu'il est question d'influencer des décisions de manière transparente et collégiale, Rostra est une réponse concrète fonctionnant à échelle.

## Fonctionnement général

Les administrateurs définissent les règles d'approbation, et les membres font vivre l'espace selon des règles prédéfinies transparentes : chaque membre peut être force de proposition, ou simplement contribuer par des suggestions de changements ou, évidemment, par le positionnement (vote).

Il existe trois rôles au sein d'un espace :
- les *contributeurs* (rôle de base : vote, suggestion, initiative)
- les *administrateurs* (propriétaires de l'espace : régissent les règles et composantes)
- les *modérateurs* (régissent le contenu selon les permissions des administrateurs)

> Le terme *membre* désigne tout individu appartenant à un espace, quel que soit son rôle. Un administrateur est donc aussi un membre.

> Note : le statut de *garant*, mentionné ci-après, n'est pas un rôle global mais une permission additionnelle accordée à un membre sur un sujet spécifique. Un garant voit sa voix peser davantage uniquement sur les initiatives associées au sujet pour lequel il a été désigné.

> TODO : définir les actions de modération disponibles (masquer un éclairage, retirer une initiative, etc.) et leur gouvernance (permission administrateur requise).

### Orientée-action

Éliminer la paralysie analytique par des mécanismes psychologiques (association des initiatives aux actions, wording), mécanismes de durée, édition itérative collaborative à base de suggestions.

> Les termes passifs — idée, discussion, etc. — ne doivent pas être utilisés. Nous utilisons des termes actifs et engageants : *soutenir*, *s'opposer*, *suggérer*.

La zone de commentaire n'est accessible qu'en se positionnant.

### Complexité progressive

Sans configuration, l'interface est sobre et les flux sont minimaux : créer un espace, publier une initiative, se positionner. Aucun apprentissage requis.

C'est le paramétrage administrateur qui ajoute de la complexité — optionnelle, choisie, proportionnelle aux besoins de l'espace :

- Activer la validation de publication par modérateur ou garant
- Définir des sujets et désigner des garants
- Configurer les quorums, les délais et les protocoles d'arbitrage
- Restreindre ou élargir les permissions par rôle

Toute feature avancée est inactive par défaut. Aucun flux de base ne suppose ni n'expose les paramétrages avancés.

---

## Lexique

- *Espace* *(Space)* : espace participatif réunissant des membres autour d'un ensemble d'initiatives et de décisions régies selon des règles prédéfinies.

- *Initiative* *(Initiative)* : proposition publiée et ouverte au vote. États possibles :
  - *Ébauche* *(Draft)* : état initial d'une initiative non publiée. Elle n'est visible que par son auteur (et les administrateurs / modérateurs selon les permissions). Elle peut être éditée librement. Des suggestions internes (par l'auteur) sont possibles. Aucun arbitrage n'est en cours. La publication explicite par l'auteur est l'action qui fait passer l'initiative en état Arbitrage.
  - *Arbitrage X* *(Arbitration X)* : état transitoire, l'initiative est publiée et la délibération en cours. X modifications ont été appliquées depuis ouverture.
  - *Scelée* *(Sealed)* : le scellage — automatique par inactivité ou manuel par un ayant droit — ne peut se déclencher **que si** le quorum minimum de membres ayant voté (ENDORSE ou OPPOSE) est atteint. Une fois l'initiative scellée, elle est considérée stable et un délai est déclenché, à l'issue duquel le protocole sera automatiquement exécuté.
    Les conditions de déclenchement sont régies par les règles administrateur.
    Exemples : automatique après inactivité de X heures ; manuel par garant hors auteur.
    > Note : des flags *Mineur / Majeur* pourraient exister pour influencer les règles.
  - *Adoption* *(Adoption)* : état final : adoptée suite à l'application de la matrice d'arbitrage. État alternatif à *Classée*.
    > Note : un flag *"réalisée"* associé à une preuve (simple "commentaire" de conclusion) permet de marquer l'application concrète de l'initiative adoptée.
  - *Classée* *(Dismissal)* : rejet suite à l'application du protocole. État alternatif à l'adoption.

- *Sujet* *(Topic)* : système de tags créés par les administrateurs. Les sujets peuvent être associés à toute initiative par les ayants droit. Des garants peuvent être associés à des sujets par les administrateurs.

- *Garants* *(Steward)* : membres ou modérateurs désignés garants d'un sujet spécifique par les administrateurs. Le statut de garant n'est pas un rôle global : c'est une permission additionnelle liée à un sujet. Le terme utilisé dans toute l'interface et la documentation est *garant*.* La voix d'un garant a plus de poids uniquement sur les initiatives associées au sujet pour lequel il a été désigné. Ce poids est exprimé en nombre de voix (et non en pourcentage). En cas d'égalité dans le décompte du protocole, le poids des garants est utilisé comme facteur de décision. Ce poids ne se cumule pas : même si un garant est associé à plusieurs sujets liés à la même initiative, il compte une seule fois avec le poids défini dans les règles de l'espace.
  Les garants sont désignés par les administrateurs, via l'association à un tag.
  Un garant peut amender une initiative.
  Un garant est visuellement mis en valeur dans le fil de délibération.
  > TODO : les garants peuvent être élus (fonctionnalité similaire aux initiatives).

- *Protocole (d'arbitrage)* *(Arbitration Protocol)* : action automatisée et/ou manuelle, entérinant une initiative selon des règles pré-définies par l'administrateur. Exemples : soutien à l'unanimité ; majorité + validation par un garant.

- *Registre de décisions* *(Decision Registry)* : index consultable de toutes les initiatives en état `ADOPTED` ou `EXECUTED` au sein d'un espace. Les décisions adoptées y sont indexées en texte intégral (titre, contenu, sujets associés, preuve de réalisation), permettant une recherche full-text native. Le registre constitue la mémoire institutionnelle de l'espace : toute décision adoptée y est automatiquement versée, sans action manuelle. Il est accessible en lecture à tous les membres de l'espace.
  > V2 : recherche sémantique assistée par IA (embeddings vectoriels).

- *Fil d'arbitrage* *(Arbitration Thread)* : historique des positionnements associés à une initiative.

- *Positionnement* *(Stance)* : acte de se positionner vis-à-vis d'une initiative. Il existe quatre stances :
  - *Soutenir* *(Endorse)* : soutien net à l'initiative. Entre dans le décompte du protocole.
  - *Désapprouver* *(Oppose)* : opposition nette à l'initiative. Entre dans le décompte du protocole.
  - *Suggérer* *(Suggest)* : positionnement conditionnel — ni soutien net, ni opposition nette. Sémantique : "je suis favorable à cette initiative sous réserve que ma suggestion soit intégrée" ou "je suis contre en l'état, mais je me repositionnerai si ma suggestion est acceptée". N'entre pas dans le décompte du protocole, mais enrichit la délibération de manière active et visible dans le fil. Une suggestion cite le texte d'origine et propose une modification.
    > Alternative écartée : avoir seulement 2 stances (ENDORSE / OPPOSE) où suggérer serait simplement un éclairage facultatif couplé à une stance. Écarté car cela perd la nuance du positionnement conditionnel et empêche de distinguer dans le fil "je soutiens" de "je soutiens SI...".
  - *Clarifier* *(Clarify)* : positionnement à part entière — demande explicite d'éclaircissement adressée à l'auteur avant de pouvoir se positionner autrement. N'entre pas dans le décompte du protocole, mais est un acte actif visible dans le fil.
    > Une stance CLARIFY peut être déclarée **résolue** (et la déclaration peut être annulée) par : l'auteur de l'initiative, l'auteur de la clarification, ou un garant (selon les règles de l'espace). La résolution est tracée par les champs `resolved_by` et `resolved_at` dans la table `stances` (null = non résolue). Une fois résolue, l'auteur de la clarification peut se repositionner (ENDORSE, OPPOSE, SUGGEST ou une nouvelle CLARIFY) comme après n'importe quelle stance — il n'y a pas de mécanique spéciale.

  Apporter un éclairage est conditionné par le fait de se positionner (ENDORSE, OPPOSE, SUGGEST, CLARIFY). L'éclairage est facultatif : au clic sur une position, la zone de commentaire est activée et le bouton de soumission envoie les deux simultanément (le commentaire peut être vide). Un seul éclairage par positionnement est autorisé.
  Le positionnement peut être édité, auquel cas le commentaire lui-même est mis à jour, et rendu visible dans le fil à la date d'édition (et non pas à la date de soumission initiale).
  L'auteur ne peut pas se positionner sur sa propre initiative (ni ENDORSE, ni OPPOSE, ni SUGGEST, ni CLARIFY). Il peut uniquement réagir aux éclairages du fil en se positionnant sur un éclairage existant (via `parent_stance_id`).
  Répondre à un éclairage requiert de se positionner sur cet éclairage (ENDORSE / OPPOSE sur l'éclairage lui-même), accompagné d'un éclairage facultatif. Cette action n'est pas récursive : il n'y a qu'un seul niveau de thread.

- *Éclairage* *(Rationale)* : commentaire facultatif associé à un positionnement. Peut accompagner une réponse à un éclairage existant (voir *Positionnement* pour la règle de non-récursivité).

- *Modérateurs* : membres disposant de droits de modération du contenu selon les permissions définies par les administrateurs.
  > TODO : définir les actions de modération disponibles (masquer un éclairage, retirer une initiative, etc.) et leur gouvernance (permission administrateur requise).

---

## Systèmes

### Matrice de permissions

Bien qu'un moteur de validation soit envisagé, dans un premier temps, des règles prédéfinies sont proposées :

| Action | Description | Type | Défaut |
|--------|-------------|------|--------|
| Publication d'une ébauche | Requiert validation par modérateur / garant ? | `bool` | `false` |
| Poids garant | Nombre de voix attribuées à **tous les garants** de l'espace pour les initiatives associées à leur sujet. Ce poids est défini une seule fois au niveau de l'espace et s'applique uniformément à tous les garants, sans distinction individuelle ou par sujet. Ne se cumule pas : un garant associé à plusieurs sujets d'une même initiative compte une seule fois. Tranche en cas d'égalité. | `uint8` (voix) | `2` |
| Protocole : pourcentage de validation initiative | (soutiens - opposants) / total utilisateurs | `uint8` (voix) | `100` |
| Matrice d'arbitrage : requiert N garant(s) | La validation manuelle par N garants est requise | `uint8` (nb) | `0` |
| Déclenchement du Scellage | Durée d'**inactivité** (absence d'éclairage, de positionnement, de suggestion et de clarification) avant scellage. `0` → pas de déclenchement. | `uint8` (heures) | `48` |
| Déclenchement du Protocole | Durée après scellage. `0` → pas de déclenchement. | `uint8` | `48` |
| Quorum minimum pour scellage | Pourcentage minimum de membres ayant voté (ENDORSE ou OPPOSE) pour que le scellage puisse se déclencher. `0` → pas de quorum requis. | `uint8` (%) | `0` |
| Créer initiative | Qui peut soumettre une nouvelle initiative ? | `enum` | contributeur / garant / admin |
| Déclencher protocole | Qui peut déclencher manuellement le protocole d'arbitrage ? | `enum` | — |
| Déclencher le scellage | Qui peut déclencher manuellement le scellage (hors déclenchement automatique par inactivité) ? | `enum` | garant / admin |
| Accepter suggestion | Qui peut intégrer une suggestion dans l'initiative (amender) ? | `enum` | auteur / garant |
| Clarifier | Qui peut soumettre une clarification ? | `enum` | contributeur / garant / admin / modérateur |
| Voir les ébauches | Qui peut voir les initiatives en état `DRAFT` autres que les siennes ? | `enum` | admin / modérateur |
| Modérateurs peuvent inviter des membres | Les modérateurs peuvent inviter des membres. Les administrateurs peuvent toujours inviter, sans paramétrage. | `bool` | `false` |

### Système d'édition

- En V1, le champ content JSONB d'une initiative contient uniquement du texte Markdown brut sous la forme `{ "type": "markdown", "body": "..." }`.
- En V2, ce champ est prévu pour évoluer vers un formulaire dynamique (sondages, champs structurés).
- Les métadonnées d'amendement (lien entre zones du texte et suggestions intégrées) sont stockées dans la table `suggestions`, pas dans `content`.
- Le système de collaboration est inspiré d'un CRDT allégé : les modifications concurrentes sont représentées comme des suggestions indépendantes (position, longueur, nouveau texte) dans la table `suggestions`. L'auteur intègre les suggestions de manière séquentielle. Il n'y a pas de résolution automatique de conflits en V1 : c'est l'auteur qui arbitre.
- Le versionnement du contenu après chaque amendement accepté repose sur un CRDT simplifié, dont le modèle s'inspire de l'approche décrite dans [Zed's CRDT implementation](https://zed.dev/blog/crdts). Chaque suggestion stocke `Vec<(index, length, new_text)>` ; l'historique des amendements permet de reconstituer les états successifs du texte.

### Machine à état

Voir le diagramme ci-dessous (section *Cycle de vie d'une initiative*) qui constitue la source de vérité unique pour les états et transitions. `SUGGEST` apparaît dans le fil d'arbitrage mais n'entre pas dans le décompte du protocole.

### Cycle de vie d'une initiative — Machine à état

```
       [ Ébauche / Draft ]
            |
            | Publication explicite par l'auteur
            v
       [ Arbitrage / Arbitration ] <--------+
            |                               |
            | Soutenir (ENDORSE)            | Suggérer (SUGGEST) — neutre au protocole
            | Désapprouver (OPPOSE)         | → Suggestion soumise, enrichit la délibération
            |                               |
            +-------------------------------+
            |
            |
            | [CLARIFY] ← positionnement possible à tout moment en Arbitrage,
            |             neutre au protocole, sans impact sur l'état
            |
            | Scellage (inactivité ou manuel par ayant droit)
            | [condition : quorum minimum atteint ET (inactivité >= seuil OU déclenchement manuel)]
            v
       [ Scelée / Sealed ]
            |
            | Expiration du délai
            v
  { Matrice d'Arbitrage }
            |
      +-----+-----+
      |           |
      v           v
 [ Adoption ]   [ Classée / Dismissed ]
      |
      | Fourniture d'une "preuve" de réalisation
      v
 [ Réalisée / Executed ]
```

---

## Onboarding

### Inscription

L'authentification repose sur Keycloak (voir Spécifications techniques). L'utilisateur peut s'inscrire via email/mot de passe ou OAuth (Google, GitHub, etc.).

À l'inscription, l'utilisateur est invité à rejoindre un espace existant (via un lien d'invitation reçu par email) ou à créer un nouvel espace.

Un utilisateur sans espace voit une page d'accueil l'invitant à créer ou rejoindre un espace. Il ne peut pas accéder au dashboard sans appartenir à au moins un espace.

### Création d'un espace

- Saisie du nom et d'une description.
- L'utilisateur créateur devient automatiquement administrateur de l'espace.
- Il peut ensuite configurer les règles, les sujets et inviter des membres depuis la vue *Gestion de l'espace*.

### Rejoindre un espace

- Via lien d'invitation : l'email contient un magic-link. Si l'utilisateur n'a pas de compte, il est redirigé vers l'inscription Keycloak, puis automatiquement ajouté à l'espace après authentification.
- Les administrateurs peuvent toujours inviter des membres. Les modérateurs peuvent le faire uniquement si la règle *"Modérateurs peuvent inviter des membres"* est activée dans la matrice de permissions (défaut : `false`).
- Si l'email n'est pas associé à un compte Keycloak existant, une invitation est envoyée avec un lien qui crée le compte et rejoint l'espace en une seule étape (comportement à la Slack).

---

## Vues

L'application est composée des vues suivantes :

- *L'Essentiel* *(AS administrateur / modérateur / garant / contributeur)*
- *Initiative* *(AS auteur / contributeur)*
- *Profil*
- *Gestion de l'espace* *(AS admin)*
- *Kanban* *(AS contributeur / modérateur / garant / administrateur)*

### L'Essentiel

L'Essentiel est une gazette intégrant cinq blocs :

- ℹ️ *Informations* — Une bannière d'informations et lectures importantes, épinglées par les administrateurs.
- 🆕 *Nouveautés* — Dernières initiatives publiées (depuis dernière connexion puis 15 derniers jours dans la limite de 10) : entrée d'actualité immédiate.
- ✅ *Succès* — Les initiatives en état `ADOPTED` et `EXECUTED`, mélangées, en ordre chronologique de passage à l'état final.
- 🕰️ *À trancher* — Les initiatives expirant prochainement.
- 🔥 *Tendances* — Bloc intelligent fusionnant tendances et suivies : les initiatives suivies à fort engagement sont prioritaires, puis les tendances globales de l'espace. Le score d'engagement est calculé selon une formule à définir (TODO) favorisant les initiatives récentes (pondération temporelle décroissante) et actives (nombre de positionnements, repositionnements et suggestions récents).

> Idéalement, plutôt que des blocs distincts, un format plus créatif mais épuré et fonctionnel est envisagé (exemple : sous forme de gazette, ou de tableau avec en-tête vertical et horizontal type kanban). Le tout doit être extrêmement simple d'utilisation, avec une complexité accessible cachée.

Boutons de navigation :

- Notifications : modale affichant un fil de notifications en side panel.
- Profil : saut vers vue.
- Espace dropdown : un bouton permettant de switcher d'un espace à un autre.
- Gestion de l'espace *(AS admin)* : saut vers vue dédiée.
- **Registre de décisions** : barre de recherche full-text accessible depuis la vue principale, portant sur toutes les initiatives en état `ADOPTED` ou `EXECUTED` de l'espace (titre, contenu, sujets, preuve de réalisation). Les résultats s'affichent en liste inline (pas de vue dédiée), triés par pertinence puis par date d'adoption décroissante. Chaque résultat affiche : titre, sujets, auteur, date d'adoption, statut (`ADOPTED` / `EXECUTED`), extrait contextuel. Un clic ouvre la vue Initiative correspondante. Les filtres (sujet, auteur, période, état) sont accessibles depuis la barre.
  La recherche repose sur l'index `tsvector` PostgreSQL (pondération : titre A, contenu B, sujets C, preuve D). L'alimentation est automatique dès qu'une initiative passe en état `ADOPTED` ou `EXECUTED`.
  > V2 : recherche sémantique assistée par IA (embeddings vectoriels via pgvector).

### Initiative

L'auteur crée et gère l'initiative, le contributeur se positionne.

#### Auteur

##### 1. Création

Interface de création d'initiative :

- Input : titre
- Text Area (idéalement éditeur de markdown) : contenu de la proposition. Insertion de table, de formule, de headers, gras, souligné, italique (et raccourcis hors table).
- ❓ Aide contextuelle

L'ébauche est privée jusqu'à publication explicite par l'auteur (voir *Lexique > Initiative > Ébauche*).

> Note : automatiquement à la création d'une initiative, l'auteur y est assigné, ainsi que les garants associés aux sujets sélectionnés.

> V2 : utiliser un outil de création de formulaire dynamique afin d'offrir une plus grande flexibilité.
> Exemple : sondages, où le positionnement n'est plus binaire mais repose sur des priorités à ordonner.

##### 2. Gestion *(AS auteur | administrateur | modérateur)*

- Bouton valider à côté d'une suggestion → amender l'initiative en intégrant la suggestion. Dès lors, l'initiative sauvegarde une métadonnée liant la zone amendée à la suggestion.
- Bouton assigner pour assigner un membre ou un sujet (et indirectement les garants associés).

#### Vue de participation *(AS contributeur | administrateur | modérateur)*

Layout :

- Rendu (pretty-md) de l'initiative.
- Groupe de boutons : soutenir / désapprouver / suggérer / clarifier. Au clic sur n'importe lequel, la zone de commentaire est activée et le bouton *'me positionner'* envoie les deux simultanément.
  L'auteur de l'initiative ne voit pas ces boutons de positionnement sur sa propre initiative. Il peut en revanche réagir aux éclairages du fil en se positionnant dessus (ENDORSE / OPPOSE), ce qui lui permet d'interagir avec la délibération sans se repositionner sur sa propre initiative.
- Le fil : la liste des soutiens / désapprobations et les positions associées, s'il y a.
  - Affichage chronologique mêlant évènements, éclairages, suggestions (qui citent directement le texte d'origine ainsi que la modification) et clarifications.
  - L'historique des repositionnements d'un utilisateur est groupé par `stance_group_id` et affiché dans l'ordre chronologique, le plus récent en premier, les anciens grisés.
  - Chaque membre positionné peut se repositionner et éditer son éclairage. Le nouveau positionnement apparaîtra dans le fil à la date d'édition. Le(s) précédent(s) apparaîtront toujours, grisé(s), dans le fil à la date initiale.
  - Les garants ayant participé apparaissent mêlés mais se distinguent visuellement par la présence d'un cadre coloré.
  - Il est possible de soutenir / désapprouver un éclairage (se positionner sur l'éclairage via `parent_stance_id`). Répondre à un éclairage = se positionner sur cet éclairage (ENDORSE / OPPOSE), accompagné d'un éclairage facultatif. Le commentaire cite l'éclairage initial et apparaît dans le fil principal. Cette action n'est pas récursive : il y a un unique niveau de thread. L'auteur de l'initiative peut également réagir aux éclairages de cette manière. (❓ Voire pas de thread du tout et tout reste dans le fil principal — à tester.)
  - Les suggestions peuvent être intégrées à l'initiative par un ayant droit. Ce mécanisme fonctionne comme la validation d'une suggestion dans une PR GitHub.
  > Inspiration : le fil de commentaires associés à une pull request GitHub.

### Kanban

Vue tableau de l'ensemble des initiatives de l'espace, organisées par état (colonnes : Ébauche, Arbitrage, Scelée, Adoption, Classée, Réalisée).

- Chaque carte affiche : titre, auteur, sujets associés, nombre de positionnements, date de dernière activité.
- **Recherche** : barre de recherche textuelle (titre, contenu) et filtres par état, sujet, auteur.
- Les ébauches ne sont visibles que par leur auteur (et les administrateurs / modérateurs selon les permissions) — voir *Lexique > Initiative > Ébauche*.
- Accessible depuis le bouton de navigation principal.

*(AS contributeur / modérateur / garant / administrateur)*

### Profil

L'utilisateur y gère ses informations et préférences personnelles :

- Son profil et ses informations personnelles (cf. data-membre)
- Ses préférences de notification (canaux, fréquence, dans les limites définies par chaque espace).
- Son thème.
- La liste des espaces dont il est membre (lecture seule, avec un lien vers la vue Gestion de l'espace pour les administrateurs).

### Gestion de l'espace *(AS admin)*

Vue accessible depuis le dashboard (bouton admin). Elle contient :

- Informations générales de l'espace : nom, description, visibilité (public / privé / sur invitation).
- Membres :
  - Tableau des membres avec colonnes : nom d'utilisateur, email, rôle (admin / modérateur / contributeur), statut (actif / invité en attente), actions (changer de rôle, retirer).
  - Bouton *"Inviter des membres"* : saisie d'une ou plusieurs adresses email. Si l'email est associé à un compte existant, l'utilisateur est ajouté à l'espace et notifié. Si l'email n'est pas connu, une invitation est envoyée par email avec un lien pour créer un compte et rejoindre l'espace directement (comportement à la Slack).
  - Les administrateurs peuvent toujours inviter des membres. Les modérateurs le peuvent si la règle *"Modérateurs peuvent inviter des membres"* est activée (voir matrice de permissions).
- Sujets :
  - Liste des sujets (tags) de l'espace.
  - Création / suppression de sujets. La suppression d'un sujet n'est pas possible si des initiatives ou des garants y sont associés ; l'interface doit le signaler explicitement.
  - Pour chaque sujet : liste des garants associés. Bouton pour associer / dissocier un garant (membre de l'espace).
- Règles : formulaire pour configurer la matrice de permissions (toutes les lignes du tableau de la matrice).
- Danger zone :
  > Suppression de l'espace : tout administrateur peut initier la suppression. Une fois initiée :
  > - Un délai de 60 jours est déclenché avant la suppression effective des données.
  > - Pendant ce délai, tout administrateur peut annuler la suppression.
  > - Tous les membres sont notifiés immédiatement.
  > - Il n'y a pas d'archivage : la suppression est définitive après le délai.

---

## Notifications

Les notifications sont délivrées sur trois canaux :
- 📱 Push (mobile / navigateur)
- 🔔 In-app (centre de notifications dans l'interface)
- 📧 Email

Les canaux activés et leur fréquence sont configurés par espace par les administrateurs (règle d'espace), et peuvent être affinés par utilisateur dans ses préférences de profil (dans les limites définies par l'espace).

Voici la liste des événements notifiés à l'utilisateur :

- Nouvelle initiative proposée
- Changement de règle au sein de l'espace
- Changement d'état définitif (adoptée / classée) d'une initiative
- Changement de rôle de tout utilisateur au sein de l'espace
- Ajout de l'utilisateur à un nouvel espace
- Initiative : délai restant 4h
- Initiative *suivie* :
  - Nouveau positionnement publié
  - Changement d'état de l'initiative
  - (Scelée, si absence de positionnement) Délai restant 6h ; 1h
  - (Scelée, si positionnement) Délai restant 4h

---

## Tutoriel

> v2

Ensemble de vues tutoriel, accessibles sur demande (bouton "Tutoriel" ou ❓ toujours accessible sur les pages concernées).

Parcours à définir, mais l'objectif est de présenter le lexique à l'utilisateur, ainsi que :

- Introduction au lexique : définir les mots-clés
- Vue d'ensemble du dashboard
- Création d'espace :
  - Matrice d'arbitrage
  - Matrice de permissions
  - Création des sujets et association de garants
- Création d'initiative
- Amendement d'une initiative
- Participation :
  - Soutenir / Désapprouver et apporter un éclairage
  - Suggérer un changement

---

# Licence

Ce projet est développé sous licence MIT ou Apache-2.
