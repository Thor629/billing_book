# Design Document

## Overview

The Flutter SaaS Billing Platform is a full-stack subscription management system consisting of a Flutter frontend application and a Laravel backend API. The architecture follows a clean separation between client and server, with RESTful API communication. The system supports both web and mobile platforms through Flutter's cross-platform capabilities, while Laravel provides a robust, secure backend with authentication, authorization, and data persistence.

The platform implements role-based access control (RBAC) with two primary roles: Admin and User. A unified login interface authenticates both roles and routes them to appropriate dashboards based on their permissions.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────┐
│         Flutter Frontend                │
│  (Web, iOS, Android)                    │
│                                         │
│  ┌──────────────┐  ┌─────────────────┐ │
│  │ Admin Panel  │  │   User Panel    │ │
│  │  Dashboard   │  │   Dashboard     │ │
│  └──────────────┘  └─────────────────┘ │
│           │                │            │
│           └────────┬───────┘            │
│                    │                    │
│           ┌────────▼────────┐           │
│           │  Auth Service   │           │
│           │  API Client     │           │
│           └────────┬────────┘           │
└────────────────────┼────────────────────┘
                     │ HTTPS/REST
                     │
┌────────────────────▼────────────────────┐
│         Laravel Backend API             │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │     API Routes & Controllers     │  │
│  └──────────────┬───────────────────┘  │
│                 │                       │
│  ┌──────────────▼───────────────────┐  │
│  │  Middleware (Auth, CORS, etc)    │  │
│  └──────────────┬───────────────────┘  │
│                 │                       │
│  ┌──────────────▼───────────────────┐  │
│  │    Business Logic Services       │  │
│  └──────────────┬───────────────────┘  │
│                 │                       │
│  ┌──────────────▼───────────────────┐  │
│  │    Eloquent Models & ORM         │  │
│  └──────────────┬───────────────────┘  │
└─────────────────┼───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         MySQL Database                  │
│  (Users, Plans, Subscriptions, etc)    │
└─────────────────────────────────────────┘
```

### Technology Stack

**Frontend:**
- Flutter 3.x (Dart)
- Provider or Riverpod for state management
- HTTP/Dio for API communication
- Flutter Secure Storage for token management
- Responsive UI framework (flutter_screenutil)
- Google Fonts for typography

**Backend:**
- Laravel 10.x (PHP 8.1+)
- Laravel Sanctum for API authentication
- Eloquent ORM for database operations
- MySQL 8.0+ for data persistence
- Laravel Validation for input validation
- Laravel Mail for email notifications

### UI/UX Design System

**Color Palette:**
- Primary Dark: `#2D3250` (Sidebar background)
- Primary Light: `#424769` (Sidebar hover states)
- Background: `#F8F9FA` (Main content area)
- Card Background: `#FFFFFF`
- Success/Positive: `#10B981` (Green for positive metrics)
- Warning/Negative: `#EF4444` (Red for negative metrics)
- Info/Neutral: `#3B82F6` (Blue for informational elements)
- Text Primary: `#1F2937`
- Text Secondary: `#6B7280`
- Text Light: `#FFFFFF` (Sidebar text)
- Border: `#E5E7EB`

**Typography:**
- Primary Font: Inter or Roboto
- Heading Sizes: 24px (H1), 20px (H2), 16px (H3)
- Body Text: 14px
- Small Text: 12px
- Font Weights: Regular (400), Medium (500), Semibold (600), Bold (700)

**Spacing System:**
- Base unit: 8px
- Small: 8px
- Medium: 16px
- Large: 24px
- XLarge: 32px

**Component Styles:**
- Border Radius: 8px for cards, 6px for buttons, 4px for inputs
- Card Shadow: `0 1px 3px rgba(0,0,0,0.1)`
- Hover Shadow: `0 4px 6px rgba(0,0,0,0.1)`
- Transition Duration: 200ms for all interactive elements

**Layout Patterns:**
- Sidebar Width: 240px (desktop), collapsible on mobile
- Content Max Width: 1400px
- Card Padding: 24px
- Grid Gap: 24px
- Table Row Height: 56px

## Components and Interfaces

### Frontend Components

#### 1. Authentication Module
- **LoginScreen**: Unified login interface for both admin and users
  - Clean centered form with logo
  - Email and password fields with validation
  - "Login" button with loading state
  - Role detection happens server-side
- **AuthService**: Handles authentication logic, token management, and role detection
- **AuthProvider**: State management for authentication state

