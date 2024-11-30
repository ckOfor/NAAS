;; Asset Verification Contract for Physical Asset Authentication System

;; Constants
(define-constant contract-owner tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-VERIFIER-NOT-FOUND (err u101))
(define-constant ERR-INVALID-SCORE (err u103))

;; Data Maps
(define-map verifiers principal bool)

(define-map asset-verifications
    { asset-id: uint }
    {
        verifier: principal,
        verification-score: uint,
        timestamp: uint,
        notes: (string-utf8 500)
    }
)

;; Public Functions
(define-public (add-verifier (new-verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
        (ok (map-set verifiers new-verifier true))
    )
)

(define-public (remove-verifier (verifier principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) ERR-NOT-AUTHORIZED)
        (ok (map-delete verifiers verifier))
    )
)
