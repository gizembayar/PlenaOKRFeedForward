// Stripe → Supabase: üyelik durumunu profile yazar.
// JWT doğrulaması kapalı deploy edilir (Stripe imzası doğrulanır):
//   supabase functions deploy stripe-webhook --no-verify-jwt
import type Stripe from "npm:stripe@17.7.0";
import { admin, cryptoProvider, stripe, tierForPrice } from "../_shared/stripe.ts";

const ACTIVE = new Set(["active", "trialing", "past_due"]);

async function syncSubscription(sub: Stripe.Subscription) {
  const customerId = typeof sub.customer === "string" ? sub.customer : sub.customer.id;
  const priceId = sub.items.data[0]?.price.id;
  const tier = ACTIVE.has(sub.status) ? tierForPrice(priceId) : "free";

  const update = {
    tier,
    stripe_subscription_id: sub.id,
    subscription_status: sub.status,
    current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
  };

  const userId = sub.metadata?.supabase_user_id;
  const query = admin.from("profiles").update(update);
  const { error } = userId
    ? await query.eq("id", userId)
    : await query.eq("stripe_customer_id", customerId);
  if (error) throw error;
}

Deno.serve(async (req) => {
  const signature = req.headers.get("Stripe-Signature");
  if (!signature) return new Response("missing signature", { status: 400 });

  let event: Stripe.Event;
  try {
    event = await stripe.webhooks.constructEventAsync(
      await req.text(),
      signature,
      Deno.env.get("STRIPE_WEBHOOK_SECRET")!,
      undefined,
      cryptoProvider,
    );
  } catch (err) {
    return new Response(`invalid signature: ${(err as Error).message}`, { status: 400 });
  }

  // Idempotency: aynı olay ikinci kez gelirse atla.
  const { error: dup } = await admin
    .from("stripe_events")
    .insert({ id: event.id, type: event.type });
  if (dup?.code === "23505") return new Response("duplicate", { status: 200 });

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const s = event.data.object as Stripe.Checkout.Session;
        if (s.mode === "subscription" && s.subscription) {
          const sub = await stripe.subscriptions.retrieve(s.subscription as string);
          // client_reference_id ile müşteri ↔ kullanıcı eşleşmesini garantiye al
          if (s.client_reference_id && s.customer) {
            await admin
              .from("profiles")
              .update({ stripe_customer_id: s.customer as string })
              .eq("id", s.client_reference_id);
          }
          await syncSubscription(sub);
        }
        break;
      }
      case "customer.subscription.created":
      case "customer.subscription.updated":
      case "customer.subscription.deleted":
        await syncSubscription(event.data.object as Stripe.Subscription);
        break;
      default:
        break;
    }
  } catch (err) {
    // Olayı tekrar denenebilir bırak.
    await admin.from("stripe_events").delete().eq("id", event.id);
    console.error(err);
    return new Response("handler error", { status: 500 });
  }

  return new Response("ok", { status: 200 });
});
