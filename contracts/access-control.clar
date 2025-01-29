;; Achievement NFT Contract

(define-non-fungible-token achievement uint)

(define-map achievement-info
  { achievement-id: uint }
  {
    owner: principal,
    institution: principal,
    achievement-type: (string-ascii 50),
    issue-date: uint,
    metadata: (string-utf8 500)
  }
)

(define-data-var achievement-id-nonce uint u0)

(define-public (mint-achievement
  (recipient principal)
  (achievement-type (string-ascii 50))
  (metadata (string-utf8 500))
)
  (let
    ((new-achievement-id (+ (var-get achievement-id-nonce) u1)))
    (asserts! (is-authorized-institution tx-sender) ERR_UNAUTHORIZED)
    (try! (nft-mint? achievement new-achievement-id recipient))
    (map-set achievement-info
      { achievement-id: new-achievement-id }
      {
        owner: recipient,
        institution: tx-sender,
        achievement-type: achievement-type,
        issue-date: block-height,
        metadata: metadata
      }
    )
    (var-set achievement-id-nonce new-achievement-id)
    (ok new-achievement-id)
  )
)

(define-read-only (get-achievement-info (achievement-id uint))
  (map-get? achievement-info { achievement-id: achievement-id })
)

(define-constant ERR_UNAUTHORIZED (err u401))