#### 2. Admin Panel Module
- **AdminDashboard**: Overview of system statistics
  - Top metrics cards showing: Total Users, Active Subscriptions, Revenue
  - Color-coded cards (green for positive metrics, blue for totals)
  - Recent activity table with user actions
  - Quick action buttons
- **UserManagementScreen**: List, create, edit, activate/deactivate users
  - Data table with columns: Name, Email, Status, Plan, Actions
  - Search and filter functionality
  - "Add User" button (primary action)
  - Toggle switches for activate/deactivate
  - Edit and delete icons in action column
- **PlanManagementScreen**: CRUD operations for subscription plans
  - Grid or list view of plans
  - Each plan card shows: Name, Monthly/Yearly price, Features list
  - "Add Plan" button
  - Edit and delete actions per plan
  - Active/Inactive status indicator
- **AdminNavigationDrawer**: Dark sidebar navigation
  - Logo and business name at top
  - Menu items with icons: Dashboard, Users, Plans, Reports, Settings
  - Active state highlighting
  - Collapsible on mobile

#### 3. User Panel Module
- **UserDashboard**: User's subscription status and account overview
  - Current plan card with features
  - Subscription expiry date
  - Usage statistics (if applicable)
  - Quick links to manage subscription
- **ProfileScreen**: View and edit user profile information
  - Form layout with sections
  - Editable fields: Name, Email, Password
  - "Save Changes" button
  - Avatar/profile picture upload
- **PlansScreen**: Browse and subscribe to available plans
  - Card grid layout (3 columns on desktop)
  - Each card: Plan name, price toggle (monthly/yearly), features list, "Subscribe" button
  - Current plan highlighted
  - Comparison view option
- **SubscriptionScreen**: Manage current subscription
  - Current plan details
  - Billing history table
  - Upgrade/downgrade options
  - Cancel subscription option
- **UserNavigationDrawer**: Navigation menu for user features
  - Similar dark sidebar style as admin
  - Menu items: Dashboard, My Profile, Plans, Subscription, Support

#### 4. Shared UI Components
- **MetricCard**: Reusable card for displaying key metrics
  - Icon, label, value, trend indicator
  - Color variants for different metric types
- **DataTable**: Reusable table component
  - Sortable columns
  - Pagination
  - Row actions
  - Responsive (converts to cards on mobile)
- **StatusBadge**: Colored badge for status indicators
  - Variants: Active (green), Inactive (gray), Expired (red)
- **ActionButton**: Icon buttons for table actions
  - Edit, Delete, View, Toggle icons
  - Hover states with tooltips
- **FormInput**: Styled input fields
  - Label, input, error message
  - Validation states
  - Prefix/suffix icon support
- **ApiClient**: HTTP client wrapper with authentication headers
- **ErrorHandler**: Centralized error handling and user feedback
- **LoadingIndicator**: Consistent loading states across the app
- **FormValidators**: Reusable validation logic

### Backend Components

#### 1. API Controllers
- **AuthController**: Handles login, logout, token refresh, registration
- **UserController**: User CRUD operations (admin only)
- **PlanController**: Subscription plan CRUD operations
- **SubscriptionController**: Subscription management
- **ProfileController**: User profile operations
- **OrganizationController**: Organization CRUD operations and member management

#### 2. Models (Eloquent)
- **User**: User accounts with role, status, and relationships
- **Plan**: Subscription plans with pricing and features
- **Subscription**: User subscriptions with plan and expiration
- **ActivityLog**: Audit trail for admin actions

#### 3. Middleware
- **Authenticate**: Verify API token validity
- **AdminOnly**: Restrict access to admin routes
- **ValidateRequest**: Input validation middleware
- **CORS**: Cross-origin resource sharing configuration

#### 4. Services
- **UserService**: Business logic for user management
- **PlanService**: Business logic for plan management
- **SubscriptionService**: Subscription lifecycle management
- **NotificationService**: Email notification handling

## Data Models

### User Model
```
User {
  id: integer (primary key)
  name: string
  email: string (unique)
  phone: string
  password: string (hashed)
  role: enum ['admin', 'user']
  status: enum ['active', 'inactive']
  email_verified_at: timestamp (nullable)
  created_at: timestamp
  updated_at: timestamp
  
  relationships:
    - hasMany: Subscriptions
    - hasMany: ActivityLogs
    - belongsToMany: Organizations (through organization_user pivot)
}
```

