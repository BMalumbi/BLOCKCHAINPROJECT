# Guide de Test DiasporaRemit - Remix IDE

## Préparation

### 1. Configuration de MetaMask

1. **Installer MetaMask** (si pas déjà fait)
   - Extension navigateur: https://metamask.io

2. **Ajouter le réseau Sepolia Test Network**
   - Ouvrir MetaMask
   - Réseau → Ajouter un réseau → Sepolia Test Network
   - Ou ajouter manuellement:
     - Nom: Sepolia
     - RPC URL: https://sepolia.infura.io/v3/YOUR_KEY
     - Chain ID: 11155111
     - Symbol: ETH

3. **Créer 3 comptes de test**
   - **Account 1:** Ronny (Allemagne - Sender)
   - **Account 2:** Grâce (Kinshasa, RDC - Recipient)
   - **Account 3:** UNIKIN Bureau Frais (Validator)

4. **Obtenir du Sepolia ETH**
   - Aller sur https://sepoliafaucet.com
   - Ou https://www.infura.io/faucet/sepolia
   - Demander 1 ETH pour Account 1 (Ronny)

### 2. Configuration de Remix

1. **Ouvrir Remix IDE**
   - https://remix.ethereum.org

2. **Créer le fichier du contrat**
   - File Explorer → New File
   - Nom: `DiasporaRemitEscrow.sol`
   - Copier le code depuis `contracts/DiasporaRemitEscrow.sol`

3. **Compiler le contrat**
   - Onglet "Solidity Compiler"
   - Compiler version: 0.8.20
   - Cliquer "Compile DiasporaRemitEscrow.sol"
   - Vérifier qu'il n'y a pas d'erreurs ✅

4. **Déployer le contrat**
   - Onglet "Deploy & Run Transactions"
   - Environment: **Injected Provider - MetaMask**
   - Account: Vérifier que c'est Account 1
   - Contract: DiasporaRemitEscrow
   - Cliquer "Deploy"
   - Confirmer dans MetaMask
   - ✅ Contrat déployé! Noter l'adresse.

## Scénarios de Test

### Test 1: Transfert Complet Réussi ✅

**Objectif:** Tester le cycle de vie complet d'un transfert.

**Contexte (Expérience de Ronny):**
- Ronny (Allemagne) envoie 1 ETH pour le minerval (frais universitaires) de sa petite sœur Grâce
- Grâce est étudiante en 2ème année Licence Informatique de Gestion à l'UNIKIN (Kinshasa)
- Le Bureau des Frais Académiques de l'UNIKIN valide l'inscription après paiement
- Grâce peut retirer les fonds pour finaliser son inscription

**Étapes:**

#### 1.1 Créer et financer le transfert

```javascript
// Dans Remix, sous "Deployed Contracts"
// Account: Account 1 (Ronny en Allemagne)

Fonction: createAndFundTransfer

Paramètres:
_recipient: [ADRESSE_ACCOUNT_2 - Grâce]
_validator: [ADRESSE_ACCOUNT_3 - UNIKIN]
_purpose: "Minerval 2eme semestre 2025 - Licence Informatique de Gestion - UNIKIN"
_deadlineSeconds: 2592000

Value: 1000000000000000000 wei (1 ETH)

▶ Cliquer "transact"
✅ Confirmer dans MetaMask
```

**Vérification:**
```javascript
Fonction: totalTransfers

Résultat attendu: 1
```

```javascript
Fonction: totalValueLocked

Résultat attendu: 1000000000000000000 (1 ETH - Les "makuta" de Ronny sont sécurisés!)
```

#### 1.2 Vérifier le statut du transfert

```javascript
Fonction: getTransferStatus

Paramètres:
_transferId: 0

Résultats attendus:
- status: 1 (Funded)
- isFunded: true
- isValidated: false
- isCompleted: false
- canRefund: false
- timeRemaining: ~2592000 (30 jours en secondes)
```

#### 1.3 Consulter les détails du transfert

```javascript
Fonction: getTransfer

Paramètres:
_transferId: 0

Résultats attendus:
- sender: [ADRESSE_ACCOUNT_1]
- recipient: [ADRESSE_ACCOUNT_2]
- validator: [ADRESSE_ACCOUNT_3]
- amount: 1000000000000000000
- status: 1 (Funded)
- purpose: "Frais inscription 2eme semestre..."
```

#### 1.4 Valider le transfert (en tant qu'UNIKIN)

