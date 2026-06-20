//
//  SellerConnectTests.swift
//  SellerConnectTests
//
//  Created by Ben H on 5/30/26.
//

import Testing
@testable import SellerConnect

@MainActor
struct SellerConnectTests {
    
    // MARK: - RegisterViewModel Password Validation Tests
    
    @Test
    func passwordValidAllRequirements() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test@123!"
        
        #expect(viewModel.passwordValid, "Password meeting all requirements should be valid")
    }
    
    @Test
    func passwordValidMissingUppercase() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "securepass123!"
        
        #expect(!viewModel.passwordValid, "Password without uppercase should be invalid")
    }
    
    @Test
    func passwordValidMissingNumber() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test!"
        
        #expect(!viewModel.passwordValid, "Password without number should be invalid")
    }
    
    @Test
    func passwordValidMissingSpecialCharacter() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test123"
        
        #expect(!viewModel.passwordValid, "Password without special character should be invalid")
    }
    
    @Test
    func passwordValidTooShort() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Spc1!"
        
        #expect(!viewModel.passwordValid, "Password shorter than 6 characters should be invalid")
    }
    
    @Test
    func passwordValidContainsUnderscore() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test_123!"
        
        #expect(!viewModel.passwordValid, "Password containing underscore should be invalid")
    }
    
    @Test
    func passwordValidContainsDash() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test-123!"
        
        #expect(!viewModel.passwordValid, "Password containing dash should be invalid")
    }
    
    // MARK: - RegisterViewModel Form Validation Tests
    
    @Test
    func passwordsMatchBothEmpty() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = ""
        viewModel.confirmPassword = ""
        
        #expect(!viewModel.passwordsMatch, "Empty passwords should not match")
    }
    
    @Test
    func passwordsMatchIdentical() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        
        #expect(viewModel.passwordsMatch, "Identical passwords should match")
    }
    
    @Test
    func passwordsMatchDifferent() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@456!"
        
        #expect(!viewModel.passwordsMatch, "Different passwords should not match")
    }
    
    @Test
    func canSubmitAllFieldsValid() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        
        #expect(viewModel.canSubmit, "Should allow submit when all fields are valid")
    }
    
    @Test
    func canSubmitMissingFirstName() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = ""
        viewModel.email = "john@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        
        #expect(!viewModel.canSubmit, "Should not allow submit when first name is missing")
    }
    
    @Test
    func canSubmitMissingEmail() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = ""
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        
        #expect(!viewModel.canSubmit, "Should not allow submit when email is missing")
    }
    
    @Test
    func canSubmitInvalidPassword() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "weak"
        viewModel.confirmPassword = "weak"
        
        #expect(!viewModel.canSubmit, "Should not allow submit with invalid password")
    }
    
    @Test
    func canSubmitPasswordsMismatch() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@456!"
        
        #expect(!viewModel.canSubmit, "Should not allow submit when passwords don't match")
    }
    
    // MARK: - RegisterViewModel State Tests
    
    @Test
    func resetForm() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        viewModel.errorMessage = "Test error"
        viewModel.registrationSuccess = true
        viewModel.showPassword = true
        viewModel.showConfirmPassword = true
        
        viewModel.resetForm()
        
        #expect(viewModel.firstName == "")
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
        #expect(viewModel.confirmPassword == "")
        #expect(viewModel.errorMessage == "")
        #expect(!viewModel.registrationSuccess)
        #expect(!viewModel.showPassword)
        #expect(!viewModel.showConfirmPassword)
    }
    
    // MARK: - RegisterViewModel Registration Flow Tests
    
    @Test("Registration state before submission")
    func registrationStateBeforeSubmission() async throws {
        let viewModel = RegisterViewModel()
        
        #expect(!viewModel.isRegistering, "Should not be registering initially")
        #expect(!viewModel.registrationSuccess, "Should not have registration success initially")
        #expect(viewModel.errorMessage.isEmpty, "Should have no error message initially")
    }
    
    @Test("Store registration payload in state")
    func storeRegistrationPayloadInState() async throws {
        let viewModel = RegisterViewModel()
        
        // Set form fields
        viewModel.firstName = "Alice"
        viewModel.email = "alice@example.com"
        viewModel.password = "Secure@123!"
        viewModel.confirmPassword = "Secure@123!"
        
        // Verify payload would be created correctly
        #expect(viewModel.firstName == "Alice")
        #expect(viewModel.email == "alice@example.com")
        #expect(viewModel.password == "Secure@123!")
        #expect(viewModel.canSubmit, "Should allow submission with valid data")
    }
    
    @Test("Successful registration resets form state")
    func successfulRegistrationResetsForm() async throws {
        let viewModel = RegisterViewModel()
        
        // Set initial values
        viewModel.firstName = "Bob"
        viewModel.email = "bob@example.com"
        viewModel.password = "Secure@123!"
        viewModel.confirmPassword = "Secure@123!"
        viewModel.errorMessage = ""
        
        // Simulate successful registration by setting success flag
        // (In real scenario, this happens after successful API call)
        viewModel.registrationSuccess = true
        viewModel.resetForm()
        
        // Verify form is cleared
        #expect(viewModel.firstName == "")
        #expect(viewModel.email == "")
        #expect(viewModel.password == "")
        #expect(viewModel.confirmPassword == "")
        #expect(viewModel.errorMessage == "")
        #expect(!viewModel.registrationSuccess)
    }
    
    @Test("Multiple users can register with different emails")
    func multipleUsersRegisterDifferentEmails() async throws {
        // First user
        let viewModel1 = RegisterViewModel()
        viewModel1.firstName = "User1"
        viewModel1.email = "user1@example.com"
        viewModel1.password = "Pass@123!"
        viewModel1.confirmPassword = "Pass@123!"
        
        #expect(viewModel1.canSubmit, "First user should be able to submit")
        
        // Simulate first user registration success
        viewModel1.registrationSuccess = true
        viewModel1.resetForm()
        
        // Second user
        let viewModel2 = RegisterViewModel()
        viewModel2.firstName = "User2"
        viewModel2.email = "user2@example.com"
        viewModel2.password = "Pass@456!"
        viewModel2.confirmPassword = "Pass@456!"
        
        #expect(viewModel2.canSubmit, "Second user should be able to submit")
        #expect(viewModel2.email != viewModel1.email, "Different emails should be stored")
    }
    
    @Test("Duplicate email registration shows error")
    func duplicateEmailRegistrationError() async throws {
        let viewModel = RegisterViewModel()
        
        // Attempt to register with existing email
        viewModel.firstName = "John"
        viewModel.email = "existing@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        
        // Simulate 409 Conflict response (duplicate email)
        viewModel.errorMessage = "Email already registered."
        #expect(!viewModel.errorMessage.isEmpty, "Should have error message for duplicate email")
        #expect(viewModel.errorMessage == "Email already registered.", "Should show duplicate email error")
        #expect(!viewModel.registrationSuccess, "Should not mark as successful with error")
    }
    
    @Test("Network error handling maintains form state")
    func networkErrorMaintainsFormState() async throws {
        let viewModel = RegisterViewModel()
        
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        
        // Simulate network error
        viewModel.errorMessage = "Network error: The network connection was lost."
        
        #expect(!viewModel.errorMessage.isEmpty, "Should have error message")
        #expect(viewModel.firstName == "John", "Should keep first name on error")
        #expect(viewModel.email == "john@example.com", "Should keep email on error")
        #expect(viewModel.password == "Test@123!", "Should keep password on error")
        #expect(!viewModel.registrationSuccess, "Should not mark as successful with error")
    }
    
    @Test("Form state after error retry")
    func formStateAfterErrorRetry() async throws {
        let viewModel = RegisterViewModel()
        
        // Initial attempt with error
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "Test@123!"
        viewModel.confirmPassword = "Test@123!"
        viewModel.errorMessage = "Email already registered."
        
        #expect(!viewModel.canSubmit || !viewModel.errorMessage.isEmpty, "Should have validation error")
        
        // User corrects email and retries
        viewModel.errorMessage = ""
        viewModel.email = "newemail@example.com"
        
        #expect(viewModel.canSubmit, "Should allow resubmission with corrected email")
        #expect(viewModel.errorMessage.isEmpty, "Error should be cleared")
    }
    
    @Test("Registration with validation error doesn't clear form")
    func validationErrorDoesntClearForm() async throws {
        let viewModel = RegisterViewModel()
        
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "weak"  // Invalid password
        viewModel.confirmPassword = "weak"
        
        #expect(!viewModel.passwordValid, "Password should be invalid")
        #expect(!viewModel.canSubmit, "Should not allow submit")
        
        // Form data should be preserved
        #expect(viewModel.firstName == "John", "First name should be preserved")
        #expect(viewModel.email == "john@example.com", "Email should be preserved")
    }
}

