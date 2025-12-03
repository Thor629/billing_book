# Implementation Plan

- [ ] 1. Set up Laravel backend project structure
  - Initialize Laravel 10.x project with required dependencies
  - Configure database connection and environment variables
  - Install Laravel Sanctum for API authentication
  - Set up CORS configuration for Flutter frontend
  - _Requirements: 9.1, 9.4_

- [ ] 2. Create database migrations and models
  - Create users table migration with role and status fields
  - Create plans table migration with pricing and features
  - Create subscriptions table migration with relationships
  - Create activity_logs table migration for audit trail
  - Create Eloquent models with relationships and casts
  - _Requirements: 1.1, 3.1, 8.2, 2.3_

- [ ] 3. Implement authentication system
  - Create AuthController with login and logout methods
  - Implement credential validation and role detection
  - Generate secure tokens with expiration using Sanctum
  - Create authentication middleware for protected routes
  - Implement token refresh endpoint
  - _Requirements: 5.1, 5.4, 5.5, 12.1_

- [ ]* 3.1 Write property test for authentication
  - **Property 21: Authentication validates credentials and determines role**
  - **Property 23: Successful login creates secure token**
  - **Validates: Requirements 5.1, 5.5**

- [ ]* 3.2 Write property test for failed authentication
  - **Property 22: Failed authentication doesn't leak information**
  - **Validates: Requirements 5.4**

- [ ] 4. Implement admin user management endpoints
  - Create UserController with CRUD operations
  - Implement user creation with validation and default inactive status
  - Add email uniqueness validation
  - Implement user status activation/deactivation endpoint
  - Create AdminOnly middleware for authorization
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.4_

- [ ]* 4.1 Write property test for user creation
  - **Property 1: User creation preserves data**
  - **Property 3: New users default to inactive**
  - **Property 5: User creation validates required fields**
  - **Validates: Requirements 1.1, 1.3, 1.5**

- [ ]* 4.2 Write property test for email uniqueness
  - **Property 2: Email uniqueness enforcement**
  - **Validates: Requirements 1.2**

- [ ]* 4.3 Write property test for account status management
  - **Property 6: Activation grants access**
  - **Property 7: Deactivation revokes access**
  - **Property 9: Status changes require admin permission**
  - **Validates: Requirements 2.1, 2.2, 2.4**

- [ ] 5. Implement activity logging system
  - Create ActivityLog model and service
  - Add logging to user status changes
  - Add logging to plan CRUD operations
  - Store admin identifier and timestamp with each log
  - Create endpoint to retrieve activity logs
  - _Requirements: 2.3, 4.5_

- [ ]* 5.1 Write property test for activity logging
  - **Property 8: Status changes are logged**
  - **Property 20: CRUD operations are logged**
  - **Validates: Requirements 2.3, 4.5**

- [ ] 6. Implement notification service
  - Set up Laravel Mail configuration
  - Create welcome email template
  - Create account status change email template
  - Create subscription confirmation email template
  - Implement NotificationService to send emails
  - Add email sending to user creation, status changes, and subscriptions
  - _Requirements: 1.4, 2.5, 8.5_

- [ ]* 6.1 Write property test for email notifications
  - **Property 4: User creation triggers welcome email**
  - **Property 10: Deactivation triggers notification**
  - **Property 37: Subscription activation sends confirmation**
  - **Validates: Requirements 1.4, 2.5, 8.5**

- [ ] 7. Implement subscription plan management
  - Create PlanController with CRUD operations
  - Implement plan creation with validation (name, prices, billing cycle)
  - Add plan name uniqueness validation
  - Add price validation (positive numeric values)
  - Implement plan update with subscription preservation check
  - Implement plan deletion with active subscription check
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 4.1, 4.2, 4.3, 4.4_