### Organization Model
```
Organization {
  id: integer (primary key)
  name: string
  gst_no: string (nullable)
  billing_address: text (nullable)
  mobile_no: string
  email: string
  created_by: integer (foreign key to users)
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
  
  relationships:
    - belongsTo: User (creator)
    - belongsToMany: Users (through organization_user pivot with role)
}
```

### OrganizationUser Pivot Model
```
OrganizationUser {
  id: integer (primary key)
  organization_id: integer (foreign key)
  user_id: integer (foreign key)
  role: enum ['owner', 'admin', 'member']
  created_at: timestamp
  updated_at: timestamp
  
  unique constraint: (organization_id, user_id)
}
```

### Plan Model
```
Plan {
  id: integer (primary key)
  name: string (unique)
  description: text
  price_monthly: decimal(10,2)
  price_yearly: decimal(10,2)
  features: json
  is_active: boolean
  created_at: timestamp
  updated_at: timestamp
  
  relationships:
    - hasMany: Subscriptions
}
```

### Subscription Model
```
Subscription {
  id: integer (primary key)
  user_id: integer (foreign key)
  plan_id: integer (foreign key)
  billing_cycle: enum ['monthly', 'yearly']
  status: enum ['active', 'expired', 'cancelled']
  started_at: timestamp
  expires_at: timestamp
  created_at: timestamp
  updated_at: timestamp
  
  relationships:
    - belongsTo: User
    - belongsTo: Plan
}
```