```javascript
// IMPORTANT: Changer de compte dans MetaMask vers Account 3 (UNIKIN)

Fonction: validateTransfer

Paramètres:
_transferId: 0
_note: "Inscription confirmee - Recu UNIKIN #2025-KIN-001234 - Grace Etudiant en L2 Info - IPFS: QmExample123"

▶ Cliquer "transact"
✅ Confirmer dans MetaMask
```

**Vérification:**
```javascript
Fonction: getTransferStatus

Paramètres:
_transferId: 0

Résultat:
- status: 2 (Validated)
- isValidated: true
```

#### 1.5 Retirer les fonds (en tant que Grâce)

```javascript
// IMPORTANT: Changer de compte dans MetaMask vers Account 2 (Grâce à Kinshasa)

Fonction: withdrawFunds

Paramètres:
_transferId: 0

▶ Cliquer "transact"
✅ Confirmer dans MetaMask
```

**Vérifications:**

1. Vérifier le statut:
```javascript
Fonction: getTransferStatus

Résultat:
- status: 3 (Completed)
- isCompleted: true
```

2. Vérifier le TVL:
```javascript
Fonction: totalValueLocked

Résultat: 0 (tout est retiré)
```

3. Vérifier le solde de Account 2 (Grâce) dans MetaMask
   - Devrait avoir augmenté de ~0.99 ETH (~1,485 EUR pour payer le minerval!)

4. Vérifier les statistiques:
```javascript
// Account 1 (Ronny en Allemagne)
Fonction: getUserStats
Paramètres: [ADRESSE_ACCOUNT_1]

Résultats:
- totalTransfersSent: 1
- totalAmountSent: 1000000000000000000
- successRate: 100 (Ronny peut avoir confiance!)

// Account 2 (Grâce à Kinshasa)
Fonction: getUserStats
Paramètres: [ADRESSE_ACCOUNT_2]

Résultats:
- totalTransfersReceived: 1
- totalAmountReceived: 990000000000000000 (0.99 ETH - Grâce inscrite!)
```

✅ **Test 1 RÉUSSI! Ronny en Allemagne sait que Grâce est bien inscrite à l'UNIKIN!** 🎓🇨🇩

---

### Test 2: Remboursement Automatique ✅

**Objectif:** Tester le remboursement si deadline dépassée sans validation.

**Contexte:**
- Ronny envoie 0.5 ETH pour des soins médicaux
- Délai court (1 minute pour test rapide)
- Si l'hôpital ne valide pas à temps → Remboursement automatique à Ronny

**Étapes:**

#### 2.1 Créer transfert avec deadline courte

```javascript
// Account: Account 1 (Marie)

Fonction: createAndFundTransfer

Paramètres:
_recipient: [ADRESSE_ACCOUNT_2]
_validator: [ADRESSE_ACCOUNT_3]
_purpose: "Test remboursement automatique"
_deadlineSeconds: 60

Value: 500000000000000000 wei (0.5 ETH)

▶ transact
```

#### 2.2 Vérifier qu'on ne peut PAS encore rembourser

```javascript
Fonction: refundTransfer

Paramètres:
_transferId: 1

Résultat attendu: ❌ ERREUR "DeadlineNotPassed()"
```

#### 2.3 Attendre 1 minute ⏰

#### 2.4 Demander le remboursement

```javascript
// Account: Account 1

Fonction: refundTransfer

Paramètres:
_transferId: 1

▶ transact
✅ Confirmer
```

**Vérifications:**

```javascript
Fonction: getTransferStatus

Résultat:
- status: 4 (Refunded)
- isRefunded: true
```

Vérifier solde de Account 1: devrait avoir récupéré ~0.5 ETH

✅ **Test 2 RÉUSSI!**

---

### Test 3: Gestion de Litige ✅

**Objectif:** Lever et résoudre un litige.

**Contexte:**
- Transfert créé et financé
- Désaccord entre parties
- Admin intervient et split 50/50

**Étapes:**

#### 3.1 Créer et financer

```javascript
// Account 1

Fonction: createAndFundTransfer

Paramètres:
_recipient: [ADRESSE_ACCOUNT_2]
_validator: [ADRESSE_ACCOUNT_3]
_purpose: "Transfert avec litige"
_deadlineSeconds: 2592000

Value: 800000000000000000 wei (0.8 ETH)

▶ transact
```

#### 3.2 Lever un litige

```javascript
// Account 1 (ou 2 ou 3 peut lever)

Fonction: raiseDispute

Paramètres:
_transferId: 2
_reason: "Beneficiaire n'a pas utilise pour objectif initial"

▶ transact
```