- [ ]* 7.1 Write property test for plan creation
  - **Property 11: Plan creation preserves all fields**
  - **Property 14: Plan name uniqueness**
  - **Property 15: Price validation**
  - **Property 19: Plan ID uniqueness**
  - **Validates: Requirements 3.1, 3.4, 3.5, 4.4**

- [ ]* 7.2 Write property test for billing cycle validation
  - **Property 12: Billing cycle validation**
  - **Validates: Requirements 3.2**

- [ ]* 7.3 Write property test for plan updates and deletion
  - **Property 13: Plan updates preserve existing subscriptions**
  - **Property 16: Plan listing completeness**
  - **Property 17: Plan updates persist changes**
  - **Property 18: Plan deletion protection**
  - **Validates: Requirements 3.3, 4.1, 4.2, 4.3**

- [ ] 8. Implement user profile management
  - Create ProfileController for user profile operations
  - Implement profile retrieval endpoint with subscription status
  - Implement profile update with validation
  - Add email uniqueness check for email updates
  - Implement password change with current password verification
  - Ensure password hashing with bcrypt
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 9.5_

- [ ]* 8.1 Write property test for profile management
  - **Property 24: Profile displays complete information**
  - **Property 25: Profile updates are validated and saved**
  - **Property 26: Email change validates uniqueness**
  - **Property 27: Password change requires verification**
  - **Property 28: Sensitive data is hashed**
  - **Property 40: Passwords are hashed with bcrypt**
  - **Validates: Requirements 6.1, 6.2, 6.3, 6.4, 6.5, 9.5**

- [ ] 9. Implement subscription management
  - Create SubscriptionController for subscription operations
  - Implement public plans listing endpoint (active plans only)
  - Implement subscription creation with expiration calculation
  - Add subscription status update on payment completion
  - Implement plan upgrade/downgrade functionality
  - Implement subscription cancellation
  - Update user account status when subscription is activated
  - _Requirements: 7.1, 7.2, 7.5, 8.1, 8.2, 8.3, 8.4_

- [ ]* 9.1 Write property test for plan viewing
  - **Property 29: Active plans are displayed**
  - **Property 30: Both pricing options shown**
  - **Property 32: Unauthenticated users can view plans**
  - **Validates: Requirements 7.1, 7.2, 7.5**

- [ ]* 9.2 Write property test for subscription operations
  - **Property 33: Subscription initiation preserves plan details**
  - **Property 34: Payment completion activates subscription**
  - **Property 35: Expiration date calculation**
  - **Property 36: Subscription modifications allowed**
  - **Validates: Requirements 8.1, 8.2, 8.3, 8.4**

- [ ] 10. Implement comprehensive input validation
  - Create custom validation rules for email format
  - Create password complexity validation rules
  - Add numeric input validation with range checks
  - Implement detailed validation error responses
  - Add validation to all controller methods
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ]* 10.1 Write property test for input validation
  - **Property 45: Input validation before processing**
  - **Property 46: Email format validation**
  - **Property 47: Password complexity enforcement**
  - **Property 48: Numeric input validation**
  - **Property 49: Validation errors are specific**
  - **Validates: Requirements 11.1, 11.2, 11.3, 11.4, 11.5**

- [ ] 11. Implement session management features
  - Configure token expiration in Sanctum
  - Implement token expiration checking middleware
  - Implement logout with token invalidation
  - Add suspicious activity detection (optional advanced feature)
  - Implement multi-session tracking
  - Create session management endpoints
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ]* 11.1 Write property test for session management
  - **Property 50: Login generates unique tokens**
  - **Property 51: Expired tokens require re-authentication**
  - **Property 52: Logout invalidates tokens**
  - **Property 54: Multiple sessions are tracked**
  - **Validates: Requirements 12.1, 12.2, 12.3, 12.5**

- [ ] 12. Implement API error handling
  - Create global exception handler
  - Implement validation error responses (422)
  - Implement authentication error responses (401, 403)
  - Implement not found error responses (404)
  - Implement server error responses (500)
  - Add error logging for debugging
  - _Requirements: 9.3_