### ActivityLog Model
```
ActivityLog {
  id: integer (primary key)
  admin_id: integer (foreign key)
  action: string
  entity_type: string
  entity_id: integer
  details: json
  created_at: timestamp
  
  relationships:
    - belongsTo: User (admin)
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### User Management Properties

Property 1: User creation preserves data
*For any* valid user data submitted by an admin, creating a user account should result in a user record with exactly that information stored in the database.
**Validates: Requirements 1.1**

Property 2: Email uniqueness enforcement
*For any* existing user email, attempting to create a new user with that email should be rejected with an appropriate error message.
**Validates: Requirements 1.2**

Property 3: New users default to inactive
*For any* newly created user account, the initial status should be set to inactive regardless of other provided data.
**Validates: Requirements 1.3**

Property 4: User creation triggers welcome email
*For any* user account creation, the system should send a welcome email notification to the user's email address.
**Validates: Requirements 1.4**

Property 5: User creation validates required fields
*For any* user data missing required fields or containing invalid formats, the creation attempt should be rejected with specific validation errors.
**Validates: Requirements 1.5**

### Account Status Management Properties

Property 6: Activation grants access
*For any* inactive user account, when an admin activates it, the account status should change to active and the user should gain access to their subscribed services.
**Validates: Requirements 2.1**

Property 7: Deactivation revokes access
*For any* active user account, when an admin deactivates it, the account status should change to inactive and all service access should be revoked.
**Validates: Requirements 2.2**

Property 8: Status changes are logged
*For any* user account status change, the system should create an activity log entry containing the timestamp, admin identifier, and status change details.
**Validates: Requirements 2.3**

Property 9: Status changes require admin permission
*For any* non-admin user attempting to change account status, the operation should be rejected with an authorization error.
**Validates: Requirements 2.4**

Property 10: Deactivation triggers notification
*For any* user account deactivation, the system should send an email notification to the user informing them of the status change.
**Validates: Requirements 2.5**

### Subscription Plan Management Properties

Property 11: Plan creation preserves all fields
*For any* valid plan data (name, description, prices, billing cycle, features), creating a plan should result in a plan record with all fields stored correctly.
**Validates: Requirements 3.1**

Property 12: Billing cycle validation
*For any* plan creation or update with a billing cycle value other than "monthly" or "yearly", the operation should be rejected with a validation error.
**Validates: Requirements 3.2**

Property 13: Plan updates preserve existing subscriptions
*For any* subscription plan with active subscriptions, updating the plan details should not invalidate or modify the existing user subscriptions.
**Validates: Requirements 3.3**

Property 14: Plan name uniqueness
*For any* existing plan name, attempting to create a new plan with that name should be rejected with an appropriate error message.
**Validates: Requirements 3.4**

Property 15: Price validation
*For any* plan with a negative or non-numeric price value, the creation or update should be rejected with a validation error.
**Validates: Requirements 3.5**

### Plan CRUD Properties

Property 16: Plan listing completeness
*For any* set of created plans, requesting the plan list should return all plans with their complete details (name, description, prices, features, status).
**Validates: Requirements 4.1**

Property 17: Plan updates persist changes
*For any* plan update operation, the changes should be saved to the database and the updated_at timestamp should be refreshed.
**Validates: Requirements 4.2**

Property 18: Plan deletion protection
*For any* subscription plan with one or more active subscriptions, attempting to delete the plan should be rejected with an error indicating active subscriptions exist.
**Validates: Requirements 4.3**

Property 19: Plan ID uniqueness
*For any* set of created plans, each plan should have a unique identifier that differs from all other plans.
**Validates: Requirements 4.4**

Property 20: CRUD operations are logged
*For any* plan CRUD operation performed by an admin, the system should create an activity log entry with the operation type, admin identifier, and timestamp.
**Validates: Requirements 4.5**

### Authentication Properties

Property 21: Authentication validates credentials and determines role
*For any* submitted login credentials, the system should verify them against the database and return the user's role (admin or user) on success.
**Validates: Requirements 5.1**

Property 22: Failed authentication doesn't leak information
*For any* failed login attempt (wrong email or wrong password), the error message should not reveal which credential was incorrect.
**Validates: Requirements 5.4**

Property 23: Successful login creates secure token
*For any* successful login, the system should generate a unique session token with an expiration time and return it to the client.
**Validates: Requirements 5.5**

### User Profile Properties

Property 24: Profile displays complete information
*For any* user accessing their profile, the system should display all account information including email, name, and current subscription status.
**Validates: Requirements 6.1**

Property 25: Profile updates are validated and saved
*For any* valid profile update data, the changes should be validated and persisted to the database.
**Validates: Requirements 6.2**

Property 26: Email change validates uniqueness
*For any* profile update attempting to change email to an address already in use, the operation should be rejected with an appropriate error.
**Validates: Requirements 6.3**

Property 27: Password change requires verification
*For any* password change attempt without correct current password verification, the operation should be rejected.
**Validates: Requirements 6.4**

Property 28: Sensitive data is hashed
*For any* profile update containing password changes, the new password should be hashed before storage, not stored in plaintext.
**Validates: Requirements 6.5**

### Plan Viewing and Subscription Properties

Property 29: Active plans are displayed
*For any* user accessing the plans page, the system should display all plans marked as active with their pricing and features, excluding inactive plans.
**Validates: Requirements 7.1**

Property 30: Both pricing options shown
*For any* displayed subscription plan, both monthly and yearly pricing should be visible to the user.
**Validates: Requirements 7.2**

Property 31: Current plan is highlighted
*For any* user with an active subscription viewing the plans page, their current plan should be visually distinguished from other plans.
**Validates: Requirements 7.3**

Property 32: Unauthenticated users can view plans
*For any* unauthenticated user accessing the plans page, the plans should be displayed, but subscription actions should require authentication.
**Validates: Requirements 7.5**

Property 33: Subscription initiation preserves plan details
*For any* plan selected for subscription, the subscription process should be initiated with the correct plan identifier and pricing information.
**Validates: Requirements 8.1**

Property 34: Payment completion activates subscription
*For any* completed payment for a subscription, the system should create an active subscription record and update the user's account status to active.
**Validates: Requirements 8.2**

Property 35: Expiration date calculation
*For any* created subscription, the expiration date should be calculated correctly based on the billing cycle (30 days for monthly, 365 days for yearly from start date).
**Validates: Requirements 8.3**

Property 36: Subscription modifications allowed
*For any* user with an active subscription, the system should allow them to upgrade or downgrade to a different plan.
**Validates: Requirements 8.4**

Property 37: Subscription activation sends confirmation
*For any* activated subscription, the system should send a confirmation email to the user with subscription details.
**Validates: Requirements 8.5**

### Backend API Properties

Property 38: API validates requests
*For any* API request received by the backend, the system should validate the request format and authentication token before processing.
**Validates: Requirements 9.1**

Property 39: API returns appropriate error responses
*For any* error encountered during API processing, the system should return an HTTP status code matching the error type and a descriptive error message.
**Validates: Requirements 9.3**

Property 40: Passwords are hashed with bcrypt
*For any* password stored by the backend, the system should hash it using bcrypt algorithm before database storage.
**Validates: Requirements 9.5**

### Frontend Client Properties

Property 41: API calls include authentication
*For any* authenticated API request from the Flutter frontend, the request headers should include the user's authentication token.
**Validates: Requirements 10.1**

Property 42: API responses are parsed correctly
*For any* API response received by the Flutter frontend, the JSON data should be parsed and the UI should update to reflect the data.
**Validates: Requirements 10.2**

Property 43: Network errors display user-friendly messages
*For any* network error encountered by the Flutter frontend, the system should display a user-friendly error message rather than technical details.
**Validates: Requirements 10.3**

Property 44: Sensitive data uses secure storage
*For any* sensitive data (tokens, credentials) stored by the Flutter frontend, the system should use platform-specific secure storage mechanisms.
**Validates: Requirements 10.5**

### Validation Properties

Property 45: Input validation before processing
*For any* user input received by the system, data types, formats, and constraints should be validated before any processing occurs.
**Validates: Requirements 11.1**

Property 46: Email format validation
*For any* email address submitted to the system, it should be validated against standard email format rules and rejected if invalid.
**Validates: Requirements 11.2**

Property 47: Password complexity enforcement
*For any* password submitted during registration or password change, the system should enforce minimum length and complexity requirements.
**Validates: Requirements 11.3**

Property 48: Numeric input validation
*For any* numeric input field, the system should reject non-numeric values and values outside the acceptable range with appropriate errors.
**Validates: Requirements 11.4**

Property 49: Validation errors are specific
*For any* validation failure, the error response should identify which specific fields failed validation and why.
**Validates: Requirements 11.5**

### Session Management Properties

Property 50: Login generates unique tokens
*For any* successful login, the system should generate a unique session token that differs from all other active tokens.
**Validates: Requirements 12.1**

Property 51: Expired tokens require re-authentication
*For any* API request with an expired session token, the system should reject the request and require the user to re-authenticate.
**Validates: Requirements 12.2**

Property 52: Logout invalidates tokens
*For any* logout operation, the session token should be immediately invalidated and subsequent requests with that token should be rejected.
**Validates: Requirements 12.3**

Property 53: Suspicious activity terminates session
*For any* detected suspicious activity pattern, the system should terminate the user's session and require re-authentication.
**Validates: Requirements 12.4**

Property 54: Multiple sessions are tracked
*For any* user with multiple active sessions, the system should track all sessions and allow the user to view and manage them.
**Validates: Requirements 12.5**

### Organization Management Properties

Property 55: Organization creation preserves data and assigns owner
*For any* valid organization data submitted by a user, creating an organization should result in an organization record with that information and the user assigned as owner.
**Validates: Requirements 13.1, 13.2**

Property 56: Organization creation validates required fields
*For any* organization data missing required fields (name, mobile_no, email), the creation attempt should be rejected with specific validation errors.
**Validates: Requirements 13.3, 13.4**

Property 57: New organizations default to active
*For any* newly created organization, the initial status should be set to active regardless of other provided data.
**Validates: Requirements 13.5**

Property 58: Organization updates require owner permission
*For any* non-owner user attempting to update organization details, the operation should be rejected with an authorization error.
**Validates: Requirements 14.3**

Property 59: Organization updates persist changes
*For any* organization update by the owner, the changes should be saved to the database and the updated_at timestamp should be refreshed.
**Validates: Requirements 14.2, 14.4**

Property 60: Email validation on organization update
*For any* organization update with an invalid email format, the operation should be rejected with a validation error.
**Validates: Requirements 14.5**

Property 61: Organization deletion requires owner permission
*For any* non-owner user attempting to delete an organization, the operation should be rejected with an authorization error.
**Validates: Requirements 15.2, 15.5**

Property 62: Organization deletion cascades relationships
*For any* organization deletion, all user-organization relationships should be removed while maintaining the user accounts.
**Validates: Requirements 15.1, 15.3, 15.4**

Property 63: User organizations list completeness
*For any* user requesting their organizations, the system should return all organizations where the user is a member with complete details.
**Validates: Requirements 16.1, 16.2, 16.4**

Property 64: Empty organizations list handled gracefully
*For any* user with no organization memberships, requesting organizations should return an empty list without errors.
**Validates: Requirements 16.3**

Property 65: Organization role indication
*For any* organization in a user's list, the system should clearly indicate whether the user is an owner or member.
**Validates: Requirements 16.5**

### User Registration Properties

Property 66: Registration creates user with all fields
*For any* valid registration data (name, email, phone, password), the system should create a user account with all fields stored correctly and password hashed.
**Validates: Requirements 17.1**

Property 67: Registration enforces email uniqueness
*For any* registration attempt with an existing email address, the operation should be rejected with an appropriate error message.
**Validates: Requirements 17.2**

Property 68: Registration validates all fields
*For any* registration data, the system should validate email format, phone format, and password complexity before creating the account.
**Validates: Requirements 17.3**

Property 69: Registration assigns default role and status
*For any* successful registration, the new user should be assigned the 'user' role and 'inactive' status by default.
**Validates: Requirements 17.4**

Property 70: Registration redirects to login
*For any* successful registration, the system should redirect to the login screen with a success message.
**Validates: Requirements 17.5**

### Organization Selection Properties

Property 71: First login with no organizations redirects to creation
*For any* user logging in for the first time with no organizations, the system should redirect to the organization creation screen.
**Validates: Requirements 18.1**

Property 72: Single organization auto-selection
*For any* user logging in with exactly one organization, the system should automatically select that organization and redirect to the dashboard.
**Validates: Requirements 18.2**

Property 73: Multiple organizations show selection screen
*For any* user logging in with multiple organizations, the system should display an organization selection screen.
**Validates: Requirements 18.3**

Property 74: Organization selection persists
*For any* organization selection by a user, the system should store the selection and redirect to the appropriate dashboard.
**Validates: Requirements 18.4**

Property 75: Organization selection grants access
*For any* completed organization selection or creation, the system should grant the user access to platform features.
**Validates: Requirements 18.5**

## Error Handling

### Frontend Error Handling

**Network Errors:**
- Connection timeout: Display "Unable to connect. Please check your internet connection."
- Server unreachable: Display "Service temporarily unavailable. Please try again later."
- Request timeout: Display "Request timed out. Please try again."

**Validation Errors:**
- Display inline error messages below form fields
- Highlight invalid fields with red border
- Show summary of errors at top of form for multiple errors

**Authentication Errors:**
- Invalid credentials: "Invalid email or password"
- Expired session: Redirect to login with message "Your session has expired. Please log in again."
- Insufficient permissions: "You don't have permission to perform this action"

**API Errors:**
- 400 Bad Request: Display specific validation errors from response
- 401 Unauthorized: Redirect to login
- 403 Forbidden: Display "Access denied" message
- 404 Not Found: Display "Resource not found"
- 500 Server Error: Display "An error occurred. Please try again later."

### Backend Error Handling

**Validation Errors:**
- Return 422 Unprocessable Entity with detailed field errors
- Use Laravel's validation system for consistent error format
- Example response:
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email has already been taken."],
    "password": ["The password must be at least 8 characters."]
  }
}
```

