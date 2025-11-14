# DiasporaRemit - Documentation Technique

## Vue d'ensemble

DiasporaRemit est un système d'escrow blockchain conçu pour sécuriser les transferts d'argent de la diaspora africaine vers leurs familles, en garantissant que les fonds sont utilisés pour leur objectif initial grâce à un système de validation par tiers de confiance.

## Architecture du Système

### Contrats Smart

#### 1. DiasporaRemitEscrow.sol (Contrat Principal)

**Adresse:** [À déployer sur Sepolia/Polygon]

**Fonctionnalités:**
- Création et gestion de transferts d'escrow conditionnels
- Système de validation par tiers de confiance
- Gestion automatique des remboursements
- Résolution de litiges
- Statistiques utilisateur et réputation

**Rôles:**
- **Sender (Expéditeur):** Membre de la diaspora qui envoie les fonds
- **Recipient (Bénéficiaire):** Personne qui reçoit les fonds au pays
- **Validator (Validateur):** Tiers de confiance qui vérifie que les conditions sont remplies

### Flux de Transaction Standard

```
1. Sender crée un transfert
   ↓
2. Sender finance le transfert (fonds verrouillés)
   ↓
3. Validator vérifie les conditions (ex: reçu de paiement universitaire)
   ↓
4. Validator approuve le transfert
   ↓
5. Recipient retire les fonds
   ↓
6. Statistiques mises à jour automatiquement
```

### États d'un Transfert

- **Created:** Transfert créé mais non financé
- **Funded:** Fonds déposés, en attente de validation
- **Validated:** Validé par le validateur, prêt pour retrait
- **Completed:** Fonds retirés par le bénéficiaire
- **Refunded:** Remboursé à l'expéditeur (deadline dépassée)
- **Disputed:** En litige, nécessite intervention admin

## Guide de Déploiement

### Prérequis

