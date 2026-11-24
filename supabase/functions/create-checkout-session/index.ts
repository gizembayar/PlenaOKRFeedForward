// POST { tier: "cool" | "icon", period: "monthly" | "yearly", success_url, cancel_url }
// → { url } — Stripe Checkout (abonelik) sayfası.
import {
  corsHeaders,
  ensureCustomer,
  json,
  type Period,
  priceFor,
  requireUser,
  safeUrl,
  stripe,
  type Tier,
} from "../_shared/stripe.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const user = await requireUser(req);
  if (!user) return json({ error: "unauthorized" }, 401);

  const body = await req.json().catch(() => ({}));
  const tier = body.tier as Tier;
  const period = (body.period as Period) ?? "yearly";
  if (tier !== "cool" && tier !== "icon") return json({ error: "invalid_tier" }, 400);
  if (period !== "monthly" && period !== "yearly") return json({ error: "invalid_period" }, 400);

  const price = priceFor(tier, period);
  if (!price) return json({ error: "price_not_configured" }, 500);

  const customer = await ensureCustomer(user.id, user.email);

  // Zaten aktif aboneliği varsa yeni abonelik yerine portalda plan değişikliği.
  const existing = await stripe.subscriptions.list({ customer, status: "active", limit: 1 });
  if (existing.data.length > 0) {
    const portal = await stripe.billingPortal.sessions.create({
      customer,
      return_url: safeUrl(body.success_url, "/app/profil"),
    });
    return json({ url: portal.url });
  }

  const session = await stripe.checkout.sessions.create({
    mode: "subscription",
    customer,
    client_reference_id: user.id,
    line_items: [{ price, quantity: 1 }],
    allow_promotion_codes: true,
    billing_address_collection: "required",
    locale: "tr",
    metadata: { supabase_user_id: user.id, tier },
    subscription_data: { metadata: { supabase_user_id: user.id, tier } },
    success_url: safeUrl(body.success_url, "/app/uyelik?durum=basarili"),
    cancel_url: safeUrl(body.cancel_url, "/uyelik?durum=iptal"),
  });

  return json({ url: session.url });
});