**Authentication Errors:**
- Return 401 Unauthorized for invalid credentials
- Return 403 Forbidden for insufficient permissions
- Include generic error messages to prevent information leakage

**Database Errors:**
- Catch and log database exceptions
- Return 500 Internal Server Error with generic message
- Log detailed error information for debugging

**Business Logic Errors:**
- Return appropriate status codes (400, 409, etc.)
- Include descriptive error messages
- Example: "Cannot delete plan with active subscriptions"

## Testing Strategy

### Unit Testing

**Backend (Laravel - PHPUnit):**
- Test individual model methods and relationships
- Test controller actions with mocked dependencies
- Test validation rules and custom validators
- Test service layer business logic
- Test authentication and authorization logic
- Coverage target: 80%+ for critical paths

**Frontend (Flutter - flutter_test):**
- Test widget rendering and interactions
- Test state management logic
- Test API client methods with mocked responses
- Test form validation logic
- Test navigation flows
- Coverage target: 70%+ for business logic

### Property-Based Testing

**Backend (Laravel - Pest with Faker):**
- Use Pest testing framework with Faker for property-based tests
- Configure each property test to run minimum 100 iterations
- Tag each test with format: `// Feature: flutter-saas-billing, Property X: [property text]`
- Focus on testing universal properties across random valid inputs

