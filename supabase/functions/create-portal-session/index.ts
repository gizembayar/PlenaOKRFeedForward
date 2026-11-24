// POST { return_url } → { url } — Stripe Müşteri Portalı
// (iptal, plan değişikliği, kart güncelleme, faturalar).
import { corsHeaders, ensureCustomer, json, requireUser, safeUrl, stripe } from "../_shared/stripe.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const user = await requireUser(req);
  if (!user) return json({ error: "unauthorized" }, 401);

  const body = await req.json().catch(() => ({}));
  const customer = await ensureCustomer(user.id, user.email);
  const portal = await stripe.billingPortal.sessions.create({
    customer,
    return_url: safeUrl(body.return_url, "/app/profil"),
  });
  return json({ url: portal.url });
});
