// ── Organization ──────────────────────────────────────────────────────────────

export type SubscriptionTier = "free" | "professional" | "enterprise";
export type SubscriptionStatus = "active" | "trial" | "suspended";

export interface Organization {
  id: string;
  name: string;
  subdomain: string;
  subscription_tier: SubscriptionTier;
  subscription_status: SubscriptionStatus;
  max_users: number;
  max_facilitators: number;
  api_key?: string;
  stripe_customer_id?: string | null;
  trial_ends_at?: string | null;
  subscription_ends_at?: string | null;
}

// ── User ──────────────────────────────────────────────────────────────────────

export interface User {
  id: number;
  firstname: string;
  lastname: string;
  email: string;
  gender?: string;
  number?: string;
  organization_id?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

// ── Facilitator ───────────────────────────────────────────────────────────────

export type FacilitatorRole = "Police" | "Ambulance" | "Road Assistance" | "Rescue";

export interface Facilitator {
  id: number;
  firstname: string;
  lastname: string;
  email: string;
  role: FacilitatorRole;
  location?: string | null;
  gender?: string;
  number?: string;
  organization_id?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

// ── Query ─────────────────────────────────────────────────────────────────────

export type QueryType =
  | "Home Invasion"
  | "Medical Help"
  | "Fire Extinguisher"
  | "Travel Emergency";

export interface Query {
  id: number;
  text?: string;
  querytype: QueryType;
  location?: string;
  audio_url?: string;
  postedBy: string;
  assignedTo?: number;
  completed?: boolean;
  organization_id?: string | null;
  createdAt?: string;
  updatedAt?: string;
}

// ── Auth ──────────────────────────────────────────────────────────────────────

export interface AuthUser {
  token: string;
  subdomain: string;
}

export interface LoginCredentials {
  email: string;
  password: string;
  subdomain: string;
}

export interface OrgSignupPayload {
  organization_name: string;
  subdomain: string;
  admin_email: string;
  admin_password: string;
  admin_first_name: string;
  admin_last_name: string;
}