**Frontend (Flutter - faker package):**
- Use faker package to generate random test data
- Run property tests with minimum 100 iterations
- Test UI components with various random data inputs
- Verify properties hold across different screen sizes and platforms

**Key Property Tests to Implement:**
- User creation with random valid data preserves all fields
- Email uniqueness across random email generation
- Status changes maintain audit trail
- Plan CRUD operations maintain data integrity
- Authentication tokens are unique across multiple logins
- Validation rejects all forms of invalid input
- Session management handles concurrent sessions correctly

### Integration Testing

**API Integration Tests:**
- Test complete API workflows (register → login → subscribe)
- Test admin workflows (create user → assign plan → activate)
- Test error scenarios and edge cases
- Use Laravel's HTTP testing features

**End-to-End Testing:**
- Test critical user journeys through the Flutter app
- Test admin workflows from UI to database
- Use Flutter integration testing framework
- Test on multiple platforms (web, iOS, Android)

### Manual Testing Checklist

**UI/UX Testing:**
- Verify design matches reference screenshot
- Test responsive behavior on different screen sizes
- Verify color scheme and typography consistency
- Test dark sidebar navigation and interactions
- Verify card layouts and spacing

**Cross-Platform Testing:**
- Test on web browsers (Chrome, Firefox, Safari)
- Test on iOS devices/simulator
- Test on Android devices/emulator
- Verify platform-specific behaviors

