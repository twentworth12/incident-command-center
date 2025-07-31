# Security Policy

## 🛡️ Security Principles

The Incident Command Center for Apple TV is designed with security and privacy as core principles:

- **User Data Control**: Users maintain complete control over their incident.io API keys
- **Local Storage Only**: API keys are stored locally on the device using iOS Keychain
- **No Data Collection**: The app does not collect, transmit, or store any user data externally
- **Secure Communication**: All API communications use HTTPS with proper certificate validation
- **Minimal Permissions**: The app requests only necessary permissions

## 🔒 Supported Versions

We actively maintain security for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | ✅ Yes             |
| < 1.0   | ❌ No              |

## 🚨 Reporting a Vulnerability

If you discover a security vulnerability, please follow responsible disclosure:

### 📧 Contact

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please email: **[Contact information will be added]**

### 📋 Information to Include

When reporting a vulnerability, please include:

- **Description** of the vulnerability
- **Steps to reproduce** the issue
- **Potential impact** assessment
- **Suggested mitigation** (if you have ideas)
- **Your contact information** for follow-up

### ⏱️ Response Timeline

- **Initial response**: Within 48 hours
- **Status update**: Within 1 week  
- **Resolution timeline**: Depends on severity and complexity

### 🏆 Recognition

We appreciate security researchers who help keep our users safe:

- Security contributors will be acknowledged (if desired)
- We'll coordinate public disclosure timing
- Critical findings may be eligible for recognition

## 🔐 Security Features

### Data Protection
- **API keys stored in iOS Keychain** with `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- **No hardcoded credentials** in source code
- **Input validation** for all user-provided data
- **Secure error handling** without exposing sensitive information

### Network Security
- **HTTPS only** for all API communications
- **Certificate validation** for incident.io API
- **Request timeout handling** to prevent hanging connections
- **Graceful degradation** when API is unavailable

### Code Security
- **No force unwrapping** that could cause crashes
- **Proper error boundaries** to prevent data leakage
- **Memory safety** through Swift's type system
- **Input sanitization** for display purposes

## 🛠️ Security Best Practices for Developers

If you're contributing to the project:

### Code Reviews
- All code changes require review
- Security-sensitive changes require additional scrutiny
- Focus on input validation and error handling

### Testing
- Test error conditions and edge cases
- Verify that sensitive data isn't logged
- Test network failure scenarios

### Dependencies
- Keep dependencies up to date
- Review new dependencies for security issues
- Minimize external dependencies

## 📱 User Security Recommendations

### API Key Management
- **Generate dedicated API keys** for the Apple TV app
- **Use minimal permissions** necessary for incident viewing
- **Rotate API keys regularly** as part of security hygiene
- **Revoke unused API keys** from your incident.io dashboard

### Device Security
- **Keep Apple TV updated** with latest tvOS versions
- **Use strong Apple ID passwords** with two-factor authentication
- **Secure your home network** with WPA3 when possible

### Network Security
- **Use trusted networks** for incident data
- **Consider VPN** for sensitive environments
- **Monitor network traffic** in enterprise environments

## 🚫 What We Don't Do

To protect your privacy:

- **No analytics or tracking** of any kind
- **No crash reporting** that includes sensitive data
- **No automatic updates** of API keys or settings
- **No data sharing** with third parties
- **No cloud storage** of any user data

## 📚 Security Resources

- [Apple Security Guide](https://support.apple.com/guide/security/)
- [incident.io Security](https://incident.io/security)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Swift Security Best Practices](https://swift.org/security/)

## 🔄 Updates to This Policy

This security policy may be updated periodically. Users will be notified of significant changes through:

- GitHub repository notifications
- Release notes
- README updates

---

**Last updated**: July 2025

**Remember**: If you see something, say something. Security is everyone's responsibility! 🛡️