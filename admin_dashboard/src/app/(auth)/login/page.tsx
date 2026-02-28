"use client";
import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import { authApi } from "@/lib/api";

export default function LoginPage() {
  const router = useRouter();
  const { login } = useAuth();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [subdomain, setSubdomain] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await authApi.login(email, password, subdomain);
      login(res.data.token, subdomain);
      router.push("/dashboard");
    } catch (err: any) {
      setError(err.response?.data?.message || "Login failed. Please check your credentials.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative flex min-h-screen overflow-hidden">
      {/* Animated gradient background */}
      <div className="absolute inset-0 -z-10"
        style={{
          background:
            "linear-gradient(135deg, #0f172a 0%, #1e1b4b 40%, #0f172a 70%, #1a0a14 100%)",
        }}
      />
      {/* Decorative blobs */}
      <div className="pointer-events-none absolute -top-40 -right-40 h-[520px] w-[520px] rounded-full opacity-25"
        style={{ background: "radial-gradient(circle, #f43f5e 0%, transparent 70%)" }} />
      <div className="pointer-events-none absolute -bottom-40 -left-40 h-[420px] w-[420px] rounded-full opacity-20"
        style={{ background: "radial-gradient(circle, #6366f1 0%, transparent 70%)" }} />

      {/* Left panel — branding */}
      <div className="hidden lg:flex lg:w-1/2 flex-col items-center justify-center px-16 text-white">
        <div className="animate-fade-up max-w-sm text-center">
          <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-2xl"
            style={{ background: "linear-gradient(135deg, #f43f5e, #9f1239)" }}>
            <svg viewBox="0 0 24 24" fill="white" className="h-10 w-10">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
            </svg>
          </div>
          <h1 className="text-4xl font-extrabold tracking-tight">TrackMe Admin</h1>
          <p className="mt-3 text-lg text-slate-300 leading-relaxed">
            Real-time emergency response management for your organization.
          </p>
          <div className="mt-10 grid grid-cols-3 gap-4 text-center">
            {[
              { val: "99.9%", lbl: "Uptime" },
              { val: "< 2s",  lbl: "Response" },
              { val: "AES-256", lbl: "Encryption" },
            ].map(({ val, lbl }) => (
              <div key={lbl} className="card-glass rounded-xl px-4 py-3">
                <p className="text-xl font-bold text-rose-400">{val}</p>
                <p className="text-xs text-slate-400 mt-0.5">{lbl}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Right panel — form */}
      <div className="flex w-full items-center justify-center px-6 py-12 lg:w-1/2">
        <div className="animate-fade-up w-full max-w-md card-glass rounded-2xl p-8">
          {/* Mobile logo */}
          <div className="mb-8 flex flex-col items-center lg:hidden">
            <div className="mb-3 flex h-14 w-14 items-center justify-center rounded-xl"
              style={{ background: "linear-gradient(135deg, #f43f5e, #9f1239)" }}>
              <svg viewBox="0 0 24 24" fill="white" className="h-7 w-7">
                <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
              </svg>
            </div>
            <h1 className="text-2xl font-bold text-white">TrackMe Admin</h1>
          </div>

          <h2 className="text-xl font-bold text-white">Welcome back</h2>
          <p className="mt-1 text-sm text-slate-400">Sign in to your organization dashboard</p>

          <form onSubmit={handleSubmit} className="mt-7 space-y-4">
            {/* Subdomain */}
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-slate-400">
                Organization Subdomain
              </label>
              <div className="flex overflow-hidden rounded-[0.625rem] border border-white/10 focus-within:border-rose-500/60 focus-within:shadow-[0_0_0_3px_rgba(244,63,94,0.12)] transition-shadow">
                <input
                  type="text"
                  value={subdomain}
                  onChange={(e) => setSubdomain(e.target.value)}
                  placeholder="nypd"
                  required
                  className="flex-1 bg-white/5 px-3.5 py-2.5 text-sm text-white placeholder-slate-500 outline-none"
                />
                <span className="flex items-center bg-white/5 px-3 text-xs text-slate-500 border-l border-white/10">
                  .trackme.app
                </span>
              </div>
            </div>

            {/* Email */}
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-slate-400">
                Email
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@example.com"
                required
                className="w-full rounded-[0.625rem] border border-white/10 bg-white/5 px-3.5 py-2.5 text-sm text-white placeholder-slate-500 outline-none focus:border-rose-500/60 focus:shadow-[0_0_0_3px_rgba(244,63,94,0.12)] transition-shadow"
              />
            </div>

            {/* Password */}
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wide text-slate-400">
                Password
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••"
                required
                className="w-full rounded-[0.625rem] border border-white/10 bg-white/5 px-3.5 py-2.5 text-sm text-white placeholder-slate-500 outline-none focus:border-rose-500/60 focus:shadow-[0_0_0_3px_rgba(244,63,94,0.12)] transition-shadow"
              />
            </div>

            {error && (
              <div className="flex items-start gap-2 rounded-xl bg-rose-500/10 border border-rose-500/20 px-4 py-3 text-sm text-rose-300">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" className="mt-0.5 h-4 w-4 shrink-0">
                  <circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" />
                </svg>
                {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              className="mt-1 flex w-full items-center justify-center gap-2 rounded-[0.625rem] py-2.5 text-sm font-semibold text-white disabled:opacity-55 transition-all"
              style={{ background: loading ? "#be123c" : "linear-gradient(135deg, #f43f5e, #be123c)" }}
            >
              {loading ? (
                <>
                  <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/30 border-t-white" />
                  Signing in…
                </>
              ) : "Sign In →"}
            </button>
          </form>

          <p className="mt-6 text-center text-xs text-slate-500">
            Don&apos;t have an organization?{" "}
            <Link href="/signup" className="font-semibold text-rose-400 hover:text-rose-300">
              Start free trial
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
