import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import "./ResetPassword.css";
import '../common/AuthCommon.css';
import { Logo1 } from "../../Logos/Logos";
import { CloseIcon } from "../../Icons/Icons";
import EmailStep from "./steps/EmailStep";
import CodeStep from "./steps/CodeStep";
import PasswordStep from "./steps/PasswordStep";
import API from "../../../api/axios";

const ResetPassword = () => {
  const [step, setStep] = useState(1);
  const [email, setEmail] = useState("");
  const [code, setCode] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [serverError, setServerError] = useState("");

  const navigate = useNavigate();

  // Step 1: Send verification code to email
  const handleEmailSubmit = async () => {
    if (!email) return setServerError("Please enter your email");
    setServerError("");
    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/request", { email });
      setStep(2);
    } catch (err) {
      setServerError(err.response?.data?.detail || "Failed to send verification code");
    } finally {
      setIsLoading(false);
    }
  };

  // Step 2: Verify code
  const handleCodeSubmit = async () => {
    if (code.length !== 4) return setServerError("Please enter the 4-digit code");
    setServerError("");
    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/verify", { email, code });
      setStep(3);
    } catch (err) {
      setServerError(err.response?.data?.detail || "Invalid code");
    } finally {
      setIsLoading(false);
    }
  };

  // Step 3: Reset password
  const handlePasswordSubmit = async () => {
    if (!newPassword || newPassword !== confirmPassword) {
      return setServerError("Passwords do not match");
    }
    setServerError("");
    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/confirm", {
        email,
        code,
        new_password: newPassword
      });
      alert("Password reset successful!");
      navigate("/signin");
    } catch (err) {
      setServerError(err.response?.data?.detail || "Failed to reset password");
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendCode = async () => {
    if (!email) return setServerError("Please enter your email first");
    setServerError("");
    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/request", { email });
      alert("Verification code sent again!");
    } catch (err) {
      setServerError(err.response?.data?.detail || "Failed to resend code");
    } finally {
      setIsLoading(false);
    }
  };

  const handleClose = () => navigate("/signin");

  return (
    <div className="auth-container">
      <div className="auth-card reset-card">
        <button className="auth-close-btn" onClick={handleClose}>
          <CloseIcon />
        </button>

        <div className="reset-header">
          <Logo1 />
          <div className="reset-title">
            <h2>Reset Password</h2>
          </div>
        </div>

        {/* Step Indicator */}
        <div className="step-indicator">
          {[1, 2, 3].map((s) => (
            <React.Fragment key={s}>
              {s !== 1 && <div className="step-connector"></div>}
              <div className="step-container">
                <div className={`step ${step >= s ? 'active' : ''}`}>
                  <span>{s}</span>
                </div>
                <div className="step-label">
                  {s === 1 ? "Email" : s === 2 ? "Verify" : "Reset"}
                </div>
              </div>
            </React.Fragment>
          ))}
        </div>

        {serverError && <div className="server-error">{serverError}</div>}

        {/* Render the current step */}
        {step === 1 && (
          <EmailStep
            email={email}
            setEmail={setEmail}
            isLoading={isLoading}
            onSubmit={handleEmailSubmit}
          />
        )}
        {step === 2 && (
          <CodeStep
            email={email}
            code={code}
            setCode={setCode}
            isLoading={isLoading}
            onSubmit={handleCodeSubmit}
            onResend={handleResendCode}
          />
        )}
        {step === 3 && (
          <PasswordStep
            newPassword={newPassword}
            setNewPassword={setNewPassword}
            confirmPassword={confirmPassword}
            setConfirmPassword={setConfirmPassword}
            isLoading={isLoading}
            onSubmit={handlePasswordSubmit}
          />
        )}
      </div>
    </div>
  );
};

export default ResetPassword;
