;; learn-earn-hub.clar
;; Learn-to-earn education contract for the Stacks blockchain

(define-constant ERR_NOT_ENROLLED (err u100))
(define-constant ERR_ALREADY_ENROLLED (err u101))
(define-constant ERR_LOW_SCORE (err u102))
(define-constant ERR_UNAUTHORIZED (err u103))
(define-constant ERR_NO_REWARD (err u104))

;; === DATA STRUCTURES ===

;; course info
(define-map courses
  { id: uint }
  { title: (string-ascii 64),
    instructor: principal,
    reward: uint,
    fee: uint,
    active: bool })

;; enrollment info
(define-map enrollments
  { user: principal, course-id: uint }
  { staked: uint, completed: bool, score: uint })

;; === VARIABLES ===
(define-data-var total-courses uint u0)
(define-data-var admin principal tx-sender)

;; === ADMIN FUNCTIONS ===

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) ERR_UNAUTHORIZED)
    (var-set admin new-admin)
    (ok new-admin)
  )
)

;; === COURSE MANAGEMENT ===

(define-public (create-course (title (string-ascii 64)) (reward uint) (fee uint))
  (let ((id (+ u1 (var-get total-courses))))
    (begin
      (map-set courses
        { id: id }
        { title: title, instructor: tx-sender, reward: reward, fee: fee, active: true })
      (var-set total-courses id)
      (ok id)
    )
  )
)

(define-public (deactivate-course (course-id uint))
  (let ((course (map-get? courses { id: course-id })))
    (match course
      course-data
      (begin
        (asserts! (is-eq tx-sender (get instructor course-data)) ERR_UNAUTHORIZED)
        (map-set courses { id: course-id } (merge course-data { active: false }))
        (ok course-id)
      )
      (err u1)
    )
  )
)

;; === STUDENT INTERACTION ===

(define-public (enroll (course-id uint))
  (let ((course (map-get? courses { id: course-id })))
    (match course
      course-data
      (begin
        (asserts! (get active course-data) (err u200))
        (if (is-some (map-get? enrollments { user: tx-sender, course-id: course-id }))
            ERR_ALREADY_ENROLLED
            (let ((fee (get fee course-data)))
              (try! (stx-transfer? fee tx-sender (as-contract tx-sender)))
              (map-set enrollments { user: tx-sender, course-id: course-id }
                { staked: fee, completed: false, score: u0 })
              (ok "Enrolled successfully")
            )
        )
      )
      (err u404)
    )
  )
)

(define-public (submit-quiz (course-id uint) (score uint))
  (let ((enrollment-data (map-get? enrollments { user: tx-sender, course-id: course-id })))
    (match enrollment-data
      enroll-data
      (begin
        (asserts! (not (get completed enroll-data)) ERR_NO_REWARD)
        (if (>= score u50)
            (begin
              (map-set enrollments { user: tx-sender, course-id: course-id }
                (merge enroll-data { completed: true, score: score }))
              (ok "Quiz passed")
            )
            ERR_LOW_SCORE
        )
      )
      ERR_NOT_ENROLLED
    )
  )
)

(define-public (claim-reward (course-id uint))
  (let (
        (enrollment-data (map-get? enrollments { user: tx-sender, course-id: course-id }))
        (course (map-get? courses { id: course-id }))
       )
    (match enrollment-data
      enroll-data
      (match course
        course-data
        (if (get completed enroll-data)
            (let ((reward (+ (get reward course-data) (get staked enroll-data))))
              (try! (stx-transfer? reward (as-contract tx-sender) tx-sender))
              (ok reward)
            )
            ERR_NO_REWARD
        )
        (err u404)
      )
      ERR_NOT_ENROLLED
    )
  )
)

;; === VIEW FUNCTIONS ===

(define-read-only (get-course (course-id uint))
  (map-get? courses { id: course-id })
)

(define-read-only (get-enrollment (user principal) (course-id uint))
  (map-get? enrollments { user: user, course-id: course-id })
)

(define-read-only (get-total-courses)
  (ok (var-get total-courses))
)

(define-read-only (get-admin)
  (ok (var-get admin))
)
