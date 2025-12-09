import * as functions from "firebase-functions";
import express from "express";
import Stripe from "stripe";
import * as admin from "firebase-admin";
import cors from "cors";

// Inicializa o Firebase Admin
admin.initializeApp();
const app = express();

// 🔹 Configura CORS corretamente (aceita tanto localhost quanto o domínio do site)
app.use(
  cors({
    origin: true,
    methods: ["GET", "POST", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
  })
);

// 🔹 Lida com preflight OPTIONS requests
app.options("/create-checkout-session", cors());

// Body parser
app.use(express.json());

// Inicializa Stripe
const stripe = new Stripe(
  "sk_test_51SPcfXCTxikVLYqMseAD91TnbMGBpw92ixiEfIxNyf3OmTkX8zflDGSeHfEqMaGGD1ly1LsUEMjZC0K8jH2iUxc800pwJ4y7ec",
  { apiVersion: "2025-10-29.clover" }
);

// 🔹 Endpoint principal
app.post("/create-checkout-session", async (req, res) => {
  try {
    const { amount, currency, email } = req.body;

    if (!amount || !currency) {
      return res.status(400).json({ error: "amount and currency are required" });
    }

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      mode: "payment",
      line_items: [
        {
          price_data: {
            currency,
            product_data: { name: "農食のオーダー" },
            unit_amount: amount,
          },
          quantity: 1,
        },
      ],
      customer_email: email,
      success_url: "https://noushoku-ec.web.app/success",
      cancel_url: "https://noushoku-ec.web.app/cancel",
    });

    return res.status(200).json({ url: session.url });
  } catch (err: any) {
    console.error("Error in createCheckoutSession:", err);
    return res.status(500).json({ error: err.message || "Internal Error" });
  }
});

// 🔹 Exporta função HTTP (1ª geração)
export const createCheckoutSession = functions.https.onRequest(app);
