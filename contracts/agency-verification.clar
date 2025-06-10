;; Agency Verification Contract
;; Validates and manages government agencies

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_AGENCY_EXISTS (err u101))
(define-constant ERR_AGENCY_NOT_FOUND (err u102))
(define-constant ERR_INVALID_STATUS (err u103))

;; Agency status constants
(define-constant STATUS_PENDING u0)
(define-constant STATUS_VERIFIED u1)
(define-constant STATUS_SUSPENDED u2)
(define-constant STATUS_REVOKED u3)

;; Data structures
(define-map agencies
  { agency-id: uint }
  {
    name: (string-ascii 100),
    contact-info: (string-ascii 200),
    verification-date: uint,
    status: uint,
    verifier: principal
  }
)

(define-map agency-principals
  { principal: principal }
  { agency-id: uint }
)

(define-data-var next-agency-id uint u1)

;; Public functions
(define-public (register-agency (name (string-ascii 100)) (contact-info (string-ascii 200)))
  (let ((agency-id (var-get next-agency-id)))
    (asserts! (is-none (map-get? agency-principals { principal: tx-sender })) ERR_AGENCY_EXISTS)
    (map-set agencies
      { agency-id: agency-id }
      {
        name: name,
        contact-info: contact-info,
        verification-date: u0,
        status: STATUS_PENDING,
        verifier: CONTRACT_OWNER
      }
    )
    (map-set agency-principals { principal: tx-sender } { agency-id: agency-id })
    (var-set next-agency-id (+ agency-id u1))
    (ok agency-id)
  )
)

(define-public (verify-agency (agency-id uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (match (map-get? agencies { agency-id: agency-id })
      agency-data
      (begin
        (map-set agencies
          { agency-id: agency-id }
          (merge agency-data {
            verification-date: block-height,
            status: STATUS_VERIFIED
          })
        )
        (ok true)
      )
      ERR_AGENCY_NOT_FOUND
    )
  )
)

(define-public (update-agency-status (agency-id uint) (new-status uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (<= new-status STATUS_REVOKED) ERR_INVALID_STATUS)
    (match (map-get? agencies { agency-id: agency-id })
      agency-data
      (begin
        (map-set agencies
          { agency-id: agency-id }
          (merge agency-data { status: new-status })
        )
        (ok true)
      )
      ERR_AGENCY_NOT_FOUND
    )
  )
)

;; Read-only functions
(define-read-only (get-agency (agency-id uint))
  (map-get? agencies { agency-id: agency-id })
)

(define-read-only (get-agency-by-principal (principal principal))
  (match (map-get? agency-principals { principal: principal })
    agency-ref (map-get? agencies { agency-id: (get agency-id agency-ref) })
    none
  )
)

(define-read-only (is-verified-agency (agency-id uint))
  (match (map-get? agencies { agency-id: agency-id })
    agency-data (is-eq (get status agency-data) STATUS_VERIFIED)
    false
  )
)