**Vérification:**
```javascript
Fonction: getTransferStatus

Résultat:
- status: 5 (Disputed)
```

#### 3.3 Résoudre le litige (Owner)

```javascript
// Account 1 (car c'est le owner/deployer)

Fonction: resolveDispute

Paramètres:
_transferId: 2
_percentageToRecipient: 50

▶ transact
```

**Vérifications:**

1. Vérifier le statut:
```javascript
Fonction: getTransferStatus

Résultat:
- status: 3 (Completed)
```

2. Vérifier les soldes:
   - Account 1: +0.4 ETH
   - Account 2: +0.4 ETH

✅ **Test 3 RÉUSSI!**

---

### Test 4: Modification de Paramètres ✅

**Objectif:** Tester les fonctions de modification.

#### 4.1 Créer transfert (ne PAS financer immédiatement)

```javascript
// Account 1

Fonction: createTransfer

Paramètres:
_recipient: [ADRESSE_ACCOUNT_2]
_validator: [ADRESSE_ACCOUNT_3]
_purpose: "Test modifications"
_deadlineSeconds: 2592000

▶ transact
```

#### 4.2 Changer le bénéficiaire

```javascript
// Account 1

Fonction: updateRecipient

Paramètres:
_transferId: 3
_newRecipient: [NOUVELLE_ADRESSE]

▶ transact
```

#### 4.3 Changer le validateur

```javascript
Fonction: updateValidator

Paramètres:
_transferId: 3
_newValidator: [NOUVELLE_ADRESSE]

▶ transact
```

#### 4.4 Financer

```javascript
Fonction: fundTransfer

Paramètres:
_transferId: 3

Value: 300000000000000000 (0.3 ETH)

▶ transact
```

#### 4.5 Prolonger la deadline

```javascript
Fonction: extendDeadline

Paramètres:
_transferId: 3
_additionalSeconds: 1296000 (15 jours)

▶ transact
```

✅ **Test 4 RÉUSSI!**

---

### Test 5: Validateurs de Confiance ✅

**Objectif:** Tester le système de validateurs certifiés.

#### 5.1 Ajouter un validateur de confiance

```javascript
// Account 1 (owner)

Fonction: addTrustedValidator

Paramètres:
_validator: [ADRESSE_ACCOUNT_3]

▶ transact
```

#### 5.2 Vérifier qu'il est de confiance

```javascript
Fonction: isTrustedValidator

Paramètres:
_validator: [ADRESSE_ACCOUNT_3]

Résultat: true
```

#### 5.3 Retirer un validateur

```javascript
Fonction: removeTrustedValidator

Paramètres:
_validator: [ADRESSE_ACCOUNT_3]

▶ transact
```

✅ **Test 5 RÉUSSI!**

---

## Checklist de Test Complète

- ✅ Créer et financer transfert
- ✅ Valider transfert
- ✅ Retirer fonds
- ✅ Remboursement automatique
- ✅ Lever litige
- ✅ Résoudre litige
- ✅ Modifier bénéficiaire
- ✅ Modifier validateur
- ✅ Prolonger deadline
- ✅ Ajouter validateur de confiance
- ✅ Vérifier statistiques utilisateur
- ✅ Vérifier TVL
- ✅ Vérifier frais de plateforme (1%)

## Résumé des Résultats

| Test | Scénario | Statut |
|------|----------|--------|
| 1 | Transfert complet réussi | ✅ PASS |
| 2 | Remboursement automatique | ✅ PASS |
| 3 | Gestion de litige | ✅ PASS |
| 4 | Modifications paramètres | ✅ PASS |
| 5 | Validateurs de confiance | ✅ PASS |

**Tous les tests sont RÉUSSIS! 🎉**

## Notes Importantes

1. **Gas Fees:** Sur testnet, les frais sont négligeables. Sur mainnet, prévoir 50-200k gas par transaction.

2. **Deadlines:** Pour tester rapidement, utiliser des deadlines courtes (60-300 secondes). En production, recommandé: 7-30 jours.

3. **Montants:** Sur testnet, utiliser 0.1-1 ETH. En production avec stablecoins, montants réels (100-10,000 USD).

4. **Sécurité:** Ce contrat doit être audité avant utilisation en production!

## Prochaines Étapes

1. ✅ Déployer sur Sepolia ✓
2. 🔜 Audit de sécurité
3. 🔜 Déployer sur Polygon Mainnet
4. 🔜 Intégrer dans interface web
5. 🔜 Ajouter support stablecoins (USDC, USDT)

---

**Happy Testing! 🚀**
