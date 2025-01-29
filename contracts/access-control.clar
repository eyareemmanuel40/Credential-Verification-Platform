;; Access Control Contract

(define-map roles
  { user: principal }
  { role: (string-ascii 20) }
)

(define-data-var contract-owner principal tx-sender)

(define-public (set-role (user principal) (role (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-set roles { user: user } { role: role }))
  )
)

(define-public (remove-role (user principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (map-delete roles { user: user }))
  )
)

(define-read-only (get-role (user principal))
  (default-to "none" (get role (map-get? roles { user: user })))
)

(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_UNAUTHORIZED)
    (ok (var-set contract-owner new-owner))
  )
)

(define-constant ERR_UNAUTHORIZED (err u401))

