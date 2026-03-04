"use client";
import { useState, useEffect } from "react";

export interface AuthUser {
  token: string;
  subdomain: string;
}

export function useAuth() {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("admin_token");
    const subdomain = localStorage.getItem("org_subdomain");
    if (token && subdomain) {
      setUser({ token, subdomain });
    }
    setLoading(false);
  }, []);

  const login = (token: string, subdomain: string) => {
    localStorage.setItem("admin_token", token);
    localStorage.setItem("org_subdomain", subdomain);
    setUser({ token, subdomain });
  };

  const logout = () => {
    localStorage.removeItem("admin_token");
    localStorage.removeItem("org_subdomain");
    setUser(null);
  };

  const isAuthenticated = !!user;

  return { user, loading, login, logout, isAuthenticated };
}
