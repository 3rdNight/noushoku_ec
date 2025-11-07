import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import Stripe from "stripe";

admin.initializeApp();

// ⚙️ Substitua "sk_test_ABC123..." pela sua chave secreta do Stripe (começa com "sk_test_...")
const stripe = new Stripe(
  "sk_test_51SPcfXCTxikVLYqMseAD91TnbMGBpw92ixiEfIxNyf3OmTkX8zflDGSeHfEqMaGGD1ly1LsUEMjZC0K8jH2iUxc800pwJ4y7ec",
  { apiVersion: "2025-10-29.clover" }
);

export const createPaymentIntent = functions.https.onRequest(
  async (req, res) => {
    try {
      const { amount, currency } = req.body;

      if (!amount || !currency) {
        res.status(400).send({ error: "amount e currency são obrigatórios" });
        return;
      }

      // Cria PaymentIntent no Stripe
      const paymentIntent = await stripe.paymentIntents.create({
        amount,
        currency,
        automatic_payment_methods: { enabled: true },
      });

      res.status(200).send({ clientSecret: paymentIntent.client_secret });
    } catch (error: unknown) {
      console.error("Erro ao criar PaymentIntent:", error);
      const message =
        error instanceof Error ? error.message : "Erro desconhecido";
      res.status(500).send({ error: message });
    }
  }
);