- [ ]* 12.1 Write property test for error handling
  - **Property 38: API validates requests**
  - **Property 39: API returns appropriate error responses**
  - **Validates: Requirements 9.1, 9.3**

- [ ] 13. Create database seeders for testing
  - Create admin user seeder
  - Create sample plans seeder (Basic, Pro, Enterprise)
  - Create sample users seeder
  - Create sample subscriptions seeder
  - Run seeders for development environment
  - _Requirements: All_

- [ ] 14. Implement user registration endpoint
  - Add registration route to AuthController
  - Implement validation for name, email, phone, password
  - Enforce email uniqueness validation
  - Enforce password complexity requirements
  - Hash password with bcrypt before storage
  - Assign default 'user' role and 'inactive' status
  - Return success message for redirect to login
  - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

- [ ]* 14.1 Write property test for user registration
  - **Property 66: Registration creates user with all fields**
  - **Property 67: Registration enforces email uniqueness**
  - **Property 68: Registration validates all fields**
  - **Property 69: Registration assigns default role and status**
  - **Validates: Requirements 17.1, 17.2, 17.3, 17.4**

- [ ] 15. Implement organization management backend
  - Create Organization model with relationships
  - Create organization_user pivot table migration
  - Create OrganizationController with CRUD operations
  - Implement organization creation with owner assignment
  - Add validation for required fields (name, mobile_no, email)
  - Implement owner-only update and delete authorization
  - Implement user organizations listing endpoint
  - Add cascade delete for organization relationships
  - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 14.1, 14.2, 14.3, 14.4, 14.5, 15.1, 15.2, 15.3, 15.4, 15.5, 16.1, 16.2, 16.3, 16.4, 16.5_

- [ ]* 15.1 Write property test for organization creation
  - **Property 55: Organization creation preserves data and assigns owner**
  - **Property 56: Organization creation validates required fields**
  - **Property 57: New organizations default to active**
  - **Validates: Requirements 13.1, 13.2, 13.3, 13.4, 13.5**

- [ ]* 15.2 Write property test for organization updates
  - **Property 58: Organization updates require owner permission**
  - **Property 59: Organization updates persist changes**
  - **Property 60: Email validation on organization update**
  - **Validates: Requirements 14.2, 14.3, 14.4, 14.5**

- [ ]* 15.3 Write property test for organization deletion
  - **Property 61: Organization deletion requires owner permission**
  - **Property 62: Organization deletion cascades relationships**
  - **Validates: Requirements 15.1, 15.2, 15.3, 15.4, 15.5**

- [ ]* 15.4 Write property test for organization listing
  - **Property 63: User organizations list completeness**
  - **Property 64: Empty organizations list handled gracefully**
  - **Property 65: Organization role indication**
  - **Validates: Requirements 16.1, 16.2, 16.3, 16.4, 16.5**

- [ ] 16. Checkpoint - Backend API complete
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 17. Set up Flutter project structure
  - Initialize Flutter project with web, iOS, and Android support
  - Set up folder structure (models, services, screens, widgets, providers)
  - Add required dependencies (http/dio, provider/riverpod, flutter_secure_storage, google_fonts)
  - Configure API base URL for different environments
  - _Requirements: 10.1, 10.2, 10.5_

- [ ] 18. Implement Flutter API client and authentication service
  - Create ApiClient class with HTTP client wrapper
  - Implement authentication token storage using Flutter Secure Storage
  - Add authentication token to all API request headers
  - Create AuthService for login, logout, registration, and token management
  - Implement role detection from API response
  - Create AuthProvider for state management
  - _Requirements: 10.1, 10.5, 5.1, 17.1_

- [ ]* 18.1 Write property test for API client
  - **Property 41: API calls include authentication**
  - **Property 44: Sensitive data uses secure storage**
  - **Validates: Requirements 10.1, 10.5**

