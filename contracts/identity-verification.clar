;; Identity Verification Contract
;; Handles identity verification processes

(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_VERIFICATION_NOT_FOUND (err u401))
(define-constant ERR_INVALID_VERIFICATION (err u402))
(define-constant ERR_ALREADY_VERIFIED (err u403))

;; Data structures
(define-map verifications
  { verification-id: uint }
  {
    citizen-id: uint,
    verification-type: uint,
    verification-data-hash: (buff 32),
    verifier-agency: uint,
    verification-date: uint,
    expiry-date: uint,
    status: uint
  }
)

(define-map citizen-verifications
  { citizen-id: uint, verification-type: uint }
  { verification-id: uint }
)

(define-data-var next-verification-id uint u1)

;; Verification types
(define-constant TYPE_IDENTITY u1)
(define-constant TYPE_ADDRESS u2)
(define-constant TYPE_EMPLOYMENT u3)
(define-constant TYPE_INCOME u4)

;; Verification status
(define-constant STATUS_PENDING u0)
(define-constant STATUS_VERIFIED u1)
(define-constant STATUS_REJECTED u2)
(define-constant STATUS_EXPIRED u3)

;; Public functions
(define-public (submit-verification
  (citizen-id uint)
  (verification-type uint)
  (data-hash (buff 32))
  (validity-blocks uint))
  (let ((verification-id (var-get next-verification-id)))
    ;; Check if citizen already has this type of verification
    (asserts! (is-none (map-get? citizen-verifications
      { citizen-id: citizen-id, verification-type: verification-type }))
      ERR_ALREADY_VERIFIED)

    (map-set verifications
      { verification-id: verification-id }
      {
        citizen-id: citizen-id,
        verification-type: verification-type,
        verification-data-hash: data-hash,
        verifier-agency: u0, ;; Will be set when verified
        verification-date: u0,
        expiry-date: (+ block-height validity-blocks),
        status: STATUS_PENDING
      }
    )

    (map-set citizen-verifications
      { citizen-id: citizen-id, verification-type: verification-type }
      { verification-id: verification-id }
    )

    (var-set next-verification-id (+ verification-id u1))
    (ok verification-id)
  )
)

(define-public (approve-verification (verification-id uint) (agency-id uint))
  (match (map-get? verifications { verification-id: verification-id })
    verification-data
    (begin
      ;; Simplified agency verification
      (asserts! (> agency-id u0) ERR_UNAUTHORIZED)
      (asserts! (is-eq (get status verification-data) STATUS_PENDING) ERR_INVALID_VERIFICATION)

      (map-set verifications
        { verification-id: verification-id }
        (merge verification-data {
          verifier-agency: agency-id,
          verification-date: block-height,
          status: STATUS_VERIFIED
        })
      )
      (ok true)
    )
    ERR_VERIFICATION_NOT_FOUND
  )
)

(define-public (reject-verification (verification-id uint) (agency-id uint))
  (match (map-get? verifications { verification-id: verification-id })
    verification-data
    (begin
      (asserts! (> agency-id u0) ERR_UNAUTHORIZED)
      (asserts! (is-eq (get status verification-data) STATUS_PENDING) ERR_INVALID_VERIFICATION)

      (map-set verifications
        { verification-id: verification-id }
        (merge verification-data {
          verifier-agency: agency-id,
          verification-date: block-height,
          status: STATUS_REJECTED
        })
      )
      (ok true)
    )
    ERR_VERIFICATION_NOT_FOUND
  )
)

;; Read-only functions
(define-read-only (get-verification (verification-id uint))
  (map-get? verifications { verification-id: verification-id })
)

(define-read-only (get-citizen-verification (citizen-id uint) (verification-type uint))
  (match (map-get? citizen-verifications { citizen-id: citizen-id, verification-type: verification-type })
    verification-ref (map-get? verifications { verification-id: (get verification-id verification-ref) })
    none
  )
)

(define-read-only (is-verification-valid (citizen-id uint) (verification-type uint))
  (match (get-citizen-verification citizen-id verification-type)
    verification-data
    (and
      (is-eq (get status verification-data) STATUS_VERIFIED)
      (> (get expiry-date verification-data) block-height)
    )
    false
  )
)
