;; Title: BitTrust - Stacks Reputation System
;; Summary: A decentralized reputation scoring system for Bitcoin Layer 2 identities
;; Description: BitTrust enables trustless reputation management on Stacks, allowing users to build
;;              and maintain verifiable reputation scores through on-chain actions. The system supports
;;              time-based reputation decay, multiple action types with weighted scoring, and threshold
;;              verification for DeFi and governance applications. Built for Bitcoin's security with
;;              Stacks' smart contract capabilities.

;; CONSTANTS & ERROR CODES

;; Error Codes
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-PARAMETERS (err u101))
(define-constant ERR-IDENTITY-EXISTS (err u102))
(define-constant ERR-IDENTITY-NOT-FOUND (err u103))
(define-constant ERR-INSUFFICIENT-REPUTATION (err u104))
(define-constant ERR-MAX-REPUTATION-REACHED (err u105))

;; System Constants
(define-constant MAX-REPUTATION-SCORE u1000)
(define-constant MIN-REPUTATION-SCORE u0)
(define-constant REPUTATION-DECAY-RATE u10) ;; 10% decay per period

;; DATA STORAGE

(define-map identities
  { owner: principal }
  {
    did: (string-ascii 50), ;; Decentralized Identity Identifier
    reputation-score: uint, ;; Current reputation score (0-1000)
    created-at: uint, ;; Block height when identity was created
    last-updated: uint, ;; Block height of last reputation update
  }
)

(define-map reputation-actions
  { action-type: (string-ascii 50) }
  { multiplier: uint } ;; Points awarded for this action type
)

;; PRIVATE FUNCTIONS

(define-private (is-valid-owner (owner principal))
  ;; Validates that the caller owns the identity
  (and
    (is-some (map-get? identities { owner: owner }))
    (is-eq owner tx-sender)
  )
)

;; PUBLIC FUNCTIONS

(define-public (initialize-reputation-actions)
  ;; Initialize the reputation action multipliers for different activities
  (begin
    (map-set reputation-actions { action-type: "governance-vote" } { multiplier: u5 })
    (map-set reputation-actions { action-type: "contract-fulfillment" } { multiplier: u10 })
    (map-set reputation-actions { action-type: "community-contribution" } { multiplier: u7 })
    (ok true)
  )
)

(define-public (create-identity (did (string-ascii 50)))
  ;; Create a new decentralized identity with initial reputation score
  (let (
      (sender tx-sender)
      (current-stacks-block-height stacks-block-height)
    )
    (begin
      ;; Ensure identity doesn't already exist
      (asserts! (is-none (map-get? identities { owner: sender }))
        ERR-IDENTITY-EXISTS
      )
      ;; Validate DID length
      (asserts! (> (len did) u5) ERR-INVALID-PARAMETERS)
      ;; Create new identity
      (map-set identities { owner: sender } {
        did: did,
        reputation-score: u50, ;; Starting reputation score
        created-at: current-stacks-block-height,
        last-updated: current-stacks-block-height,
      })
      (ok did)
    )
  )
)

(define-public (update-reputation (action-type (string-ascii 50)))
  ;; Update reputation score based on verified on-chain action
  (let (
      (owner tx-sender)
      (current-identity (unwrap! (map-get? identities { owner: owner }) ERR-IDENTITY-NOT-FOUND))
      (action-multiplier (default-to u0
        (get multiplier
          (map-get? reputation-actions { action-type: action-type })
        )))
      (current-score (get reputation-score current-identity))
      (updated-score (if (< (+ current-score action-multiplier) MAX-REPUTATION-SCORE)
        (+ current-score action-multiplier)
        MAX-REPUTATION-SCORE
      ))
    )
    (begin
      ;; Validate action type exists
      (asserts!
        (is-some (map-get? reputation-actions { action-type: action-type }))
        ERR-INVALID-PARAMETERS
      )
      ;; Update identity with new score
      (map-set identities { owner: owner }
        (merge current-identity {
          reputation-score: updated-score,
          last-updated: stacks-block-height,
        })
      )
      (ok updated-score)
    )
  )
)

(define-public (decay-reputation)
  ;; Apply time-based reputation decay to prevent score inflation
  (let (
      (owner tx-sender)
      (current-identity (unwrap! (map-get? identities { owner: owner }) ERR-IDENTITY-NOT-FOUND))
      (current-score (get reputation-score current-identity))
      (decay-amount (/ (* current-score REPUTATION-DECAY-RATE) u100))
      (updated-score (if (> (- current-score decay-amount) MIN-REPUTATION-SCORE)
        (- current-score decay-amount)
        MIN-REPUTATION-SCORE
      ))
    )
    (begin
      ;; Apply decay to reputation score
      (map-set identities { owner: owner }
        (merge current-identity {
          reputation-score: updated-score,
          last-updated: stacks-block-height,
        })
      )
      (ok updated-score)
    )
  )
)

;; READ-ONLY FUNCTIONS

(define-read-only (get-reputation (owner principal))
  ;; Retrieve complete identity information for a given principal
  (map-get? identities { owner: owner })
)