"use client";
import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { useAuth } from "@/hooks/useAuth";
import { organizationApi } from "@/lib/api";

export default function SignupPage() {
  const router = useRouter();
  const { login } = useAuth();

  const [form, setForm] = useState({
    organization_name: "",
    subdomain: "",
    admin_email: "",
    admin_password: "",
    admin_first_name: "",
    admin_last_name: "",
  });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  const update = (field: string) => (e: React.ChangeEvent<HTMLInputElement>) =>
    setForm((f) => ({ ...f, [field]: e.target.value }));

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await organizationApi.signup(form);
      login(res.data.admin_token, form.subdomain);
      router.push("/dashboard");
    } catch (err: any) {
      setError(err.response?.data?.error || "Signup failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const inputCls =
    "w-full rounded-[0.625rem] border border-white/10 bg-white/5 px-3.5 py-2.5 text-sm text-white placeholder-slate-500 outline-none focus:border-rose-500/60 focus:shadow-[0_0_0_3px_rgba(244,63,94,0.12)] transition-shadow";
  const labelCls = "mb-1.5 block text-xs font-semibold uppercase tracking-wide text-slate-400";

  return (
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden px-4 py-12">
      {/* Background */}
      <div className="absolute inset-0 -z-10"
        style={{ background: "linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #1a0a14 100%)" }} />
      <div className="pointer-events-none absolute -top-32 right-0 h-[480px] w-[480px] rounded-full opacity-20"
        style={{ background: "radial-gradient(circle, #f43f5e 0%, transparent 70%)" }} />
      <div className="pointer-events-none absolute bottom-0 -left-32 h-[400px] w-[400px] rounded-full opacity-15"
        style={{ background: "radial-gradient(circle, #6366f1 0%, transparent 70%)" }} />

      <div className="animate-fade-up w-full max-w-lg card-glass rounded-2xl p-8">
        {/* Header */}
        <div className="mb-7 flex items-center gap-4">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl"
            style={{ background: "linear-gradient(135deg, #f43f5e, #9f1239)" }}>
            <svg viewBox="0 0 24 24" fill="white" className="h-6 w-6">
              <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z" />
            </svg>
          </div>
          <div>
            <h1 className="text-xl font-bold text-white">Create Organization</h1>
            <p className="text-sm text-slate-400">14-day free trial · No credit card required</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* Name row */}
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className={labelCls}>First Name</label>
              <input type="text" value={form.admin_first_name}
                onChange={update("admin_first_name")} required className={inputCls}
                placeholder="Jane" />
            </div>
            <div>
              <label className={labelCls}>Last Name</label>
              <input type="text" value={form.admin_last_name}
                onChange={update("admin_last_name")} required className={inputCls}
                placeholder="Smith" />
            </div>
          </div>

          <div>
            <label className={labelCls}>Organization Name</label>
            <input type="text" value={form.organization_name}
              onChange={update("organization_name")} required className={inputCls}
              placeholder="Acme Security Inc." />
          </div>

          <div>
            <label className={labelCls}>Subdomain</label>
            <div className="flex overflow-hidden rounded-[0.625rem] border border-white/10 focus-within:border-rose-500/60 focus-within:shadow-[0_0_0_3px_rgba(244,63,94,0.12)] transition-shadow">
              <input type="text" value={form.subdomain}
                onChange={update("subdomain")} required
                placeholder="acme"
                className="flex-1 bg-white/5 px-3.5 py-2.5 text-sm text-white placeholder-slate-500 outline-none" />
              <span className="flex items-center bg-white/5 px-3 text-xs text-slate-500 border-l border-white/10">
                .trackme.app
              </span>
            </div>
          </div>

          <div>
            <label className={labelCls}>Admin Email</label>
            <input type="email" value={form.admin_email}
              onChange={update("admin_email")} required className={inputCls}
              placeholder="admin@example.com" />
          </div>

          <div>
            <label className={labelCls}>Password</label>
            <input type="password" value={form.admin_password}
              onChange={update("admin_password")} required className={inputCls}
              placeholder="Min. 8 chars, 1 uppercase, 1 number" />
          </div>

          {error && (
            <div className="flex items-start gap-2 rounded-xl bg-rose-500/10 border border-rose-500/20 px-4 py-3 text-sm text-rose-300">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" className="mt-0.5 h-4 w-4 shrink-0">
                <circle cx="12" cy="12" r="10" /><path d="M12 8v4M12 16h.01" />
              </svg>
              {error}
            </div>
          )}

          <button type="submit" disabled={loading}
            className="mt-1 flex w-full items-center justify-center gap-2 rounded-[0.625rem] py-2.5 text-sm font-semibold text-white disabled:opacity-55 transition-all"
            style={{ background: loading ? "#be123c" : "linear-gradient(135deg, #f43f5e, #be123c)" }}>
            {loading ? (
              <>
                <span className="h-4 w-4 animate-spin rounded-full border-2 border-white/30 border-t-white" />
                Creating organization…
              </>
            ) : "Start Free Trial →"}
          </button>
        </form>

        <p className="mt-5 text-center text-xs text-slate-500">
          Already have an account?{" "}
          <Link href="/login" className="font-semibold text-rose-400 hover:text-rose-300">
            Sign in
          </Link>
        </p>
      </div>
    </div>
  );
}