**Security Testing:**
- Verify passwords are hashed in database
- Test session expiration and token invalidation
- Verify authorization checks on all protected routes
- Test for SQL injection vulnerabilities
- Test for XSS vulnerabilities

## API Endpoints

### Authentication Endpoints

```
POST /api/auth/register
Request: { name, email, phone, password, password_confirmation }
Response: { message }

POST /api/auth/login
Request: { email, password }
Response: { token, user: { id, name, email, phone, role }, expires_at }

POST /api/auth/logout
Headers: Authorization: Bearer {token}
Response: { message }

POST /api/auth/refresh
Headers: Authorization: Bearer {token}
Response: { token, expires_at }
```

### Organization Endpoints

```
GET /api/organizations
Headers: Authorization: Bearer {token}
Response: { data: [organizations with creator and role info] }

POST /api/organizations
Headers: Authorization: Bearer {token}
Request: { name, gst_no?, billing_address?, mobile_no, email }
Response: { organization, message }

GET /api/organizations/{id}
Headers: Authorization: Bearer {token}
Response: { organization }

PUT /api/organizations/{id}
Headers: Authorization: Bearer {token}
Request: { name?, gst_no?, billing_address?, mobile_no?, email? }
Response: { organization, message }

DELETE /api/organizations/{id}
Headers: Authorization: Bearer {token}
Response: { message }
```

### Admin - User Management Endpoints

```
GET /api/admin/users
Headers: Authorization: Bearer {token}
Query: ?page=1&per_page=20&search=&status=
Response: { data: [users], meta: { pagination } }

POST /api/admin/users
Headers: Authorization: Bearer {token}
Request: { name, email, password, role }
Response: { user, message }

PUT /api/admin/users/{id}
Headers: Authorization: Bearer {token}
Request: { name, email, role }
Response: { user, message }

PATCH /api/admin/users/{id}/status
Headers: Authorization: Bearer {token}
Request: { status: 'active' | 'inactive' }
Response: { user, message }

DELETE /api/admin/users/{id}
Headers: Authorization: Bearer {token}
Response: { message }
```

### Admin - Plan Management Endpoints

```
GET /api/admin/plans
Headers: Authorization: Bearer {token}
Response: { data: [plans] }

POST /api/admin/plans
Headers: Authorization: Bearer {token}
Request: { name, description, price_monthly, price_yearly, features: [] }
Response: { plan, message }

PUT /api/admin/plans/{id}
Headers: Authorization: Bearer {token}
Request: { name, description, price_monthly, price_yearly, features: [] }
Response: { plan, message }

DELETE /api/admin/plans/{id}
Headers: Authorization: Bearer {token}
Response: { message }

GET /api/admin/activity-logs
Headers: Authorization: Bearer {token}
Query: ?page=1&per_page=20
Response: { data: [logs], meta: { pagination } }
```

### User - Profile Endpoints

```
GET /api/user/profile
Headers: Authorization: Bearer {token}
Response: { user: { id, name, email, status, subscription } }

PUT /api/user/profile
Headers: Authorization: Bearer {token}
Request: { name, email }
Response: { user, message }

PUT /api/user/profile/password
Headers: Authorization: Bearer {token}
Request: { current_password, new_password, new_password_confirmation }
Response: { message }
```

### User - Plans and Subscriptions Endpoints

