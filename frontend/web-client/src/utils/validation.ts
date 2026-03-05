export function validateEmail(email: string): string | null {
  if (!email) return "Email is required";
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return "Invalid email format";
  return null;
}

export function validatePassword(password: string): string | null {
  if (!password) return "Password is required";
  if (password.length < 6) return "Password must be at least 6 characters";
  return null;
}

export function validateRequired(
  value: string,
  fieldName: string,
): string | null {
  if (!value || !value.trim()) return `${fieldName} is required`;
  return null;
}

export function validateUsername(username: string): string | null {
  if (!username) return "Username is required";
  if (username.length < 3) return "Username must be at least 3 characters";
  if (!/^[a-zA-Z0-9_]+$/.test(username))
    return "Username can only contain letters, numbers, and underscores";
  return null;
}