- [ ] 19. Implement error handling and user feedback
  - Create ErrorHandler utility for centralized error handling
  - Implement network error detection and user-friendly messages
  - Create error display widgets (SnackBar, Dialog)
  - Add error handling to API client
  - Implement loading states with LoadingIndicator widget
  - _Requirements: 10.3_

- [ ]* 19.1 Write property test for error handling
  - **Property 42: API responses are parsed correctly**
  - **Property 43: Network errors display user-friendly messages**
  - **Validates: Requirements 10.2, 10.3**

- [ ] 20. Create design system and shared UI components
  - Define color palette constants matching design reference
  - Define typography styles using Google Fonts
  - Create MetricCard widget for dashboard metrics
  - Create DataTable widget with sorting and pagination
  - Create StatusBadge widget for status indicators
  - Create ActionButton widget for table actions
  - Create FormInput widget with validation
  - Create custom Button widgets with loading states
  - _Requirements: All UI requirements_

- [ ] 21. Implement user registration screen
  - Create RegisterScreen with form layout
  - Add input fields for name, email, phone, password, password confirmation
  - Implement form validation for all fields
  - Add email format validation
  - Add phone number format validation
  - Add password complexity validation
  - Implement registration API call through AuthService
  - Handle validation errors and display messages
  - Redirect to login screen on successful registration
  - Add "Already have an account? Login" link
  - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5_

- [ ]* 21.1 Write property test for registration validation
  - **Property 70: Registration redirects to login**
  - **Validates: Requirements 17.5**

- [ ] 22. Implement unified login screen
  - Create LoginScreen with centered form layout
  - Add email and password input fields with validation
  - Implement login button with loading state
  - Add form validation using FormValidators
  - Call AuthService on form submission
  - Handle authentication errors and display messages
  - Implement organization-aware navigation after successful login
  - Add "Don't have an account? Register" link
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 23. Implement organization models and services
  - Create OrganizationModel with fromJson and toJson methods
  - Create OrganizationService for API calls
  - Implement organization CRUD operations in service
  - Create OrganizationProvider for state management
  - Add organization selection state management
  - _Requirements: 13.1, 14.1, 15.1, 16.1_

- [ ] 24. Implement organ
  - Create AdminDashboard screen with metrics cards
  - Display total users, active subscriptions, and revenue metrics
  - Use color-coded MetricCard widgets (green, red, blue)
  - Create recent activity table showing user actions
  - Add quick action buttons for common tasks
  - Fetch dashboard data from API
  - _Requirements: Admin panel overview_

- [ ] 21. Implement admin navigation sidebar
  - Create AdminNavigationDrawer with dark theme
  - Add logo and business name at top
  - Create menu items with icons (Dashboard, Users, Plans, Reports, Settings)
  - Implement active state highlighting
  - Make sidebar collapsible on mobile
  - Implement navigation routing
  - _Requirements: Admin panel navigation_

- [ ] 22. Implement admin user management screen
  - Create UserManagementScreen with data table
  - Display columns: Name, Email, Status, Plan, Actions
  - Add search and filter functionality
  - Create "Add User" button and dialog/modal
  - Implement user creation form with validation
  - Add toggle switches for activate/deactivate
  - Add edit and delete action buttons
  - Implement user update and delete operations
  - _Requirements: 1.1, 1.2, 1.5, 2.1, 2.2_

- [ ] 23. Implement admin plan management screen
  - Create PlanManagementScreen with grid or list view
  - Display plan cards with name, prices, and features
  - Create "Add Plan" button and dialog/modal
  - Implement plan creation form with validation
  - Add monthly and yearly price inputs
  - Add features list input (dynamic list)
  - Implement plan edit and delete actions
  - Add active/inactive status toggle
  - _Requirements: 3.1, 3.2, 3.4, 3.5, 4.1, 4.2, 4.3_