```
GET /api/plans
Response: { data: [plans] }

GET /api/user/subscription
Headers: Authorization: Bearer {token}
Response: { subscription: { plan, status, started_at, expires_at } }

POST /api/user/subscribe
Headers: Authorization: Bearer {token}
Request: { plan_id, billing_cycle: 'monthly' | 'yearly' }
Response: { subscription, message }

PUT /api/user/subscription/change-plan
Headers: Authorization: Bearer {token}
Request: { plan_id }
Response: { subscription, message }

DELETE /api/user/subscription/cancel
Headers: Authorization: Bearer {token}
Response: { message }
```

## Database Schema

### Users Table
```sql
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    status ENUM('active', 'inactive') DEFAULT 'inactive',
    email_verified_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_status (status)
);
```

### Organizations Table
```sql
CREATE TABLE organizations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    gst_no VARCHAR(50) NULL,
    billing_address TEXT NULL,
    mobile_no VARCHAR(20) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created_by BIGINT UNSIGNED NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_created_by (created_by),
    INDEX idx_is_active (is_active)
);
```

### Organization User Pivot Table
```sql
CREATE TABLE organization_user (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    organization_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    role ENUM('owner', 'admin', 'member') DEFAULT 'member',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE KEY unique_org_user (organization_id, user_id),
    INDEX idx_organization_id (organization_id),
    INDEX idx_user_id (user_id)
);
```

### Plans Table
```sql
CREATE TABLE plans (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    price_monthly DECIMAL(10,2) NOT NULL,
    price_yearly DECIMAL(10,2) NOT NULL,
    features JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_is_active (is_active)
);
```

### Subscriptions Table
```sql
CREATE TABLE subscriptions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    plan_id BIGINT UNSIGNED NOT NULL,
    billing_cycle ENUM('monthly', 'yearly') NOT NULL,
    status ENUM('active', 'expired', 'cancelled') DEFAULT 'active',
    started_at TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES plans(id) ON DELETE RESTRICT,
    INDEX idx_user_id (user_id),
    INDEX idx_plan_id (plan_id),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at)
);
```

### Activity Logs Table
```sql
CREATE TABLE activity_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    admin_id BIGINT UNSIGNED NOT NULL,
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(255) NOT NULL,
    entity_id BIGINT UNSIGNED,
    details JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_admin_id (admin_id),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at)
);
```

### Personal Access Tokens Table (Laravel Sanctum)
```sql
CREATE TABLE personal_access_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    token VARCHAR(64) UNIQUE NOT NULL,
    abilities TEXT,
    last_used_at TIMESTAMP NULL,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_tokenable (tokenable_type, tokenable_id),
    INDEX idx_token (token)
);
```

## Deployment Considerations

### Backend Deployment
- Use PHP 8.1+ with required extensions (mbstring, pdo_mysql, etc.)
- Configure environment variables (.env file)
- Run database migrations
- Set up queue workers for email notifications
- Configure CORS for Flutter web app
- Enable HTTPS/SSL certificates
- Set up logging and monitoring

### Frontend Deployment
- **Web**: Build with `flutter build web` and deploy to hosting (Netlify, Vercel, etc.)
- **iOS**: Build with `flutter build ios` and deploy via App Store
- **Android**: Build with `flutter build apk/appbundle` and deploy via Play Store
- Configure API base URL for each environment
- Set up analytics and crash reporting

### Environment Variables
```
# Laravel Backend
APP_ENV=production
APP_DEBUG=false
APP_URL=https://api.yourdomain.com
DB_HOST=localhost
DB_DATABASE=saas_billing
DB_USERNAME=dbuser
DB_PASSWORD=securepassword
SANCTUM_STATEFUL_DOMAINS=yourdomain.com
SESSION_LIFETIME=120
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525

# Flutter Frontend
API_BASE_URL=https://api.yourdomain.com
```

## Security Considerations

1. **Authentication**: Use Laravel Sanctum for API token management with appropriate expiration times
2. **Password Hashing**: Use bcrypt with cost factor 10+ for password hashing
3. **Input Validation**: Validate and sanitize all user inputs on both frontend and backend
4. **SQL Injection**: Use Eloquent ORM and parameterized queries exclusively
5. **XSS Protection**: Sanitize output and use Content Security Policy headers
6. **CSRF Protection**: Enable CSRF protection for state-changing operations
7. **Rate Limiting**: Implement rate limiting on authentication and API endpoints
8. **HTTPS**: Enforce HTTPS for all API communication
9. **Secure Storage**: Use Flutter Secure Storage for sensitive data on mobile
10. **Session Management**: Implement proper session timeout and token rotation