- Remix IDE (https://remix.ethereum.org)
- MetaMask installé
- Faucet Sepolia ETH (https://sepoliafaucet.com)

### Étapes de Déploiement

1. **Ouvrir Remix IDE**
   - Aller sur https://remix.ethereum.org

2. **Créer les fichiers**
   - Créer `DiasporaRemitEscrow.sol`
   - Copier le code du contrat

3. **Compiler**
   - Aller dans l'onglet "Solidity Compiler"
   - Sélectionner version 0.8.20
   - Cliquer "Compile DiasporaRemitEscrow.sol"

4. **Déployer**
   - Aller dans "Deploy & Run Transactions"
   - Environment: "Injected Provider - MetaMask"
   - Réseau MetaMask: Sepolia Test Network
   - Cliquer "Deploy"
   - Confirmer dans MetaMask

5. **Copier l'adresse du contrat**
   - Noter l'adresse du contrat déployé

## Guide de Test sur Remix

### Scénario 1: Transfert Réussi Complet

**Acteurs:**
- Sender: Account 1 (vous)
- Recipient: Account 2 (créer un deuxième compte)
- Validator: Account 3 (créer un troisième compte)

**Étapes:**

1. **Créer et financer un transfert**
   ```
   Fonction: createAndFundTransfer
   
   Paramètres:
   - _recipient: 0x... (adresse Account 2)
   - _validator: 0x... (adresse Account 3)
   - _purpose: "Frais de scolarité - Université de Kinshasa"
   - _deadlineSeconds: 2592000 (30 jours en secondes)
   
   Value: 1000000000000000000 (1 ETH)
   
   Cliquer "transact"
   ```

2. **Vérifier le statut**
   ```
   Fonction: getTransferStatus
   
   Paramètres:
   - _transferId: 0
   
   Résultat attendu:
   - status: 1 (Funded)
   - isFunded: true
   - isValidated: false
   - canRefund: false
   ```

3. **Valider le transfert (changer de compte vers Account 3)**
   ```
   Dans MetaMask, changer vers Account 3
   
   Fonction: validateTransfer
   
   Paramètres:
   - _transferId: 0
   - _note: "Inscription confirmée - Reçu #2025-001234"
   
   Cliquer "transact"
   ```

4. **Retirer les fonds (changer vers Account 2)**
   ```
   Dans MetaMask, changer vers Account 2
   
   Fonction: withdrawFunds
   
   Paramètres:
   - _transferId: 0
   
   Cliquer "transact"
   
   Vérifier le solde de Account 2 (devrait augmenter de ~0.99 ETH)
   ```

5. **Vérifier les statistiques**
   ```
   Fonction: getUserStats
   
   Paramètres:
   - _user: 0x... (adresse Account 1)
   
   Résultat:
   - totalTransfersSent: 1
   - totalAmountSent: 1 ETH
   - successRate: 100
   ```

### Scénario 2: Remboursement Automatique

**Note:** Ce scénario nécessite d'attendre la deadline ou de la modifier pour tester rapidement.

**Étapes:**

1. **Créer un transfert avec deadline courte**
   ```
   Fonction: createAndFundTransfer
   
   Paramètres:
   - _recipient: 0x...
   - _validator: 0x...
   - _purpose: "Test remboursement"
   - _deadlineSeconds: 60 (1 minute pour test)
   
   Value: 0.5 ETH
   ```

2. **Attendre 1 minute**

3. **Demander remboursement**
   ```
   Fonction: refundTransfer
   
   Paramètres:
   - _transferId: 1
   
   Résultat: Fonds retournés à l'expéditeur
   ```

### Scénario 3: Gestion de Litige

**Étapes:**

1. **Créer et financer un transfert**
   ```
   (Suivre étape 1 du Scénario 1)
   ```

2. **Lever un litige**
   ```
   Fonction: raiseDispute
   
   Paramètres:
   - _transferId: 0
   - _reason: "Bénéficiaire n'a pas utilisé pour objectif initial"
   
   Status devient: Disputed
   ```

3. **Résoudre le litige (en tant que owner)**
   ```
   Fonction: resolveDispute
   
   Paramètres:
   - _transferId: 0
   - _percentageToRecipient: 50
   
   Résultat: 50% au recipient, 50% au sender
   ```

## Fonctions Principales

### Fonctions d'Écriture

#### createTransfer
Crée un nouveau transfert (sans financement immédiat).

**Paramètres:**
- `_recipient`: Adresse du bénéficiaire
- `_validator`: Adresse du validateur
- `_purpose`: Description de l'objectif du transfert
- `_deadlineSeconds`: Durée avant expiration (minimum 1 jour)

**Returns:** `transferId`

#### fundTransfer
Finance un transfert existant.

**Paramètres:**
- `_transferId`: ID du transfert

**Payable:** Montant à envoyer

#### createAndFundTransfer
Crée et finance en une seule transaction.

**Paramètres:**
- `_recipient`: Adresse du bénéficiaire
- `_validator`: Adresse du validateur
- `_purpose`: Description de l'objectif
- `_deadlineSeconds`: Durée avant expiration

**Payable:** Montant à envoyer

**Returns:** `transferId`

#### validateTransfer
Valide qu'un transfert remplit les conditions.

**Paramètres:**
- `_transferId`: ID du transfert
- `_note`: Note de validation (preuve)

**Require:** Doit être appelé par le validateur

#### withdrawFunds
Retire les fonds après validation.

**Paramètres:**
- `_transferId`: ID du transfert

**Require:** Doit être appelé par le bénéficiaire

#### refundTransfer
Rembourse l'expéditeur si deadline dépassée.

**Paramètres:**
- `_transferId`: ID du transfert

**Require:** Deadline dépassée, pas encore validé

#### raiseDispute
Lève un litige sur un transfert.

**Paramètres:**
- `_transferId`: ID du transfert
- `_reason`: Raison du litige

#### resolveDispute
Résout un litige (admin seulement).

**Paramètres:**
- `_transferId`: ID du transfert
- `_percentageToRecipient`: Pourcentage pour le bénéficiaire (0-100)

### Fonctions de Configuration

#### updateRecipient
Change le bénéficiaire (avant financement).

#### updateValidator
Change le validateur (avant validation).

#### extendDeadline
Prolonge la deadline.

### Fonctions de Vue

#### getTransfer
Retourne les détails complets d'un transfert.

#### getTransferStatus
Retourne le statut détaillé d'un transfert.

#### getUserStats
Retourne les statistiques d'un utilisateur.

#### getSenderTransfers
Liste tous les transferts d'un expéditeur.

#### getRecipientTransfers
Liste tous les transferts d'un bénéficiaire.

#### getValidatorTransfers
Liste tous les transferts d'un validateur.

#### getPlatformStats
Statistiques globales de la plateforme.

## Événements

### TransferCreated
Émis lors de la création d'un transfert.

### TransferFunded
Émis lorsque des fonds sont déposés.

### TransferValidated
Émis lors de la validation.

### TransferCompleted
Émis lors du retrait des fonds.

### TransferRefunded
Émis lors d'un remboursement.

### TransferDisputed
Émis lors de la levée d'un litige.

### DisputeResolved
Émis lors de la résolution d'un litige.

## Sécurité

### Protection Reentrancy
Utilisation d'un guard pour empêcher les attaques de réentrance.

### Erreurs Personnalisées
Utilisation d'erreurs custom pour économiser du gas et améliorer la clarté.

### Access Control
Modificateurs stricts pour garantir que seules les parties autorisées peuvent appeler certaines fonctions.

### State Machine
Transitions d'état strictement contrôlées.

### Audits Recommandés
- Trail of Bits
- OpenZeppelin
- CertiK

## Gas Optimization

- Utilisation de `uint256` au lieu de types plus petits
- Erreurs custom au lieu de `require` avec messages
- Storage vs Memory approprié
- Events au lieu de logs complexes

## Considérations Futures

### Intégration Mobile Money
- Support M-Pesa, Orange Money
- Conversion automatique crypto ↔ fiat

### Multi-signature
- Validation par plusieurs validateurs pour montants élevés

### Paiements Fractionnés
- Libération progressive basée sur milestones

### Gouvernance DAO
- Décisions communautaires
- Token $REMIT

### Cross-chain
- Support Polygon, Arbitrum, Optimism
- Bridge entre chains

## Support et Contact

**Email:** dev@diasporaremit.io  
**Documentation:** https://docs.diasporaremit.io  
**GitHub:** https://github.com/diasporaremit  
**Discord:** https://discord.gg/diasporaremit

## License

MIT License - Voir fichier LICENSE

---

**Dernière mise à jour:** Novembre 2025  
**Version:** 1.0.0