- [ ] 24. Implement user dashboard
  - Create UserDashboard screen
  - Display current plan card with features
  - Show subscription expiry date
  - Add usage statistics if applicable
  - Create quick links to manage subscription
  - Fetch user subscription data from API
  - _Requirements: User panel overview_

- [ ] 25. Implement user navigation sidebar
  - Create UserNavigationDrawer with dark theme
  - Add logo and business name at top
  - Create menu items with icons (Dashboard, Profile, Plans, Subscription, Support)
  - Implement active state highlighting
  - Make sidebar collapsible on mobile
  - Implement navigation routing
  - _Requirements: User panel navigation_

- [ ] 26. Implement user profile screen
  - Create ProfileScreen with form layout
  - Display current profile information (name, email)
  - Create editable form fields with validation
  - Implement profile update functionality
  - Add password change section with current password verification
  - Add avatar/profile picture upload (optional)
  - Handle validation errors and success messages
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 27. Implement plans browsing screen
  - Create PlansScreen with card grid layout (3 columns on desktop)
  - Display all active plans from API
  - Show plan name, description, and features
  - Add price toggle for monthly/yearly view
  - Highlight user's current plan if subscribed
  - Add "Subscribe" button for each plan
  - Make layout responsive for mobile
  - Allow unauthenticated users to view plans
  - _Requirements: 7.1, 7.2, 7.3, 7.5_

- [ ]* 27.1 Write property test for plan highlighting
  - **Property 31: Current plan is highlighted**
  - **Validates: Requirements 7.3**

- [ ] 28. Implement subscription management screen
  - Create SubscriptionScreen for managing current subscription
  - Display current plan details and status
  - Show billing history table
  - Implement plan upgrade/downgrade functionality
  - Add subscription cancellation with confirmation dialog
  - Handle subscription state updates
  - _Requirements: 8.1, 8.4_

- [ ] 29. Implement subscription flow
  - Create subscription initiation from PlansScreen
  - Implement payment simulation (or integrate payment gateway)
  - Handle subscription activation on payment completion
  - Update user account status after subscription
  - Show confirmation message and email notification
  - Navigate to subscription screen after completion
  - _Requirements: 8.1, 8.2, 8.5_

- [ ] 30. Implement responsive design and platform adaptations
  - Test layouts on different screen sizes (mobile, tablet, desktop)
  - Adjust sidebar behavior for mobile (drawer vs permanent)
  - Make data tables responsive (convert to cards on mobile)
  - Test on web browser
  - Test on iOS simulator/device
  - Test on Android emulator/device
  - Fix any platform-specific issues
  - _Requirements: 10.4_

- [ ] 31. Implement form validation throughout the app
  - Create FormValidators utility with reusable validation functions
  - Add email format validation
  - Add password complexity validation (min length, complexity)
  - Add required field validation
  - Add numeric validation with range checks
  - Apply validation to all forms (login, user creation, plan creation, profile update)
  - Display inline validation errors
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 32. Implement session management in Flutter
  - Handle token expiration and automatic logout
  - Implement token refresh logic
  - Add logout functionality with token invalidation
  - Handle 401 responses by redirecting to login
  - Implement "session expired" messaging
  - _Requirements: 12.2, 12.3_

- [ ] 33. Polish UI to match design reference
  - Apply color palette throughout the app
  - Ensure typography consistency using defined styles
  - Add proper spacing and padding using spacing system
  - Apply border radius and shadows to cards and buttons
  - Implement hover states for interactive elements
  - Add smooth transitions (200ms duration)
  - Verify dark sidebar with white text
  - Verify light content area with card layouts
  - Test color-coded metrics (green, red, blue)
  - _Requirements: UI/UX design system_

- [ ] 34. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 35. Create README documentation
  - Document project setup instructions
  - Document API endpoints
  - Document environment variables
  - Document database setup and migrations
  - Document Flutter app setup and running
  - Add screenshots of the application
  - Document testing procedures
  - _Requirements: Documentation_
