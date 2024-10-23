;; Simple Physical Asset Authentication System

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ASSET-NOT-FOUND (err u101))
(define-constant ERR-ALREADY-LISTED (err u102))
(define-constant ERR-NOT-LISTED (err u103))
(define-constant ERR-INVALID-PRICE (err u104))

;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var asset-counter uint u0)

;; Data Maps
(define-map PhysicalAssets
    { asset-id: uint }
    {
        owner: principal,
        metadata: (string-utf8 256),
        location: (string-utf8 100),
        condition: uint,
        is-listed: bool
    }
)

(define-map AssetListings
    { asset-id: uint }
    {
        price: uint,
        seller: principal
    }
)

;; Administrative Functions
(define-public (set-contract-owner (new-owner principal))
    (begin
        (asserts! (is-eq tx-sender (var-get contract-owner)) ERR-NOT-AUTHORIZED)
        (ok (var-set contract-owner new-owner))
    )
)

;; Asset Management Functions
(define-public (mint-asset
    (metadata (string-utf8 256))
    (location (string-utf8 100))
    )
    (let
        (
            (new-asset-id (+ (var-get asset-counter) u1))
        )
        (map-set PhysicalAssets
            { asset-id: new-asset-id }
            {
                owner: tx-sender,
                metadata: metadata,
                location: location,
                condition: u100,
                is-listed: false
            }
        )
        (var-set asset-counter new-asset-id)
        (ok new-asset-id)
    )
)

(define-public (update-location
    (asset-id uint)
    (new-location (string-utf8 100))
    )
    (let
        (
            (asset (unwrap! (map-get? PhysicalAssets { asset-id: asset-id }) ERR-ASSET-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get owner asset)) ERR-NOT-AUTHORIZED)
        (map-set PhysicalAssets
            { asset-id: asset-id }
            (merge asset { location: new-location })
        )
        (ok true)
    )
)

;; Market Functions
(define-public (list-asset
    (asset-id uint)
    (price uint)
    )
    (let
        (
            (asset (unwrap! (map-get? PhysicalAssets { asset-id: asset-id }) ERR-ASSET-NOT-FOUND))
        )
        (asserts! (is-eq (get owner asset) tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (get is-listed asset)) ERR-ALREADY-LISTED)
        (asserts! (> price u0) ERR-INVALID-PRICE)

        (map-set AssetListings
            { asset-id: asset-id }
            {
                price: price,
                seller: tx-sender
            }
        )

        (map-set PhysicalAssets
            { asset-id: asset-id }
            (merge asset { is-listed: true })
        )
        (ok true)
    )
)

(define-public (unlist-asset (asset-id uint))
    (let
        (
            (asset (unwrap! (map-get? PhysicalAssets { asset-id: asset-id }) ERR-ASSET-NOT-FOUND))
            (listing (unwrap! (map-get? AssetListings { asset-id: asset-id }) ERR-NOT-LISTED))
        )
        (asserts! (is-eq tx-sender (get seller listing)) ERR-NOT-AUTHORIZED)

        (map-delete AssetListings { asset-id: asset-id })
        (map-set PhysicalAssets
            { asset-id: asset-id }
            (merge asset { is-listed: false })
        )
        (ok true)
    )
)

(define-public (purchase-asset (asset-id uint))
    (let
        (
            (asset (unwrap! (map-get? PhysicalAssets { asset-id: asset-id }) ERR-ASSET-NOT-FOUND))
            (listing (unwrap! (map-get? AssetListings { asset-id: asset-id }) ERR-NOT-LISTED))
        )
        (asserts! (not (is-eq tx-sender (get seller listing))) ERR-NOT-AUTHORIZED)

        (map-delete AssetListings { asset-id: asset-id })
        (map-set PhysicalAssets
            { asset-id: asset-id }
            (merge asset {
                owner: tx-sender,
                is-listed: false
            })
        )
        (ok true)
    )
)

;; Read-Only Functions
(define-read-only (get-asset-details (asset-id uint))
    (map-get? PhysicalAssets { asset-id: asset-id })
)

(define-read-only (get-listing (asset-id uint))
    (map-get? AssetListings { asset-id: asset-id })
)

(define-read-only (get-owner)
    (var-get contract-owner)
)
