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
        viewModel.password = "SecurePass123!"
        
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
        viewModel.password = "SecurePass!"
        
        #expect(!viewModel.passwordValid, "Password without number should be invalid")
    }
    
    @Test
    func passwordValidMissingSpecialCharacter() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "SecurePass123"
        
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
        viewModel.password = "Secure_Pass123!"
        
        #expect(!viewModel.passwordValid, "Password containing underscore should be invalid")
    }
    
    @Test
    func passwordValidContainsDash() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "Secure-Pass123!"
        
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
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "SecurePass123!"
        
        #expect(viewModel.passwordsMatch, "Identical passwords should match")
    }
    
    @Test
    func passwordsMatchDifferent() async throws {
        let viewModel = RegisterViewModel()
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "DifferentPass456!"
        
        #expect(!viewModel.passwordsMatch, "Different passwords should not match")
    }
    
    @Test
    func canSubmitAllFieldsValid() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "SecurePass123!"
        
        #expect(viewModel.canSubmit, "Should allow submit when all fields are valid")
    }
    
    @Test
    func canSubmitMissingFirstName() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = ""
        viewModel.email = "john@example.com"
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "SecurePass123!"
        
        #expect(!viewModel.canSubmit, "Should not allow submit when first name is missing")
    }
    
    @Test
    func canSubmitMissingEmail() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = ""
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "SecurePass123!"
        
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
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "DifferentPass456!"
        
        #expect(!viewModel.canSubmit, "Should not allow submit when passwords don't match")
    }
    
    // MARK: - RegisterViewModel State Tests
    
    @Test
    func resetForm() async throws {
        let viewModel = RegisterViewModel()
        viewModel.firstName = "John"
        viewModel.email = "john@example.com"
        viewModel.password = "SecurePass123!"
        viewModel.confirmPassword = "SecurePass123!"
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
}

