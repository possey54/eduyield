# EduYield - Learn-to-Earn Education Platform

## Overview

EduYield is a blockchain-based learn-to-earn education platform built on the Stacks blockchain using Clarity smart contracts. It enables instructors to create courses with reward mechanisms and allows students to enroll, complete quizzes, and claim rewards based on their performance.

## Features

###  Course Management
- **Create Courses**: Instructors can create courses with customizable titles, reward amounts, and enrollment fees
- **Deactivate Courses**: Course instructors can deactivate courses to prevent new enrollments
- **Course Tracking**: View course details including title, instructor, reward, and fee information

###  Student Enrollment
- **Fee-Based Enrollment**: Students pay an enrollment fee (staked in the contract) to join courses
- **Enrollment Validation**: Prevents duplicate enrollments for the same course
- **Enrollment Status**: Track student enrollment history and completion status

###  Quiz & Assessment
- **Quiz Submission**: Students submit quiz scores after completing course material
- **Pass Threshold**: Minimum 50% score required to pass and be eligible for rewards
- **Score Tracking**: Records student performance for each course

###  Reward System
- **Dual Rewards**: Students earn course rewards + their staked enrollment fee
- **Reward Claims**: Only students who pass quizzes can claim their rewards
- **STX Transfers**: Rewards are transferred directly to student wallets

###  Admin Controls
- **Admin Management**: Set and manage contract administrator
- **Authorization**: Only authorized users can perform admin operations

## Data Structures

### Courses Map
```
{
  id: uint,
  title: string-ascii(64),
  instructor: principal,
  reward: uint,
  fee: uint,
  active: bool
}
```

### Enrollments Map
```
{
  user: principal,
  course-id: uint,
  staked: uint,
  completed: bool,
  score: uint
}
```

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u100 | ERR_NOT_ENROLLED | User is not enrolled in the specified course |
| u101 | ERR_ALREADY_ENROLLED | User is already enrolled in the course |
| u102 | ERR_LOW_SCORE | Quiz score below 50% minimum threshold |
| u103 | ERR_UNAUTHORIZED | Unauthorized access (not admin or instructor) |
| u104 | ERR_NO_REWARD | No reward available (course not completed) |

## Public Functions

### Admin Functions
- `set-admin(new-admin: principal)` - Update contract administrator

### Course Management
- `create-course(title, reward, fee)` - Create a new course
- `deactivate-course(course-id)` - Deactivate an active course

### Student Functions
- `enroll(course-id)` - Enroll in a course (requires fee payment)
- `submit-quiz(course-id, score)` - Submit quiz results
- `claim-reward(course-id)` - Claim earned rewards

### Read-Only Functions
- `get-course(course-id)` - Retrieve course information
- `get-enrollment(user, course-id)` - Check enrollment status
- `get-total-courses()` - Get total number of created courses
- `get-admin()` - Retrieve current admin address

## Usage Example

```clarity
;; Create a course
(contract-call? .eduyield create-course 
  "Bitcoin Basics" 
  u1000000  ;; 1 STX reward
  u500000   ;; 0.5 STX enrollment fee
)

;; Enroll in course
(contract-call? .eduyield enroll u1)

;; Submit quiz (75% score)
(contract-call? .eduyield submit-quiz u1 u75)

;; Claim reward (1 STX + 0.5 STX = 1.5 STX)
(contract-call? .eduyield claim-reward u1)
```

## Contract Variables

- `total-courses`: Tracks the total number of courses created
- `admin`: Stores the current contract administrator's principal

## Security Considerations

-  Authorization checks for admin and instructor operations
-  Duplicate enrollment prevention
-  Score validation before reward eligibility
-  STX transfer safety with try! blocks
-  Role-based access control

## Future Enhancements

- Multi-instructor support with role management
- Grading rubrics and partial credit system
- Course completion certificates (NFT)
- Leaderboards and achievement badges
- Dynamic fee/reward adjustment
- Course ratings and reviews
