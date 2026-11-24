import Stripe from "npm:stripe@17.7.0";
import { createClient } from "npm:@supabase/supabase-js@2.49.1";

export const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY")!, {
  apiVersion: "2025-02-24.acacia",
  httpClient: Stripe.createFetchHttpClient(),
});

export const cryptoProvider = Stripe.createSubtleCryptoProvider();

/** Service role istemcisi — RLS'i aşar, yalnızca sunucuda kullanılır. */
export const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  { auth: { persistSession: false } },
);

export type Tier = "free" | "cool" | "icon";
export type Period = "monthly" | "yearly";

/**
 * Stripe Price ID'leri ortam değişkenlerinden okunur:
 *   STRIPE_PRICE_COOL_MONTHLY, STRIPE_PRICE_COOL_YEARLY,
 *   STRIPE_PRICE_ICON_MONTHLY, STRIPE_PRICE_ICON_YEARLY
 */
export function priceFor(tier: Tier, period: Period): string | undefined {
  return Deno.env.get(`STRIPE_PRICE_${tier.toUpperCase()}_${period.toUpperCase()}`);
}

export function tierForPrice(priceId: string | undefined): Tier {
  if (!priceId) return "free";
  for (const tier of ["cool", "icon"] as const) {
    for (const period of ["monthly", "yearly"] as const) {
      if (priceFor(tier, period) === priceId) return tier;
    }
  }
  return "free";
}

export const corsHeaders = {
  "Access-Control-Allow-Origin": Deno.env.get("SITE_URL") ?? "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** İstekteki JWT'den kullanıcıyı doğrular. */
export async function requireUser(req: Request) {
  const token = req.headers.get("Authorization")?.replace("Bearer ", "");
  if (!token) return null;
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return null;
  return data.user;
}

/** Yalnızca kendi sitemize yönlendirmeye izin ver (open redirect önlemi). */
export function safeUrl(url: unknown, fallbackPath: string): string {
  const site = Deno.env.get("SITE_URL")!;
  if (typeof url === "string" && url.startsWith(site)) return url;
  return `${site}${fallbackPath}`;
}

/** Profil için Stripe müşterisini bulur ya da oluşturur. */
export async function ensureCustomer(userId: string, email?: string) {
  const { data: profile } = await admin
    .from("profiles")
    .select("stripe_customer_id, display_name")
    .eq("id", userId)
    .single();

  if (profile?.stripe_customer_id) return profile.stripe_customer_id as string;

  const customer = await stripe.customers.create({
    email,
    name: profile?.display_name ?? undefined,
    metadata: { supabase_user_id: userId },
  });
  await admin.from("profiles").update({ stripe_customer_id: customer.id }).eq("id", userId);
  return customer.id;
}
