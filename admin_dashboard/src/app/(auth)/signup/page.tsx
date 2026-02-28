"use client";
import { useState, FormEvent } from "react";
import { useRouter } from "next/navigation";
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

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-lg rounded-2xl bg-white p-8 shadow-md">
        <div className="mb-8 text-center">
          <span className="text-4xl">🚨</span>
          <h1 className="mt-2 text-2xl font-bold text-gray-900">Create Organization</h1>
          <p className="text-sm text-gray-500">Start your 14-day free trial. No credit card required.</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">First Name</label>
              <input type="text" value={form.admin_first_name} onChange={update("admin_first_name")} required
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none" />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">Last Name</label>
              <input type="text" value={form.admin_last_name} onChange={update("admin_last_name")} required
                className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none" />
            </div>
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-gray-700">Organization Name</label>
            <input type="text" value={form.organization_name} onChange={update("organization_name")} required
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none" />
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-gray-700">Subdomain</label>
            <div className="flex items-center">
              <input type="text" value={form.subdomain} onChange={update("subdomain")} required
                placeholder="nypd"
                className="flex-1 rounded-l-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none" />
              <span className="rounded-r-lg border border-l-0 border-gray-300 bg-gray-50 px-3 py-2 text-sm text-gray-500">
                .trackme.app
              </span>
            </div>
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-gray-700">Admin Email</label>
            <input type="email" value={form.admin_email} onChange={update("admin_email")} required
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none" />
          </div>

          <div>
            <label className="mb-1 block text-sm font-medium text-gray-700">Password</label>
            <input type="password" value={form.admin_password} onChange={update("admin_password")} required
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-red-500 focus:outline-none" />
            <p className="mt-1 text-xs text-gray-400">Min. 8 characters, one uppercase, one number.</p>
          </div>

          {error && <p className="rounded-lg bg-red-50 px-3 py-2 text-sm text-red-600">{error}</p>}

          <button type="submit" disabled={loading}
            className="w-full rounded-lg bg-red-600 py-2 text-sm font-semibold text-white hover:bg-red-700 disabled:opacity-50">
            {loading ? "Creating organization..." : "Start Free Trial"}
          </button>
        </form>

        <p className="mt-4 text-center text-xs text-gray-400">
          Already have an account?{" "}
          <a href="/login" className="text-red-600 hover:underline">Sign in</a>
        </p>
      </div>
    </div>
  );
}
