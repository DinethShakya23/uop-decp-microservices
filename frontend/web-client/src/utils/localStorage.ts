const TOKEN_KEY = "decp_token";
const USER_KEY = "decp_user";

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

export function removeToken(): void {
  localStorage.removeItem(TOKEN_KEY);
}

export function getStoredUser(): string | null {
  return localStorage.getItem(USER_KEY);
}

export function setStoredUser(user: string): void {
  localStorage.setItem(USER_KEY, user);
}

export function removeStoredUser(): void {
  localStorage.removeItem(USER_KEY);
}

export function clearAuth(): void {
  removeToken();
  removeStoredUser();
}
