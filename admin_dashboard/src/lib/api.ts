import axios from "axios";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || "";

export const api = axios.create({
  baseURL: BASE_URL,
  headers: { "Content-Type": "application/json" },
});

/** Attach JWT and organization headers to every request automatically. */
api.interceptors.request.use((config) => {
  if (typeof window !== "undefined") {
    const token = localStorage.getItem("admin_token");
    const subdomain = localStorage.getItem("org_subdomain");
    if (token) config.headers.Authorization = `Bearer ${token}`;
    if (subdomain) config.headers["x-organization-subdomain"] = subdomain;
  }
  return config;
});

/** Redirect to login on 401. */
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401 && typeof window !== "undefined") {
      localStorage.removeItem("admin_token");
      window.location.href = "/login";
    }
    return Promise.reject(err);
  }
);

// ── API helpers ───────────────────────────────────────────────────────────────

export const authApi = {
  login: (email: string, password: string, subdomain: string) =>
    api.post("/api/users/login", { email, password }, {
      headers: { "x-organization-subdomain": subdomain },
    }),
};

export const organizationApi = {
  me: () => api.get("/api/organizations/me"),
  signup: (data: Record<string, string>) => api.post("/api/organizations/signup", data),
};

export const usersApi = {
  list: () => api.get("/api/users"),
};

export const facilitatorsApi = {
  list: () => api.get("/api/facilitators"),
};

export const queriesApi = {
  list: () => api.get("/api/queries"),
};
