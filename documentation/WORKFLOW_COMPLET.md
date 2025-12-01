# 🔄 WORKFLOW COMPLET - DiasporaRemit sur Sepolia

## 📌 ADRESSES DES CONTRATS DÉPLOYÉS

```
SEPOLIA TESTNET - DÉPLOIEMENT DiasporaRemit
================================================
DiasporaUserRegistry:       0xBAF6D6d666D8B750a1e6aCe54c7C4d58a4e28aaf
DiasporaValidatorRegistry:  0xBAF6D6d666D8B750a1e6aCe54c7C4d58a4e28aaf
DiasporaRemitEscrow:        0x61Ce4c7e227dC87D8154549902A07db5C0F9608e

COMPTES TEST
================================================
Ronny (Expéditeur):   0x6220751aC9897D6508c07a9bd571a9a246756a4C
Grâce (Bénéficiaire): 0xa9F1Dd55BB791F55d5E7241fC56f650952433d9d
UNIKIN (Validateur):  0x6220751aC9897D6508c07a9bd571a9a246756a4C
```

---

## ✅ ÉTAPES DÉJÀ COMPLÉTÉES

- [x] 3 contrats compilés et déployés sur Sepolia
- [x] Ronny enregistré comme utilisateur
- [x] UNIKIN enregistré et certifié comme validateur
- [ ] Contrats connectés entre eux (setUserRegistry, setValidatorRegistry, setMainContract)
- [ ] **Transfert à créer**
- [ ] **Validation par UNIKIN**
- [ ] **Retrait des fonds par Grâce**

---

## 📋 WORKFLOW COMPLET DÉTAILLÉ (TOUTES LES ÉTAPES REMIX)

### PHASE 0 : PRÉPARATION DE L'ENVIRONNEMENT

#### 0.1 Installer MetaMask

1. **Aller sur** : https://metamask.io
2. **Cliquer** sur "Download" → Choisir votre navigateur (Chrome, Firefox, Brave, Edge)
3. **Installer l'extension** et suivre les instructions
4. **Créer un nouveau wallet** ou importer un existant
5. **Sauvegarder la phrase de récupération** (12 mots) dans un endroit sûr

#### 0.2 Créer les 3 comptes de test

