;; Credential Issuance Contract

(define-non-fungible-token educational-credential uint)

(define-map credential-info
  { credential-id: uint }
  {
    institution: principal,
    recipient: principal,
    credential-type: (string-ascii 50),
    issue-date: uint,
    expiration-date: (optional uint),
    metadata: (string-utf8 500)
  }
)

(define-data-var credential-id-nonce uint u0)

(define-constant AUTHORIZED_INSTITUTIONS
  (list
    'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
    'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG
  )
)

(define-read-only (is-authorized-institution (institution principal))
  (is-some (index-of AUTHORIZED_INSTITUTIONS institution))
)

(define-public (issue-credential
  (recipient principal)
  (credential-type (string-ascii 50))
  (expiration-date (optional uint))
  (metadata (string-utf8 500))
)
  (let
    ((new-credential-id (+ (var-get credential-id-nonce) u1)))
    (asserts! (is-authorized-institution tx-sender) ERR_UNAUTHORIZED)
    (try! (nft-mint? educational-credential new-credential-id recipient))
    (map-set credential-info
      { credential-id: new-credential-id }
      {
        institution: tx-sender,
        recipient: recipient,
        credential-type: credential-type,
        issue-date: block-height,
        expiration-date: expiration-date,
        metadata: metadata
      }
    )
    (var-set credential-id-nonce new-credential-id)
    (ok new-credential-id)
  )
)

(define-read-only (get-credential-info (credential-id uint))
  (map-get? credential-info { credential-id: credential-id })
)

(define-public (revoke-credential (credential-id uint))
  (let
    ((credential (unwrap! (map-get? credential-info { credential-id: credential-id }) ERR_CREDENTIAL_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get institution credential)) ERR_UNAUTHORIZED)
    (try! (nft-burn? educational-credential credential-id (get recipient credential)))
    (ok (map-delete credential-info { credential-id: credential-id }))
  )
)

(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_CREDENTIAL_NOT_FOUND (err u404))
