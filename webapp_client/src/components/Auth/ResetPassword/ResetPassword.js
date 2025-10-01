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

  const navigate = useNavigate();

  const handleEmailSubmit = async () => {
    if (!email) return alert("Please enter your email");

    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/request", { email });
      setStep(2);
    } catch (err) {
      alert(err.response?.data?.detail || "Failed to send verification code");
    } finally {
      setIsLoading(false);
    }
  };

  const handleCodeSubmit = async () => {
    if (code.length !== 4) return alert("Please enter the 4-digit code");

    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/verify", { email, code });
      setStep(3);
    } catch (err) {
      alert(err.response?.data?.detail || "Invalid code");
    } finally {
      setIsLoading(false);
    }
  };

  const handlePasswordSubmit = async () => {
    if (!newPassword || newPassword !== confirmPassword)
      return alert("Passwords do not match");

    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/confirm", { email, code, new_password: newPassword });
      alert("Password reset successful!");
      navigate("/signin");
    } catch (err) {
      alert(err.response?.data?.detail || "Failed to reset password");
    } finally {
      setIsLoading(false);
    }
  };

  const handleResendCode = async () => {
    if (!email) return alert("Please enter your email first");

    setIsLoading(true);
    try {
      await API.post("/api/auth/reset-password/request", { email });
      alert("Verification code sent again!");
    } catch (err) {
      alert(err.response?.data?.detail || "Failed to resend code");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card reset-card">
        <button className="auth-close-btn" onClick={() => navigate("/signin")}>
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
          <div className="step-container">
            <div className={`step ${step >= 1 ? 'active' : ''}`}>
              <span>1</span>
            </div>
            <div className="step-label">Email</div>
          </div>

          <div className="step-connector"></div>

          <div className="step-container">
            <div className={`step ${step >= 2 ? 'active' : ''}`}>
              <span>2</span>
            </div>
            <div className="step-label">Verify</div>
          </div>

          <div className="step-connector"></div>

          <div className="step-container">
            <div className={`step ${step >= 3 ? 'active' : ''}`}>
              <span>3</span>
            </div>
            <div className="step-label">Reset</div>
          </div>
        </div>

        {/* Render the appropriate step component */}
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