1. **Ouvrir MetaMask** (cliquer sur l'icône du renard dans le navigateur)
2. **Cliquer** sur l'icône du compte (cercle coloré en haut à droite)
3. **Sélectionner** "Add account or hardware wallet"
4. **Choisir** "Add a new Ethereum account"
5. **Renommer le compte** :
   - Cliquer sur les 3 points → "Account details" → Éditer le nom
   - **Compte 1** : `Ronny (Sender)`
   - **Compte 2** : `Grace (Recipient)` (créer un 2ème compte)
   - **Compte 3** : `UNIKIN (Validator)` (créer un 3ème compte)

#### 0.3 Configurer le réseau Sepolia

1. **Dans MetaMask**, cliquer sur le sélecteur de réseau (en haut à gauche)
2. **Cliquer** sur "Show test networks" (si vous ne voyez pas Sepolia)
3. **Aller dans** : Paramètres (icône engrenage) → Advanced
4. **Activer** "Show test networks" (toggle à ON)
5. **Revenir** au sélecteur de réseau
6. **Sélectionner** "Sepolia test network"
7. **Vérifier** : Le réseau affiché doit être "Sepolia"

#### 0.4 Obtenir de l'ETH Sepolia (testnet)

**Pour le compte Ronny** (il déploiera les contrats et créera le transfert) :

1. **Sélectionner** le compte Ronny dans MetaMask
2. **Copier l'adresse** (cliquer sur le nom du compte)
3. **Aller sur un faucet Sepolia** :
   - **Google Cloud** : https://cloud.google.com/application/web3/faucet/ethereum/sepolia
   - **Alchemy** : https://www.alchemy.com/faucets/ethereum-sepolia
   - **Chainlink** : https://faucets.chain.link/sepolia
4. **Coller votre adresse** Ronny
5. **Demander 0.5 ETH** (ou le maximum disponible)
6. **Attendre** 1-2 minutes → Vérifier dans MetaMask

**Pour le compte UNIKIN** (validera les transferts) :

1. **Changer vers** le compte UNIKIN dans MetaMask
2. **Répéter** les étapes 2-6 ci-dessus
3. **Obtenir** au moins 0.1 ETH Sepolia

**Pour le compte Grâce** (retirera les fonds) :

1. **Changer vers** le compte Grâce dans MetaMask
2. **Répéter** les étapes 2-6 ci-dessus
3. **Obtenir** au moins 0.05 ETH Sepolia (pour les frais de gas du retrait)

#### 0.5 Ouvrir Remix et connecter MetaMask

1. **Ouvrir Remix** : https://remix.ethereum.org
2. **Créer un nouveau workspace** (optionnel) ou utiliser le workspace par défaut
3. **Importer vos fichiers Solidity** :
   - Clic droit sur "contracts" → "New File"
   - Créer `DiasporaUserRegistry.sol`
   - Créer `DiasporaValidatorRegistry.sol`
   - Créer `DiasporaRemitEscrow.sol`
   - **Coller le code** de chaque contrat

4. **Aller dans** "Deploy & Run Transactions" (icône Ethereum à gauche)
5. **ENVIRONMENT** : Sélectionner `Injected Provider - MetaMask`
6. **Une popup MetaMask apparaît** :
   - "Remix wants to connect to your wallet"
   - **Sélectionner** le(s) compte(s) à connecter (Ronny)
   - **Cliquer** "Next" puis "Connect"
7. **Vérifier** :
   - En haut de Remix, doit afficher : `Injected Provider - MetaMask`
   - En dessous : `Sepolia (11155111) network`
   - **ACCOUNT** : Doit montrer l'adresse de Ronny

**⚠️ IMPORTANT** : Si Remix affiche "Remix VM" au lieu de "Sepolia" :
- Cliquer sur le sélecteur ENVIRONMENT
- Re-sélectionner "Injected Provider - MetaMask"
- Vérifier que MetaMask est sur Sepolia
- Rafraîchir Remix (F5) si nécessaire

---

### PHASE 1 : DÉPLOIEMENT DES CONTRATS

#### 1.1 Compiler les contrats

1. Dans Remix, onglet **"Solidity Compiler"**
2. Sélectionner **Solidity 0.8.20**
3. Compiler : `DiasporaUserRegistry.sol`
4. Compiler : `DiasporaValidatorRegistry.sol`
5. Compiler : `DiasporaRemitEscrow.sol`

#### 1.2 Déployer DiasporaUserRegistry

1. Onglet **"Deploy & Run Transactions"**
2. **ENVIRONMENT** : `Injected Provider - MetaMask` (Sepolia)
3. **ACCOUNT** : Ronny (0x6220751aC...)
4. **CONTRACT** : `DiasporaUserRegistry`
5. **Deploy** → Confirmer dans MetaMask
6. **Noter l'adresse déployée**

#### 1.3 Déployer DiasporaValidatorRegistry

1. **CONTRACT** : `DiasporaValidatorRegistry`
2. **Deploy** → Confirmer dans MetaMask
3. **Noter l'adresse** : `0x831a24D733F1Ea754cC4554c6fb37A733A1Faaf7`

#### 1.4 Déployer DiasporaRemitEscrow

1. **CONTRACT** : `DiasporaRemitEscrow`
2. **Deploy** → Confirmer dans MetaMask
3. **Noter l'adresse** : `0x09963A973481F13c49eBCeF833Cf298e8EDf887C`

---

### PHASE 2 : CONNEXION DES CONTRATS

#### 2.1 Connecter DiasporaRemitEscrow aux registres

Dans le contrat **DiasporaRemitEscrow** déployé :

1. **setUserRegistry**
   - Paramètre : `[Adresse de votre DiasporaUserRegistry déployé]`
   - Transact → Confirmer

2. **setValidatorRegistry**
   - Paramètre : `[Adresse de votre DiasporaValidatorRegistry déployé]`
   - Transact → Confirmer

#### 2.2 Connecter le UserRegistry au contrat principal

Dans **DiasporaUserRegistry** :
- **setMainContract**
  - Paramètre : `[Adresse de votre DiasporaRemitEscrow déployé]`
  - Transact → Confirmer

**⚠️ IMPORTANT** : 
- DiasporaValidatorRegistry **n'a pas** de fonction `setMainContract`
- La fonction `recordValidation()` peut être appelée par n'importe quelle adresse
- Aucune configuration supplémentaire n'est nécessaire pour le ValidatorRegistry

---

### PHASE 3 : ENREGISTREMENT DES UTILISATEURS

#### 3.1 Ronny s'enregistre comme utilisateur

1. **MetaMask** : Compte Ronny actif
2. **CONTRACT** : DiasporaUserRegistry
3. **Fonction** : `registerUser`
4. **Paramètres** :
   ```
   _name: Ronny Kabongo
   _country: Germany
   ```
5. **Transact** → Confirmer

#### 3.2 UNIKIN s'enregistre comme validateur

1. **MetaMask** : **Changer vers compte UNIKIN** (0xb5d1ecb769...)
2. **CONTRACT** : DiasporaValidatorRegistry
3. **Fonction** : `registerValidator`
4. **Paramètres** :
   ```
   _organizationName: UNIKIN
   _country: RDC
   _licenseNumber: UNIKIN-2025
   ```
5. **Transact** → Confirmer

#### 3.3 Ronny certifie UNIKIN

1. **MetaMask** : **Revenir au compte Ronny** (owner)
2. **CONTRACT** : DiasporaValidatorRegistry
3. **Fonction** : `certifyValidator`
4. **Paramètre** :
   ```
   _validator: 0xb5d1ecb769d119b0129e5031afb27ff625e75113
   ```
5. **Transact** → Confirmer

---

## 🚀 SUITE DU WORKFLOW - EXÉCUTION DU TRANSFERT

### ÉTAPE 1 : VÉRIFIER LE TRANSFERT CRÉÉ

#### 1.1 Recharger le contrat dans Remix (si Remix a planté)

1. **Ouvrir Remix** : https://remix.ethereum.org
2. **Aller dans "Deploy & Run Transactions"**
3. **ENVIRONMENT** : Sélectionner `Injected Provider - MetaMask`
4. **Vérifier** : Doit afficher `Sepolia (11155111) network`
5. **CONTRACT** : Sélectionner `DiasporaRemitEscrow`
6. **At Address** : Coller `0x09963A973481F13c49eBCeF833Cf298e8EDf887C`
7. **Cliquer** sur le bouton orange **At Address**

#### 1.2 Vérifier que le transfert existe

Dans "Deployed Contracts", développer **DIASPORAREMITESCROW AT 0x09963...887C** :

1. Trouver le bouton bleu **`totalTransfers`**
2. Cliquer dessus
3. **Résultat attendu** : `1` (ou plus si vous avez créé plusieurs transferts)

#### 1.3 Obtenir les détails du transfert

1. Trouver le bouton bleu **`getTransfer`**
2. Dans le champ à côté, entrer : `0` (ID du premier transfert)
3. Cliquer sur **getTransfer**
4. **Résultat attendu** :
   ```
   sender: 0x80eda673bcd9daa173c3a88206377515517c7ea0
   recipient: 0xe9184d1618a106174a38062c428bfe186a4a6610
   validator: 0xb5d1ecb769d119b0129e5031afb27ff625e75113
   amount: 5000000000000000 (0.005 ETH en Wei)
   status: 1 (Funded)
   purpose: "Frais scolaires Grâce - UNIKIN"
   ```

---

### ÉTAPE 2 : UNIKIN VALIDE LE TRANSFERT

#### 2.1 Changer de compte vers UNIKIN

1. **Ouvrir MetaMask**
2. **Cliquer sur l'icône du compte** (en haut)
3. **Sélectionner** : Compte UNIKIN (0xb5d1ecb769d119b0129e5031afb27ff625e75113)
4. **Vérifier** que le réseau est toujours **Sepolia**

#### 2.2 Valider le transfert

Dans Remix, contrat **DiasporaRemitEscrow** :

1. Trouver la fonction **`validateTransfer`** (bouton orange)
2. Remplir les paramètres :
   ```
   _transferId: 0
   _note: Documents vérifiés - Grâce Kabongo inscrite à UNIKIN
   ```
3. **Cliquer** sur **transact** (bouton orange)
4. **MetaMask s'ouvre** → Vérifier les détails → **Confirmer**
5. **Attendre la confirmation** (~15 secondes)
6. **Résultat** : Message de succès dans Remix

#### 2.3 Vérifier que la validation a réussi

1. Cliquer sur **getTransfer** avec `_transferId: 0`
2. **Vérifier** :
   ```
   status: 2 (Validated) ✅
   validationNote: "Documents vérifiés - Grâce Kabongo inscrite à UNIKIN"
   ```

---

### ÉTAPE 3 : GRÂCE RETIRE LES FONDS

**⚠️ CRITIQUE** : Avant de retirer, vérifiez l'adresse du recipient dans le transfert !

#### 3.0 Vérifier le recipient du transfert

1. Dans **DiasporaRemitEscrow**, cliquer sur `getTransfer`
2. Entrer `_transferId: 0`
3. **Noter l'adresse `recipient`** affichée
4. **C'est CETTE adresse exacte** qui doit appeler `withdrawFunds`

#### 3.1 Changer de compte vers Grâce

1. **Ouvrir MetaMask**
2. **Sélectionner** : Le compte dont l'adresse correspond **exactement** au `recipient`
3. **Vérifier** que le réseau est **Sepolia**
4. **Vérifier dans Remix** : L'adresse affichée dans ACCOUNT doit être identique au `recipient`

#### 3.2 Retirer les fonds

Dans Remix, contrat **DiasporaRemitEscrow** :

1. Trouver la fonction **`withdrawFunds`** (bouton orange)
2. Remplir le paramètre :
   ```
   _transferId: 0
   ```
3. **Cliquer** sur **transact**
4. **MetaMask s'ouvre** → **Confirmer**
5. **Attendre la confirmation** (~15 secondes)
6. **Résultat** : Grâce reçoit **0.00495 ETH** (0.005 - 1% frais = 0.00495)

#### 3.3 Vérifier le solde de Grâce

1. **Dans MetaMask** (compte Grâce)
2. **Vérifier** : Le solde a augmenté de ~0.00495 ETH

#### 3.4 Vérifier que le transfert est complété

1. Cliquer sur **getTransfer** avec `_transferId: 0`
2. **Vérifier** :
   ```
   status: 3 (Completed) ✅
   releasedAt: [timestamp récent]
   ```

---

### ÉTAPE 4 : VÉRIFIER LES STATISTIQUES FINALES

#### 4.1 Statistiques de la plateforme

Dans **DiasporaRemitEscrow** :

1. Cliquer sur le bouton bleu **`getPlatformStats`**
2. **Résultat attendu** :
   ```
   _totalTransfers: 1
   _totalValueLocked: 0 (tout a été retiré)
   _platformFeePercentage: 1
   ```

#### 4.2 Vérifier le profil de UNIKIN (validateur)

##### 4.2.1 Charger DiasporaValidatorRegistry

1. **CONTRACT** : Sélectionner `DiasporaValidatorRegistry`
2. **At Address** : Coller `0x831a24D733F1Ea754cC4554c6fb37A733A1Faaf7`
3. **Cliquer** sur **At Address**

##### 4.2.2 Consulter le profil

1. Trouver **`getValidatorProfile`** (bouton bleu)
2. Paramètre :
   ```
   _validator: 0xb5d1ecb769d119b0129e5031afb27ff625e75113
   ```
3. **Cliquer** et vérifier :
   ```
   totalValidations: 1 ✅
   successfulValidations: 1
   isCertified: true
   reputationScore: 100
   ```

#### 4.3 Vérifier le profil de Ronny (expéditeur)

##### 4.3.1 Charger DiasporaUserRegistry

1. **CONTRACT** : Sélectionner `DiasporaUserRegistry`
2. **At Address** : Coller `0x3ed93312222ecc25A5BD539d93B29b34a9ceb5f2`
3. **Cliquer** sur **At Address**

##### 4.3.2 Consulter le profil

1. Trouver **`getUserProfile`** (bouton bleu)
2. Paramètre :
   ```
   _user: 0x80eda673bcd9daa173c3a88206377515517c7ea0
   ```
3. **Cliquer** et vérifier :
   ```
   name: "Ronny Kabongo"
   country: "Germany"
   isRegistered: true
   reputationScore: 100 (mis à jour après le transfert réussi)
   ```

---

### ÉTAPE 5 : VÉRIFICATION SUR SEPOLIA ETHERSCAN

#### 5.1 Vérifier le contrat DiasporaRemitEscrow

1. **Ouvrir** : https://sepolia.etherscan.io
2. **Rechercher** : `0x09963A973481F13c49eBCeF833Cf298e8EDf887C`
3. **Vérifier** :
   - **Balance** : Devrait être ~0 ETH (tout a été retiré)
   - **Transactions** : Voir toutes les transactions (création, validation, retrait)

#### 5.2 Vérifier la transaction de retrait

1. Dans Etherscan, cliquer sur l'onglet **"Transactions"**
2. **Trouver** : La transaction de `withdrawFunds` (la plus récente)
3. **Vérifier** :
   - **Status** : Success ✅
   - **To** : DiasporaRemitEscrow (0x09963...)
   - **Value** : 0 ETH (fonction, pas dépôt)
   - **Internal Txns** : 0.00495 ETH transféré à Grâce

---

## 🔄 WORKFLOW POUR UN DEUXIÈME TRANSFERT (OPTIONNEL)

### Créer un nouveau transfert

1. **Revenir au compte Ronny** dans MetaMask
2. Dans **DiasporaRemitEscrow**, fonction `createAndFundTransfer`
3. **⚠️ IMPORTANT** : Vérifiez bien l'adresse du recipient (Grâce) avant de créer le transfert !
4. Paramètres (exemple) :
   ```
   _recipient: [Adresse exacte du compte Grâce dans MetaMask]
   _validator: [Adresse du validateur UNIKIN]
   _purpose: Aide médicale urgente
   _deadlineSeconds: 259200 (3 jours)
   ```
5. **VALUE** : `0.002` Ether
6. **Transact** → Confirmer dans MetaMask
7. **Vérifier immédiatement** avec `getTransfer` que le recipient est correct !

Puis répéter les étapes de validation et retrait avec `_transferId: 1`.

---

## 📊 RÉSUMÉ DU FLUX COMPLET

```
1. CRÉATION DU TRANSFERT (Ronny)
   └─> createAndFundTransfer()
       └─> Statut: Funded
       └─> Fonds verrouillés dans l'escrow

2. VALIDATION (UNIKIN)
   └─> validateTransfer(0, "note")
       └─> Statut: Validated
       └─> Réputation UNIKIN +1

3. RETRAIT (Grâce)
   └─> withdrawFunds(0)
       └─> Statut: Completed
       └─> Grâce reçoit 99% des fonds
       └─> Plateforme reçoit 1% de frais
       └─> Réputation Ronny mise à jour
```

---

## 🎯 CHECKLIST COMPLÈTE

- [x] Transfert créé et financé (status: Funded) ✅
- [x] UNIKIN a validé le transfert (status: Validated) ✅
- [x] Grâce a retiré les fonds (status: Completed) ✅
- [x] totalTransfers = 1 ✅
- [x] totalValueLocked = 0 ✅
- [x] UNIKIN totalValidations = 1 ✅
- [x] Ronny reputationScore = 100 ✅
- [x] Vérifié sur Sepolia Etherscan ✅

## 🎉 PROJET COMPLÉTÉ AVEC SUCCÈS !

**Transaction de validation** : https://sepolia.etherscan.io/tx/0xe7255564b3bee4c480df5fa34df739eca215f93aab72c9657b10f7d43d7385e0

**Transfer ID 0** :
- Créé : 9 novembre 2025 (timestamp: 1762763532)
- Validé : Par UNIKIN avec note "Documents vérifiés - Grâce Kabongo inscrite à UNIKIN"
- Complété : 10 novembre 2025 (timestamp: 1762785060)
- Montant : 0.005 ETH
- Reçu par Grâce : 0.00495 ETH (99%)
- Frais plateforme : 0.00005 ETH (1%)

---

## ❓ DÉPANNAGE

### Si Remix plante à nouveau

1. **Rafraîchir la page** : F5 ou Ctrl+R
2. **Recharger les contrats** : Utiliser "At Address" avec les adresses ci-dessus
3. **Les données sont sur la blockchain** : Rien n'est perdu, juste recharger l'interface

### Si une transaction échoue

1. **Vérifier le compte** : Êtes-vous sur le bon compte MetaMask ?
2. **Vérifier le statut** : Le transfert est-il dans le bon état ?
3. **Vérifier le gas** : Avez-vous assez d'ETH Sepolia ?
4. **Regarder l'erreur** : Remix affiche le message d'erreur du smart contract

**Erreurs courantes** :
- `Only owner` : Vous devez être connecté avec le compte propriétaire (Ronny)
- `NotRecipient` (0x8e4a23d6) : Vous essayez de retirer avec le mauvais compte
- `InvalidStatus` : Le transfert n'est pas dans le bon état (Funded → Validated → Completed)
- `DeadlinePassed` : Le délai est expiré, utilisez `refundTransfer` à la place

### Si vous n'avez plus assez d'ETH Sepolia

1. **Faucet Google Cloud** : https://cloud.google.com/application/web3/faucet/ethereum/sepolia
2. **Ou faucet Alchemy** : https://www.alchemy.com/faucets/ethereum-sepolia
3. Entrer votre adresse Ronny : `0x80eda673bcd9daa173c3a88206377515517c7ea0`

---

## 🎓 POINTS CLÉS POUR VOTRE PRÉSENTATION

### Architecture Modulaire

> "J'ai utilisé une architecture à 3 contrats pour rester sous la limite de 24KB par contrat imposée par Ethereum, tout en permettant une évolutivité future."

### Flux de Confiance

> "Le système implémente un flux de confiance à 3 acteurs : l'expéditeur finance, le validateur certifié vérifie, et le bénéficiaire retire les fonds. Chaque action est enregistrée sur la blockchain."

### Gestion de la Réputation

> "Le système met automatiquement à jour la réputation des utilisateurs et validateurs après chaque transfert réussi, créant un système de confiance décentralisé."

### Sécurité

> "J'ai implémenté plusieurs protections : ReentrancyGuard, custom errors pour économiser le gas, validations strictes, et un système de deadline pour les remboursements automatiques."

---

## 📸 CAPTURES D'ÉCRAN RECOMMANDÉES

1. **Remix** : Contrat déployé avec toutes les fonctions visibles
2. **MetaMask** : Confirmation de transaction
3. **Etherscan** : Transaction de transfert réussie
4. **getTransfer()** : Détails complets d'un transfert complété
5. **getPlatformStats()** : Statistiques de la plateforme

---

🎉 **FÉLICITATIONS ! Votre système DiasporaRemit est pleinement opérationnel sur Sepolia !**
