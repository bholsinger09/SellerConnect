# SellerConnect Security Guidelines

## Protecting Secrets

### Environment Variables
Never commit secrets to git. Use environment variables and configuration files that are gitignored.

1. **Copy example files:**
   ```bash
   cp .env.example .env
   cp SellerConnectBackend/.env.example SellerConnectBackend/.env
   ```

2. **Fill in local values** - only in the .env files (these are gitignored)

3. **Verify .env is in .gitignore** - it should be!

### What NOT to commit:
- `.env` files with real values
- API keys or tokens
- Database credentials
- Private keys (`.key`, `.pem`, `.p12`)
- Test fixtures with real passwords
- Configuration files with sensitive data

### Git Pre-commit Checks
Before committing, ensure you haven't accidentally added:
- Hardcoded API keys
- Hardcoded database passwords
- AWS/GCloud credentials
- JWT secrets
- Authentication tokens

### GitHub Secret Scanner
GitHub automatically scans commits for common secret patterns. If GitHub detects secrets:

1. **Revoke the secret immediately** if it's a real credential
2. **Remove from git history:**
   ```bash
   # View all commits with potential secrets
   git log --all --oneline
   
   # If needed, use git filter-branch or git-filter-repo to remove
   ```
3. **Update .gitignore** to prevent future commits
4. **Inform team members** about the incident

### Test Fixtures
Unit tests use generic test values (e.g., "Test@123!") which are safe to commit.

### Local Development
- Each developer has their own `.env` file (not committed)
- Use environment variables for configuration
- Never push staging/production credentials to git

### Deployment
Use proper secret management in production:
- AWS Secrets Manager
- HashiCorp Vault
- GitHub Secrets (for CI/CD)
- Environment variables set by platform (Heroku, Docker, etc.)

## Best Practices

1. ✅ Use .env files for local configuration (gitignored)
2. ✅ Use .env.example as a template (committed)
3. ✅ Rotate keys if accidentally committed
4. ✅ Use different credentials for dev/staging/production
5. ✅ Review commits before pushing with `git diff`
6. ✅ Enable branch protection rules on main

## References
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
